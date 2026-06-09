import 'package:drift/drift.dart';

import '../../channels/storage/database.dart' as db;
import '../schedule.dart';

/// Persists [ScheduledTask]s (spec §10). Times are stored as UTC unix millis.
class ScheduleRepository {
  ScheduleRepository(this._db);

  final db.AppDatabase _db;

  Stream<List<ScheduledTask>> watch() =>
      _db.watchScheduledTasks().map((rows) => rows.map(_toDomain).toList());

  Future<List<ScheduledTask>> all() async =>
      (await _db.allScheduledTasks()).map(_toDomain).toList();

  /// Enabled tasks due at or before [now].
  Future<List<ScheduledTask>> due(DateTime now) async {
    final rows =
        await _db.dueScheduledTasks(now.toUtc().millisecondsSinceEpoch);
    return rows.map(_toDomain).toList();
  }

  Future<int> add(ScheduledTask task) =>
      _db.insertScheduledTask(_toCompanion(task));

  Future<void> update(ScheduledTask task) =>
      _db.updateScheduledTask(task.id!, _toCompanion(task));

  Future<void> delete(int id) => _db.deleteScheduledTask(id);

  // ---- mapping ----------------------------------------------------------

  ScheduledTask _toDomain(db.ScheduledTask r) => ScheduledTask(
        id: r.id,
        kind: ScheduledKindId.fromId(r.kind),
        fireAt: DateTime.fromMillisecondsSinceEpoch(r.fireAtUtc, isUtc: true),
        endAt: r.endAtUtc == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(r.endAtUtc!, isUtc: true),
        recurrence: RecurrenceId.fromId(r.recurrence),
        sourceId: r.sourceId,
        channelId: r.channelId,
        channelName: r.channelName,
        channelUrl: r.channelUrl,
        title: r.title,
        enabled: r.enabled,
      );

  db.ScheduledTasksCompanion _toCompanion(ScheduledTask t) =>
      db.ScheduledTasksCompanion.insert(
        kind: t.kind.id,
        fireAtUtc: t.fireAt.toUtc().millisecondsSinceEpoch,
        endAtUtc: Value(t.endAt?.toUtc().millisecondsSinceEpoch),
        recurrence: Value(t.recurrence.id),
        sourceId: Value(t.sourceId),
        channelId: Value(t.channelId),
        channelName: Value(t.channelName),
        channelUrl: Value(t.channelUrl),
        title: Value(t.title),
        enabled: Value(t.enabled),
      );
}
