import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:streamhub/domain/logos/logo_matcher.dart';
import 'package:streamhub/domain/logos/logo_service.dart';
import 'package:streamhub/domain/tasks/download.dart';
import 'package:streamhub/domain/tasks/task_manager.dart';
import 'package:streamhub/domain/update/update_service.dart';

void main() {
  group('TaskManager', () {
    late TaskManager manager;
    setUp(() => manager = TaskManager());
    tearDown(() => manager.dispose());

    test('runs to completion and reports progress', () async {
      final TaskHandle<int> handle = manager.run<int>(
        label: 'compute',
        action: (TaskController ctrl) async {
          ctrl.report(0.5, 'half');
          return 42;
        },
      );
      expect(await handle.result, 42);
      final TaskProgress t = manager.tasks.single;
      expect(t.status, TaskStatus.completed);
      expect(t.progress, 1.0);
    });

    test('cancel aborts the task', () async {
      final Completer<void> gate = Completer<void>();
      final TaskHandle<int> handle = manager.run<int>(
        label: 'cancellable',
        action: (TaskController ctrl) async {
          await gate.future;
          ctrl.throwIfCancelled();
          return 1;
        },
      );
      manager.cancel(handle.id);
      gate.complete();
      await expectLater(handle.result, throwsA(isA<TaskCancelled>()));
      expect(manager.tasks.single.status, TaskStatus.cancelled);
    });

    test('captures failures', () async {
      final TaskHandle<void> handle = manager.run<void>(
        label: 'boom',
        action: (_) async => throw StateError('nope'),
      );
      await expectLater(handle.result, throwsA(isA<StateError>()));
      final TaskProgress t = manager.tasks.single;
      expect(t.status, TaskStatus.failed);
      expect(t.error, contains('nope'));
    });

    test('clearFinished drops done tasks', () async {
      await manager.run<int>(label: 'a', action: (_) async => 1).result;
      expect(manager.tasks, isNotEmpty);
      manager.clearFinished();
      expect(manager.tasks, isEmpty);
    });
  });

  group('downloadToFile', () {
    test('streams bytes to a file and reports completion', () async {
      final File file = File(
          '${Directory.systemTemp.path}/dl_${DateTime.now().microsecondsSinceEpoch}.bin');
      addTearDown(() async {
        if (file.existsSync()) await file.delete();
      });

      final Uint8List payload =
          Uint8List.fromList(List<int>.generate(1500, (int i) => i % 256));
      final MockClient client =
          MockClient((_) async => http.Response.bytes(payload, 200));

      final List<double?> reports = <double?>[];
      final TaskController ctrl =
          TaskController((double? p, String? _) => reports.add(p));

      await downloadToFile(
          url: 'http://h/f.bin', file: file, controller: ctrl, client: client);

      expect(await file.readAsBytes(), payload);
      expect(reports.last, 1.0);
    });

    test('throws on non-200', () async {
      final MockClient client =
          MockClient((_) async => http.Response('no', 404));
      final TaskController ctrl = TaskController((_, __) {});
      expect(
        downloadToFile(
          url: 'http://h/x',
          file: File('${Directory.systemTemp.path}/nope.bin'),
          controller: ctrl,
          client: client,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('LogoMatcher', () {
    const LogoMatcher matcher = LogoMatcher();

    test('normalizes names (strips quality tags / punctuation)', () {
      expect(LogoMatcher.normalize('BBC One HD'), 'bbc one');
      expect(LogoMatcher.normalize('CNN-International (4K)'), 'cnn international');
    });

    test('finds the best fuzzy match above threshold', () {
      final Map<String, String> candidates = <String, String>{
        'bbc_one': 'bbc one',
        'cnn': 'cnn',
        'discovery': 'discovery',
      };
      expect(matcher.bestMatch('BBC One HD', candidates), 'bbc_one');
      expect(matcher.bestMatch('CNN International', candidates), 'cnn');
    });

    test('returns null when nothing clears the threshold', () {
      expect(
        matcher.bestMatch('Totally Unknown Channel',
            <String, String>{'bbc_one': 'bbc one'}),
        isNull,
      );
    });

    test('identical names score 1.0', () {
      expect(matcher.score('Foo TV', 'foo tv'), 1.0);
    });

    test('LogoService.keyFor builds a stable cache key', () {
      expect(LogoService.keyFor('BBC One HD'), 'bbc_one');
    });
  });

  group('version comparison', () {
    test('orders dotted versions numerically', () {
      expect(compareVersions('1.2.0', '1.10.0'), lessThan(0));
      expect(compareVersions('2.0.0', '1.9.9'), greaterThan(0));
      expect(compareVersions('1.2.0', '1.2.0'), 0);
    });

    test('ignores build and pre-release suffixes', () {
      expect(compareVersions('1.0.0+5', '1.0.0'), 0);
      expect(compareVersions('1.2.0-beta', '1.1.0'), greaterThan(0));
    });

    test('isNewerVersion is strict', () {
      expect(isNewerVersion('0.1.0', '0.2.0'), isTrue);
      expect(isNewerVersion('1.0.0', '1.0.0'), isFalse);
      expect(isNewerVersion('1.0.0', '0.9.0'), isFalse);
    });
  });

  group('UpdateService', () {
    UpdateService service(String body) => UpdateService(
          manifestUrl: 'http://h/update.json',
          client: MockClient((_) async => http.Response(body, 200)),
        );

    test('reports an available update', () async {
      final UpdateInfo info = await service(
              '{"version":"0.2.0","changelog":"New","url":"http://d"}')
          .check(current: '0.1.0');
      expect(info.available, isTrue);
      expect(info.latest, '0.2.0');
      expect(info.changelog, 'New');
    });

    test('reports up to date', () async {
      final UpdateInfo info =
          await service('{"version":"0.1.0"}').check(current: '0.1.0');
      expect(info.available, isFalse);
    });

    test('throws on a non-200 manifest', () async {
      final UpdateService s = UpdateService(
        manifestUrl: 'http://h/u',
        client: MockClient((_) async => http.Response('x', 500)),
      );
      expect(s.check(current: '0.1.0'), throwsA(isA<Exception>()));
    });
  });
}
