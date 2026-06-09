import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../core/logging/app_logger.dart';
import '../../core/storage/app_paths.dart';
import '../../core/storage/preferences.dart';
import '../channels/channel.dart';
import '../channels/channels_providers.dart';
import '../playback/playback_providers.dart';
import '../playback/playback_status.dart';
import '../providers/stream_resolver.dart';
import 'filename_template.dart';
import 'recorded_file.dart';
import 'recorder.dart';
import 'schedule.dart';
import 'storage/schedule_repository.dart';

/// The active filename template (persisted), defaulting to the standard pattern.
final recordingTemplateProvider = Provider<String>((ref) {
  return ref.watch(sharedPreferencesProvider).getString(
        PrefKeys.recordingTemplate,
      ) ??
      FilenameTemplate.defaultPattern;
});

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepository(ref.watch(appDatabaseProvider));
});

final scheduledTasksProvider = StreamProvider<List<ScheduledTask>>((ref) {
  return ref.watch(scheduleRepositoryProvider).watch();
});

/// Lists the recordings folder, newest first.
final recordedFilesProvider =
    FutureProvider.autoDispose<List<RecordedFile>>((ref) async {
  final Directory dir = AppPaths.instance.recordings;
  if (!await dir.exists()) return const <RecordedFile>[];
  final List<RecordedFile> files = <RecordedFile>[];
  await for (final FileSystemEntity e in dir.list()) {
    if (e is File) {
      final FileStat st = await e.stat();
      files.add(RecordedFile(
        path: e.path,
        name: p.basename(e.path),
        sizeBytes: st.size,
        modified: st.modified,
      ));
    }
  }
  files.sort((a, b) => b.modified.compareTo(a.modified));
  return files;
});

/// Owns the in-flight recordings (spec §10). Active recordings only; completed
/// ones drop out and appear in [recordedFilesProvider].
class RecordingController extends Notifier<List<RecordingStatus>> {
  final Map<String, HttpStreamRecorder> _recorders =
      <String, HttpStreamRecorder>{};
  final Map<String, StreamSubscription<RecordingStatus>> _subs =
      <String, StreamSubscription<RecordingStatus>>{};

  @override
  List<RecordingStatus> build() {
    ref.onDispose(() {
      for (final HttpStreamRecorder r in _recorders.values) {
        r.stop();
      }
      for (final StreamSubscription<RecordingStatus> s in _subs.values) {
        s.cancel();
      }
    });
    return const <RecordingStatus>[];
  }

  /// Starts recording [url] to a templated file. Returns the recording id, or
  /// null if [url] is empty.
  Future<String?> record({
    required String url,
    required String title,
    required String channelName,
    Map<String, String> headers = const <String, String>{},
  }) async {
    if (url.isEmpty) return null;
    final String fileName = FilenameTemplate(ref.read(recordingTemplateProvider))
        .build(
      channel: channelName,
      title: title == channelName ? null : title,
      when: DateTime.now(),
    );
    final String path = p.join(AppPaths.instance.recordings.path, fileName);
    final String id = DateTime.now().microsecondsSinceEpoch.toString();

    final HttpStreamRecorder rec = HttpStreamRecorder(
      id: id,
      url: url,
      filePath: path,
      title: title,
      headers: headers,
    );
    _recorders[id] = rec;
    _subs[id] = rec.statusStream.listen(_upsert, onDone: () => _onDone(id));
    _upsert(rec.status);
    log.i('Recording "$title" → $path');
    await rec.start();
    return id;
  }

  /// Records a channel, resolving session-based URLs (Stalker/OTT) first.
  Future<String?> recordChannel(Channel channel, int? sourceId,
      {String? title}) async {
    String url = channel.url;
    try {
      final String? resolved =
          await ref.read(streamResolverProvider).resolve(channel, sourceId);
      if (resolved != null && resolved.isNotEmpty) url = resolved;
    } catch (e) {
      log.w('Record URL resolution failed: $e');
    }
    return record(
      url: url,
      title: title ?? channel.name,
      channelName: channel.name,
      headers: channel.headers,
    );
  }

  Future<void> stop(String id) async => _recorders[id]?.stop();

  void _upsert(RecordingStatus s) {
    final List<RecordingStatus> list = <RecordingStatus>[...state];
    final int i = list.indexWhere((RecordingStatus e) => e.id == s.id);
    if (i >= 0) {
      list[i] = s;
    } else {
      list.add(s);
    }
    state = list;
  }

  void _onDone(String id) {
    _subs.remove(id)?.cancel();
    _recorders.remove(id);
    state = state.where((RecordingStatus s) => s.id != id).toList();
  }
}

final recordingControllerProvider =
    NotifierProvider<RecordingController, List<RecordingStatus>>(
        RecordingController.new);

/// Fires due [ScheduledTask]s on a timer (spec §10). Records auto-stop at their
/// `endAt`; recurring tasks are rescheduled, one-shots removed. Reminders are
/// surfaced via [events].
class SchedulerService {
  SchedulerService(this._ref);

  final Ref _ref;
  Timer? _timer;
  final Map<int, ({String recordingId, DateTime endAt})> _activeRecordings =
      <int, ({String recordingId, DateTime endAt})>{};
  final StreamController<ScheduledTask> _events =
      StreamController<ScheduledTask>.broadcast();

  /// Fired reminders / events for the UI to surface.
  Stream<ScheduledTask> get events => _events.stream;

  void start() {
    _timer ??= Timer.periodic(const Duration(seconds: 20), (_) => tick());
  }

  void dispose() {
    _timer?.cancel();
    _events.close();
  }

  /// Runs one scheduling pass (public for tests).
  Future<void> tick() async {
    final DateTime now = DateTime.now();

    // Auto-stop recordings that have reached their end.
    for (final MapEntry<int, ({String recordingId, DateTime endAt})> e
        in _activeRecordings.entries.toList()) {
      if (!e.value.endAt.isAfter(now)) {
        await _ref
            .read(recordingControllerProvider.notifier)
            .stop(e.value.recordingId);
        _activeRecordings.remove(e.key);
      }
    }

    final ScheduleRepository repo = _ref.read(scheduleRepositoryProvider);
    for (final ScheduledTask task in await repo.due(now)) {
      await _fire(task, now, repo);
    }
  }

  Future<void> _fire(
      ScheduledTask task, DateTime now, ScheduleRepository repo) async {
    try {
      switch (task.kind) {
        case ScheduledKind.record:
          await _fireRecord(task, now);
        case ScheduledKind.reminder:
          _events.add(task);
        case ScheduledKind.zap:
          if (task.channelUrl != null && task.channelUrl!.isNotEmpty) {
            await _ref.read(playbackEngineProvider).open(PlayRequest(
                  url: task.channelUrl!,
                  title: task.channelName ?? task.title ?? '',
                  isLiveHint: true,
                ));
          }
        case ScheduledKind.sleepTimer:
          await _ref.read(playbackEngineProvider).stop();
      }
    } catch (e) {
      log.w('Scheduled task ${task.id} (${task.kind.id}) failed: $e');
    }

    final DateTime? next = task.nextOccurrenceAfter(now);
    if (next != null) {
      await repo.update(task.copyWith(fireAt: next));
    } else if (task.id != null) {
      await repo.delete(task.id!);
    }
  }

  Future<void> _fireRecord(ScheduledTask task, DateTime now) async {
    final String url = task.channelUrl ?? '';
    if (url.isEmpty) return;
    final Channel channel = Channel(
      id: task.channelId ?? '',
      name: task.channelName ?? task.title ?? 'Recording',
      url: url,
      // So session-based sources (Stalker) can still resolve at fire time.
      props: <String, String>{'cmd': url},
    );
    final String? recId = await _ref
        .read(recordingControllerProvider.notifier)
        .recordChannel(channel, task.sourceId, title: task.title);
    if (recId != null && task.endAt != null && task.id != null) {
      _activeRecordings[task.id!] =
          (recordingId: recId, endAt: task.endAt!);
    }
  }
}

final schedulerProvider = Provider<SchedulerService>((ref) {
  final SchedulerService service = SchedulerService(ref)..start();
  ref.onDispose(service.dispose);
  return service;
});

/// Reminder/zap events fired by the scheduler, for the UI to show.
final schedulerEventsProvider = StreamProvider<ScheduledTask>((ref) {
  return ref.watch(schedulerProvider).events;
});
