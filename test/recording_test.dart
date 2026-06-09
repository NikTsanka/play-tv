import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:streamhub/domain/channels/storage/database.dart'
    hide ScheduledTask;
import 'package:streamhub/domain/recording/filename_template.dart';
import 'package:streamhub/domain/recording/recorder.dart';
import 'package:streamhub/domain/recording/schedule.dart';
import 'package:streamhub/domain/recording/storage/schedule_repository.dart';
import 'package:streamhub/domain/recording/timeshift_buffer.dart';

void main() {
  group('FilenameTemplate', () {
    final DateTime when = DateTime(2024, 3, 7, 21, 5, 9);

    test('expands the standard pattern', () {
      final String name = FilenameTemplate.standard().build(
        channel: 'BBC One',
        title: 'News at Ten',
        when: when,
      );
      expect(name, 'BBC One - News at Ten - 2024-03-07 21-05-09.ts');
    });

    test('expands individual tokens (case-insensitive)', () {
      final String name = const FilenameTemplate('{YEAR}_{month}_{day}_{HOUR}{minute}')
          .build(channel: 'c', when: when, ext: 'mp4');
      expect(name, '2024_03_07_2105.mp4');
    });

    test('drops unknown tokens and empty title', () {
      final String name = const FilenameTemplate('{channel}{title}{bogus}')
          .build(channel: 'X', when: when);
      expect(name, 'X.ts');
    });

    test('sanitizes filesystem-illegal characters', () {
      final String name = const FilenameTemplate('{channel} {title}').build(
        channel: 'A/B:C',
        title: 'x?<>|y',
        when: when,
      );
      expect(name, 'A_B_C x_y.ts');
    });

    test('falls back to a non-empty base', () {
      final String name =
          const FilenameTemplate('{bogus}').build(channel: '', when: when);
      expect(name, 'recording.ts');
    });
  });

  group('nextFire', () {
    final DateTime base = DateTime(2024, 1, 1, 20);

    test('once never repeats', () {
      expect(nextFire(base, Recurrence.once, base.add(const Duration(days: 5))),
          isNull);
    });

    test('daily advances to the next strictly-future slot', () {
      final DateTime after = DateTime(2024, 1, 3, 20, 0, 1);
      final DateTime? next = nextFire(base, Recurrence.daily, after);
      expect(next, DateTime(2024, 1, 4, 20));
    });

    test('weekly steps by 7 days', () {
      final DateTime after = DateTime(2024, 1, 8, 20);
      final DateTime? next = nextFire(base, Recurrence.weekly, after);
      expect(next, DateTime(2024, 1, 15, 20));
    });

    test('keeps a future base unchanged', () {
      final DateTime after = DateTime(2023, 12, 31);
      expect(nextFire(base, Recurrence.daily, after), base);
    });
  });

  group('TimeshiftBuffer', () {
    test('stores up to capacity and reports counters', () {
      final buf = TimeshiftBuffer(capacityBytes: 4);
      buf.write(<int>[1, 2, 3]);
      expect(buf.length, 3);
      expect(buf.snapshot(), <int>[1, 2, 3]);
      expect(buf.isFull, isFalse);
    });

    test('overwrites oldest bytes once full (ring)', () {
      final buf = TimeshiftBuffer(capacityBytes: 4);
      buf.write(<int>[1, 2, 3, 4, 5, 6]);
      expect(buf.isFull, isTrue);
      expect(buf.length, 4);
      expect(buf.totalWritten, 6);
      expect(buf.snapshot(), <int>[3, 4, 5, 6]);
    });

    test('readLast clamps to available', () {
      final buf = TimeshiftBuffer(capacityBytes: 8);
      buf.write(<int>[1, 2, 3]);
      expect(buf.readLast(2), <int>[2, 3]);
      expect(buf.readLast(10), <int>[1, 2, 3]);
    });
  });

  group('HttpStreamRecorder', () {
    test('dumps the response body to the target file', () async {
      final File file = File(
          '${Directory.systemTemp.path}/rec_${DateTime.now().microsecondsSinceEpoch}.ts');
      addTearDown(() async {
        if (file.existsSync()) await file.delete();
      });

      final Uint8List payload = Uint8List.fromList(List<int>.generate(2048, (i) => i % 256));
      final MockClient client =
          MockClient((_) async => http.Response.bytes(payload, 200));

      final HttpStreamRecorder recorder = HttpStreamRecorder(
        id: 'r1',
        url: 'http://host/live.ts',
        filePath: file.path,
        title: 'Test',
        client: client,
      );
      await recorder.start();
      await recorder.done;

      expect(recorder.status.state, RecordingState.stopped);
      expect(recorder.status.bytes, payload.length);
      expect(await file.readAsBytes(), payload);
    });

    test('reports an error on a non-200 response', () async {
      final MockClient client =
          MockClient((_) async => http.Response('nope', 403));
      final HttpStreamRecorder recorder = HttpStreamRecorder(
        id: 'r2',
        url: 'http://host/x',
        filePath: '${Directory.systemTemp.path}/should_not_exist.ts',
        title: 'Test',
        client: client,
      );
      await recorder.start();
      await recorder.done;
      expect(recorder.status.state, RecordingState.error);
    });
  });

  group('ScheduleRepository', () {
    late AppDatabase db;
    late ScheduleRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = ScheduleRepository(db);
    });
    tearDown(() async => db.close());

    test('adds, lists and deletes tasks', () async {
      final int id = await repo.add(ScheduledTask(
        kind: ScheduledKind.record,
        fireAt: DateTime(2024, 5, 1, 20),
        endAt: DateTime(2024, 5, 1, 21),
        channelName: 'BBC',
        channelUrl: 'http://h/s.ts',
        title: 'Film',
      ));
      final List<ScheduledTask> all = await repo.all();
      expect(all.single.title, 'Film');
      expect(all.single.duration, const Duration(hours: 1));

      await repo.delete(id);
      expect(await repo.all(), isEmpty);
    });

    test('due() returns only enabled, past-fire tasks', () async {
      final DateTime now = DateTime.now();
      await repo.add(ScheduledTask(
        kind: ScheduledKind.reminder,
        fireAt: now.subtract(const Duration(minutes: 1)),
        title: 'past',
      ));
      await repo.add(ScheduledTask(
        kind: ScheduledKind.reminder,
        fireAt: now.add(const Duration(hours: 1)),
        title: 'future',
      ));
      await repo.add(ScheduledTask(
        kind: ScheduledKind.reminder,
        fireAt: now.subtract(const Duration(minutes: 1)),
        title: 'disabled',
        enabled: false,
      ));

      final List<ScheduledTask> due = await repo.due(now);
      expect(due.map((t) => t.title), <String>['past']);
    });

    test('round-trips times as UTC', () async {
      final DateTime fire = DateTime.utc(2024, 6, 1, 12, 30);
      await repo.add(ScheduledTask(kind: ScheduledKind.zap, fireAt: fire));
      final ScheduledTask t = (await repo.all()).single;
      expect(t.fireAt.toUtc(), fire);
    });
  });
}
