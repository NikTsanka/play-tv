import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:streamhub/domain/channels/channel.dart';
import 'package:streamhub/domain/providers/provider.dart';
import 'package:streamhub/domain/providers/provider_config.dart';
import 'package:streamhub/domain/providers/provider_type.dart';
import 'package:streamhub/domain/providers/sources/stalker/stalker_client.dart';
import 'package:streamhub/domain/providers/sources/stalker/stalker_provider.dart';

Map<String, dynamic> _channel(String id, String genre) => <String, dynamic>{
      'id': id,
      'name': 'Channel $id',
      'number': id,
      'cmd': 'ffmpeg http://localhost/ch/${id}_',
      'logo': 'http://logo/$id.png',
      'tv_genre_id': genre,
      'xmltv_id': 'chan$id',
    };

/// MockClient emulating a Stalker portal (responses wrapped in `js`).
MockClient _portal() {
  return MockClient((http.Request req) async {
    final Map<String, String> q = req.url.queryParameters;
    http.Response js(Object body) =>
        http.Response(jsonEncode(<String, dynamic>{'js': body}), 200);

    switch (q['action']) {
      case 'handshake':
        return js(<String, dynamic>{'token': 'TOK123', 'random': 'r'});
      case 'get_profile':
        return js(<String, dynamic>{'id': 1, 'name': 'profile'});
      case 'get_genres':
        return js(<dynamic>[
          <String, dynamic>{'id': '1', 'title': 'News'},
        ]);
      case 'get_ordered_list':
        final int page = int.tryParse(q['p'] ?? '1') ?? 1;
        if (page == 1) {
          return js(<String, dynamic>{
            'total_items': 3,
            'max_page_items': 2,
            'data': <dynamic>[_channel('1', '1'), _channel('2', '1')],
          });
        }
        return js(<String, dynamic>{
          'total_items': 3,
          'max_page_items': 2,
          'data': <dynamic>[_channel('3', '1')],
        });
      case 'create_link':
        return js(<String, dynamic>{
          'id': 0,
          'cmd': 'ffmpeg http://real.cdn/stream/12345?token=abc',
        });
      default:
        return js(<dynamic>[]);
    }
  });
}

void main() {
  group('StalkerClient.stripCmdPrefix', () {
    test('strips ffmpeg / auto / numeric prefixes', () {
      expect(StalkerClient.stripCmdPrefix('ffmpeg http://x/y'), 'http://x/y');
      expect(StalkerClient.stripCmdPrefix('auto http://x/y'), 'http://x/y');
      expect(StalkerClient.stripCmdPrefix('12345 http://x/y'), 'http://x/y');
      expect(StalkerClient.stripCmdPrefix('http://x/y'), 'http://x/y');
    });
  });

  group('StalkerClient over MockClient', () {
    test('handshake stores the token', () async {
      final client = StalkerClient(
          portalUrl: 'http://host/c/', mac: '00:1A:79:00:00:01', client: _portal());
      await client.handshake();
      expect(client.token, 'TOK123');
    });

    test('genres parse from js list', () async {
      final client = StalkerClient(
          portalUrl: 'http://host/c/', mac: 'm', client: _portal());
      final genres = await client.genres();
      expect(genres.single.title, 'News');
    });

    test('allChannels follows pagination via total/max', () async {
      final client = StalkerClient(
          portalUrl: 'http://host/c/', mac: 'm', client: _portal());
      final channels = await client.allChannels();
      expect(channels.length, 3);
      expect(channels.map((c) => c.id), <String>['1', '2', '3']);
    });

    test('createLink resolves and strips the engine prefix', () async {
      final client = StalkerClient(
          portalUrl: 'http://host/c/', mac: 'm', client: _portal());
      final url = await client.createLink('ffmpeg http://localhost/ch/1_');
      expect(url, 'http://real.cdn/stream/12345?token=abc');
    });
  });

  group('StalkerProvider', () {
    test('builds channels with genre group and stores cmd', () async {
      final provider = StalkerProvider(
        ProviderConfig(
          type: ProviderType.stalker,
          caption: 'Portal',
          location: 'http://host/c/',
          settings: <String, String>{'mac': '00:1A:79:00:00:01'},
        ),
        httpClient: _portal(),
      );
      final sink = CollectingChannelSink();
      await provider.fetchChannelList(sink, CancelToken());

      expect(sink.channels.length, 3);
      final Channel first = sink.channels.first;
      expect(first.id, 'stalker:1');
      expect(first.group, 'News');
      expect(first.epgId, 'chan1');
      expect(first.props['cmd'], 'ffmpeg http://localhost/ch/1_');
    });

    test('resolveStreamUrl mints a fresh URL via create_link', () async {
      final provider = StalkerProvider(
        ProviderConfig(
          type: ProviderType.stalker,
          caption: 'Portal',
          location: 'http://host/c/',
          settings: <String, String>{'mac': 'm'},
        ),
        httpClient: _portal(),
      );
      final resolved = await provider.resolveStreamUrl(const Channel(
        id: 'stalker:1',
        name: 'n',
        url: 'ffmpeg http://localhost/ch/1_',
        props: <String, String>{'cmd': 'ffmpeg http://localhost/ch/1_'},
      ));
      expect(resolved, 'http://real.cdn/stream/12345?token=abc');
    });
  });
}
