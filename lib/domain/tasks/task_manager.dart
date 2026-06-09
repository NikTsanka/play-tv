import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lifecycle of a background task (spec §11).
enum TaskStatus { queued, running, completed, failed, cancelled }

/// Raised by [TaskController.throwIfCancelled] to abort a task.
class TaskCancelled implements Exception {
  const TaskCancelled();
  @override
  String toString() => 'Task cancelled';
}

/// Immutable snapshot of one task, emitted to the tasks panel.
@immutable
class TaskProgress {
  const TaskProgress({
    required this.id,
    required this.label,
    required this.status,
    this.progress,
    this.message,
    this.error,
  });

  final String id;
  final String label;
  final TaskStatus status;

  /// 0..1, or null for indeterminate.
  final double? progress;
  final String? message;
  final String? error;

  bool get isActive =>
      status == TaskStatus.queued || status == TaskStatus.running;
  bool get isDone => !isActive;

  TaskProgress copyWith({
    TaskStatus? status,
    Object? progress = _sentinel,
    Object? message = _sentinel,
    Object? error = _sentinel,
  }) =>
      TaskProgress(
        id: id,
        label: label,
        status: status ?? this.status,
        progress: progress == _sentinel ? this.progress : progress as double?,
        message: message == _sentinel ? this.message : message as String?,
        error: error == _sentinel ? this.error : error as String?,
      );

  static const Object _sentinel = Object();
}

/// Handed to a task body for cooperative cancellation + progress reporting.
class TaskController {
  TaskController(this._onReport);

  final void Function(double? progress, String? message) _onReport;
  bool _cancelled = false;

  bool get isCancelled => _cancelled;

  void throwIfCancelled() {
    if (_cancelled) throw const TaskCancelled();
  }

  /// Reports [progress] (0..1, or null for indeterminate) and optional [message].
  void report(double? progress, [String? message]) =>
      _onReport(progress, message);
}

/// Result handle for an enqueued task.
class TaskHandle<T> {
  TaskHandle(this.id, this.result);
  final String id;
  final Future<T> result;
}

class _TaskEntry {
  _TaskEntry(this.progress);
  TaskProgress progress;
  TaskController? controller;
}

/// Central hub for cancellable background work with progress streams (spec §11).
/// All downloads / fetches run through here so the UI can show and cancel them.
class TaskManager {
  final Map<String, _TaskEntry> _tasks = <String, _TaskEntry>{};
  final StreamController<List<TaskProgress>> _ctrl =
      StreamController<List<TaskProgress>>.broadcast();
  int _seq = 0;

  Stream<List<TaskProgress>> get stream => _ctrl.stream;

  List<TaskProgress> get tasks =>
      _tasks.values.map((_TaskEntry e) => e.progress).toList();

  /// Enqueues [action], returning a handle. The body receives a [TaskController]
  /// for cancellation/progress. The handle's [TaskHandle.result] completes with
  /// the value, or errors with [TaskCancelled] / the thrown error.
  TaskHandle<T> run<T>({
    required String label,
    required Future<T> Function(TaskController controller) action,
  }) {
    final String id = 'task-${_seq++}';
    final _TaskEntry entry = _TaskEntry(
        TaskProgress(id: id, label: label, status: TaskStatus.queued));
    _tasks[id] = entry;

    final TaskController controller = TaskController((double? p, String? m) {
      _patch(id, (TaskProgress t) =>
          t.copyWith(status: TaskStatus.running, progress: p, message: m));
    });
    entry.controller = controller;
    _emit();

    final Future<T> result = _execute<T>(id, controller, action);
    return TaskHandle<T>(id, result);
  }

  Future<T> _execute<T>(String id, TaskController controller,
      Future<T> Function(TaskController) action) async {
    _patch(id, (TaskProgress t) => t.copyWith(status: TaskStatus.running));
    try {
      final T value = await action(controller);
      _patch(
          id,
          (TaskProgress t) =>
              t.copyWith(status: TaskStatus.completed, progress: 1.0));
      return value;
    } on TaskCancelled {
      _patch(id, (TaskProgress t) => t.copyWith(status: TaskStatus.cancelled));
      rethrow;
    } catch (e) {
      _patch(id,
          (TaskProgress t) => t.copyWith(status: TaskStatus.failed, error: '$e'));
      rethrow;
    }
  }

  void cancel(String id) => _tasks[id]?.controller?._cancelled = true;

  /// Drops finished tasks from the list.
  void clearFinished() {
    _tasks.removeWhere((_, _TaskEntry e) => e.progress.isDone);
    _emit();
  }

  void dispose() => _ctrl.close();

  void _patch(String id, TaskProgress Function(TaskProgress) update) {
    final _TaskEntry? entry = _tasks[id];
    if (entry == null) return;
    entry.progress = update(entry.progress);
    _emit();
  }

  void _emit() {
    if (!_ctrl.isClosed) _ctrl.add(tasks);
  }
}

final taskManagerProvider = Provider<TaskManager>((ref) {
  final TaskManager manager = TaskManager();
  ref.onDispose(manager.dispose);
  return manager;
});

/// Live list of all tasks (active + recently finished) for the tasks panel.
final tasksStreamProvider = StreamProvider<List<TaskProgress>>((ref) {
  final TaskManager manager = ref.watch(taskManagerProvider);
  return manager.stream;
});
