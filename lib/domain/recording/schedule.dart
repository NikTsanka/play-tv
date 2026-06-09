import 'package:flutter/foundation.dart';

/// What a scheduled task does when it fires (spec §10 scheduler).
enum ScheduledKind { record, reminder, zap, sleepTimer }

extension ScheduledKindId on ScheduledKind {
  String get id => name;
  static ScheduledKind fromId(String? id) => ScheduledKind.values.firstWhere(
        (k) => k.name == id,
        orElse: () => ScheduledKind.reminder,
      );
}

/// How a task repeats.
enum Recurrence { once, daily, weekly }

extension RecurrenceId on Recurrence {
  String get id => name;
  static Recurrence fromId(String? id) => Recurrence.values.firstWhere(
        (r) => r.name == id,
        orElse: () => Recurrence.once,
      );
}

/// A scheduled action: record a programme, remind, switch channel, or sleep.
@immutable
class ScheduledTask {
  const ScheduledTask({
    this.id,
    required this.kind,
    required this.fireAt,
    this.endAt,
    this.recurrence = Recurrence.once,
    this.sourceId,
    this.channelId,
    this.channelName,
    this.channelUrl,
    this.title,
    this.enabled = true,
  });

  final int? id;
  final ScheduledKind kind;
  final DateTime fireAt;

  /// For records: when to stop. Null = open-ended (manual stop).
  final DateTime? endAt;
  final Recurrence recurrence;

  final int? sourceId;
  final String? channelId;
  final String? channelName;
  final String? channelUrl;

  /// EPG programme title (records) or reminder message.
  final String? title;
  final bool enabled;

  /// Recording duration when both ends are known.
  Duration? get duration => endAt?.difference(fireAt).abs();

  bool isDue(DateTime now) => enabled && !fireAt.isAfter(now);

  /// The next fire time strictly after [after] for a recurring task, or null
  /// for a one-shot (which should be removed once fired).
  DateTime? nextOccurrenceAfter(DateTime after) =>
      nextFire(fireAt, recurrence, after);

  ScheduledTask copyWith({
    int? id,
    DateTime? fireAt,
    DateTime? endAt,
    bool? enabled,
  }) =>
      ScheduledTask(
        id: id ?? this.id,
        kind: kind,
        fireAt: fireAt ?? this.fireAt,
        endAt: endAt ?? this.endAt,
        recurrence: recurrence,
        sourceId: sourceId,
        channelId: channelId,
        channelName: channelName,
        channelUrl: channelUrl,
        title: title,
        enabled: enabled ?? this.enabled,
      );
}

/// Pure next-fire computation: advances [base] by the recurrence step until it
/// is strictly after [after]. Returns null for [Recurrence.once].
DateTime? nextFire(DateTime base, Recurrence recurrence, DateTime after) {
  switch (recurrence) {
    case Recurrence.once:
      return null;
    case Recurrence.daily:
      return _advance(base, const Duration(days: 1), after);
    case Recurrence.weekly:
      return _advance(base, const Duration(days: 7), after);
  }
}

DateTime _advance(DateTime base, Duration step, DateTime after) {
  DateTime next = base;
  // If base is already in the future relative to `after`, keep it.
  if (next.isAfter(after)) return next;
  final int steps = (after.difference(next).inMicroseconds ~/ step.inMicroseconds) + 1;
  next = next.add(step * steps);
  // Guard against rounding leaving it non-strictly-after.
  while (!next.isAfter(after)) {
    next = next.add(step);
  }
  return next;
}
