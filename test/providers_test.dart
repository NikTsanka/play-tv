import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamhub/domain/channels/storage/channel_repository.dart';
import 'package:streamhub/domain/channels/storage/database.dart';
import 'package:streamhub/domain/providers/provider.dart';
import 'package:streamhub/domain/providers/provider_config.dart';
import 'package:streamhub/domain/providers/provider_type.dart';
import 'package:streamhub/domain/providers/providers_manager.dart';
import 'package:streamhub/domain/providers/sources/generic_url_provider.dart';
import 'package:streamhub/domain/providers/sources/iptv_org_provider.dart';
import 'package:streamhub/domain/providers/sources/m3u_provider.dart';

void main() {
  group('ProviderConfig', () {
    test('settings + update interval round-trip through JSON', () {
      final config = ProviderConfig(
        type: ProviderType.iptvOrg,
        caption: 'Catalog',
        settings: <String, String>{'scope': 'country', 'code': 'us'},
        updateInterval: const Duration(hours: 12),
      );
      final decoded = ProviderConfig.decodeSettings(config.encodeSettings());
      expect(decoded.settings, <String, String>{'scope': 'country', 'code': 'us'});
      expect(decoded.updateInterval, const Duration(hours: 12));
    });

    test('tolerates legacy empty settings blob', () {
      final decoded = ProviderConfig.decodeSettings('{}');
      expect(decoded.settings, isEmpty);
      expect(decoded.updateInterval, const Duration(hours: 6));
    });

    test('legacy kind ids map to the right type', () {
      expect(ProviderTypeId.fromId('m3u_url'), ProviderType.m3uUrl);
      expect(ProviderTypeId.fromId('m3u_file'), ProviderType.m3uFile);
      expect(ProviderTypeId.fromId('iptvOrg'), ProviderType.iptvOrg);
    });
  });

  group('ProviderRegistry', () {
    final registry = ProviderRegistry();

    test('covers every wired type', () {
      expect(registry.all.length, ProviderType.values.length);
    });

    test('builds a matching runtime provider per type', () {
      for (final type in ProviderType.values) {
        final provider = registry.build(
            ProviderConfig(type: type, caption: 'x', location: 'http://h/p.m3u'));
        expect(provider.type, type);
      }
    });
  });

  group('GenericUrlProvider', () {
    test('emits a single channel, honouring the radio flag', () async {
      final provider = GenericUrlProvider(ProviderConfig(
        type: ProviderType.genericUrl,
        caption: 'My radio',
        location: 'http://host/stream.aac',
        settings: <String, String>{'isRadio': 'true'},
      ));
      final sink = CollectingChannelSink();
      await provider.fetchChannelList(sink, CancelToken());

      expect(sink.channels.length, 1);
      expect(sink.channels.single.name, 'My radio');
      expect(sink.channels.single.isRadio, isTrue);
      expect(provider.availableFunctions, contains(ProviderFunction.radio));
    });

    test('throws on an empty url', () {
      final provider = GenericUrlProvider(ProviderConfig(
          type: ProviderType.genericUrl, caption: 'x', location: '   '));
      expect(provider.fetchChannelList(CollectingChannelSink(), CancelToken()),
          throwsException);
    });
  });

  group('IptvOrgProvider', () {
    test('derives the public M3U url from scope + code', () {
      ProviderConfig cfg(Map<String, String> s) =>
          ProviderConfig(type: ProviderType.iptvOrg, caption: 'c', settings: s);

      expect(IptvOrgProvider(cfg(<String, String>{})).playlistUrl,
          'https://iptv-org.github.io/iptv/index.m3u');
      expect(
          IptvOrgProvider(cfg(<String, String>{'scope': 'country', 'code': 'UK'}))
              .playlistUrl,
          'https://iptv-org.github.io/iptv/countries/uk.m3u');
      expect(
          IptvOrgProvider(
                  cfg(<String, String>{'scope': 'category', 'code': 'news'}))
              .playlistUrl,
          'https://iptv-org.github.io/iptv/categories/news.m3u');
    });
  });

  group('CancelToken', () {
    test('throwIfCancelled raises once cancelled', () {
      final ct = CancelToken();
      expect(ct.isCancelled, isFalse);
      ct.throwIfCancelled();
      ct.cancel();
      expect(ct.isCancelled, isTrue);
      expect(ct.throwIfCancelled, throwsA(isA<ProviderCancelled>()));
    });
  });

  group('ProvidersManager', () {
    late AppDatabase db;
    late ProvidersManager manager;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      manager = ProvidersManager(ChannelRepository(db), ProviderRegistry());
    });

    tearDown(() async => db.close());

    test('imports a generic stream and persists one channel', () async {
      final id = await manager.import(ProviderConfig(
        type: ProviderType.genericUrl,
        caption: 'Single',
        location: 'http://host/live.m3u8',
      ));
      final channels = await manager.channelsOf(id);
      expect(channels.length, 1);
      expect(channels.single.url, 'http://host/live.m3u8');

      final configs = await manager.list();
      expect(configs.single.caption, 'Single');
      expect(configs.single.type, ProviderType.genericUrl);
    });

    test('imports an M3U file, persists channels and stores the EPG url',
        () async {
      final file = File(
          '${Directory.systemTemp.path}/streamhub_test_${DateTime.now().microsecondsSinceEpoch}.m3u');
      await file.writeAsString('''
#EXTM3U url-tvg="http://epg.example/guide.xml"
#EXTINF:-1 tvg-id="one" group-title="A",Channel One
http://host/one.m3u8
#EXTINF:-1 tvg-id="two" group-title="A",Channel Two
http://host/two.m3u8
''');
      addTearDown(() async {
        if (file.existsSync()) await file.delete();
      });

      final id = await manager.import(ProviderConfig(
        type: ProviderType.m3uFile,
        caption: 'From file',
        location: file.path,
      ));

      final channels = await manager.channelsOf(id);
      expect(channels.length, 2);
      expect(channels.map((c) => c.name),
          containsAll(<String>['Channel One', 'Channel Two']));

      final config = await ChannelRepository(db).providerConfig(id);
      expect(config?.epgUrl, 'http://epg.example/guide.xml');
    });

    test('re-import refreshes channels in place without orphaning the source',
        () async {
      final config = ProviderConfig(
        type: ProviderType.genericUrl,
        caption: 'Refreshable',
        location: 'http://host/a.m3u8',
      );
      final id = await manager.import(config);
      // Same id, new location → channels replaced, no duplicate source row.
      await manager.import(config.copyWith(id: id, location: 'http://host/b.m3u8'));

      final channels = await manager.channelsOf(id);
      expect(channels.single.url, 'http://host/b.m3u8');
      expect((await manager.list()).length, 1);
    });

    test('a cancelled token aborts the import', () async {
      final ct = CancelToken()..cancel();
      await expectLater(
        manager.import(
          ProviderConfig(
            type: ProviderType.genericUrl,
            caption: 'x',
            location: 'http://host/s.m3u8',
          ),
          cancelToken: ct,
        ),
        throwsA(isA<ProviderCancelled>()),
      );
    });
  });

  test('downloadBytes is exported for reuse', () {
    // Compile-time guard that the shared helper stays public.
    expect(downloadBytes, isA<Function>());
  });
}
