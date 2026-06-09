import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:streamhub/domain/channels/channel.dart';
import 'package:streamhub/domain/providers/provider.dart';
import 'package:streamhub/domain/providers/provider_config.dart';
import 'package:streamhub/domain/providers/provider_type.dart';
import 'package:streamhub/domain/providers/sources/xtream/xtream_client.dart';
import 'package:streamhub/domain/providers/sources/xtream/xtream_models.dart';
import 'package:streamhub/domain/providers/sources/xtream/xtream_provider.dart';

String _b64(String s) => base64.encode(utf8.encode(s));

/// MockClient routing by the `action` query parameter (login = no action).
MockClient _panel() {
  return MockClient((http.Request req) async {
    final String? action = req.url.queryParameters['action'];
    switch (action) {
      case null:
        return http.Response(
          jsonEncode(<String, dynamic>{
            'user_info': <String, dynamic>{
              'auth': 1,
              'status': 'Active',
              'exp_date': '1735689600',
              'max_connections': '2',
              'allowed_output_formats': <String>['m3u8', 'ts'],
            },
            'server_info': <String, dynamic>{
              'url': 'cdn.example.com',
              'port': '8080',
              'server_protocol': 'http',
            },
          }),
          200,
        );
      case 'get_live_categories':
        return http.Response(
          jsonEncode(<dynamic>[
            <String, dynamic>{'category_id': '10', 'category_name': 'News'},
          ]),
          200,
        );
      case 'get_live_streams':
        return http.Response(
          jsonEncode(<dynamic>[
            <String, dynamic>{
              'num': 1,
              'name': 'BBC One HD',
              'stream_id': 123,
              'stream_icon': 'http://logo/bbc.png',
              'epg_channel_id': 'bbc1.uk',
              'category_id': '10',
              'tv_archive': 1,
              'tv_archive_duration': 7,
            },
          ]),
          200,
        );
      case 'get_short_epg':
        return http.Response(
          jsonEncode(<String, dynamic>{
            'epg_listings': <dynamic>[
              <String, dynamic>{
                'title': _b64('News at Ten'),
                'description': _b64('Headlines'),
                'start_timestamp': '1704139200',
                'stop_timestamp': '1704142800',
              },
            ],
          }),
          200,
        );
      default:
        return http.Response('[]', 200);
    }
  });
}

void main() {
  group('XtreamAccount', () {
    test('parses auth, status, server info', () {
      final account = XtreamAccount.fromJson(<String, dynamic>{
        'user_info': <String, dynamic>{
          'auth': 1,
          'status': 'Active',
          'max_connections': '3',
        },
        'server_info': <String, dynamic>{
          'url': 'h',
          'port': '80',
          'server_protocol': 'https',
        },
      });
      expect(account.isActive, isTrue);
      expect(account.maxConnections, 3);
      expect(account.serverProtocol, 'https');
    });
  });

  group('XtreamEpgListing', () {
    test('decodes Base64 title/description and timestamps', () {
      final listing = XtreamEpgListing.fromJson(<String, dynamic>{
        'title': _b64('Movie'),
        'description': _b64('Plot'),
        'start_timestamp': '1704139200',
        'stop_timestamp': '1704142800',
      });
      expect(listing.title, 'Movie');
      expect(listing.description, 'Plot');
      expect(listing.start, DateTime.utc(2024, 1, 1, 20));
    });
  });

  group('XtreamClient URL builders', () {
    final client = XtreamClient(
        baseUrl: 'http://example.com:8080/', username: 'u', password: 'p');

    test('strips trailing slash and builds api/xmltv urls', () {
      expect(client.baseUrl, 'http://example.com:8080');
      expect(client.xmltvUrl(),
          'http://example.com:8080/xmltv.php?username=u&password=p');
    });

    test('live url uses base when no server_info loaded', () {
      expect(client.liveUrl(123), 'http://example.com:8080/live/u/p/123.ts');
    });

    test('vod and series urls use container extension', () {
      expect(client.vodUrl(999, 'mkv'), 'http://example.com:8080/movie/u/p/999.mkv');
      expect(client.seriesEpisodeUrl('1001', 'mp4'),
          'http://example.com:8080/series/u/p/1001.mp4');
    });

    test('timeshift url follows the path form', () {
      expect(
        client.timeshiftUrl(
          streamId: 123,
          startUtc: DateTime.utc(2024, 1, 2, 20, 30),
          durationMinutes: 60,
        ),
        'http://example.com:8080/timeshift/u/p/60/2024-01-02:20-30/123.ts',
      );
    });
  });

  group('XtreamClient over MockClient', () {
    test('login prefers server_info host for stream urls', () async {
      final client = XtreamClient(
        baseUrl: 'http://example.com:8080',
        username: 'u',
        password: 'p',
        client: _panel(),
      );
      await client.login();
      expect(client.streamBase, 'http://cdn.example.com:8080');
      expect(client.liveUrl(123), 'http://cdn.example.com:8080/live/u/p/123.ts');
    });

    test('rejects an inactive account', () async {
      final client = XtreamClient(
        baseUrl: 'http://x',
        username: 'u',
        password: 'p',
        client: MockClient((_) async => http.Response(
            jsonEncode(<String, dynamic>{
              'user_info': <String, dynamic>{'auth': 0, 'status': 'Disabled'}
            }),
            200)),
      );
      expect(client.login(), throwsA(isA<XtreamException>()));
    });
  });

  group('XtreamProvider', () {
    test('builds live channels with group, catch-up and EPG url', () async {
      final provider = XtreamProvider(
        ProviderConfig(
          type: ProviderType.xtream,
          caption: 'Panel',
          location: 'http://example.com:8080',
          settings: <String, String>{'username': 'u', 'password': 'p'},
        ),
        httpClient: _panel(),
      );
      final sink = CollectingChannelSink();
      await provider.fetchChannelList(sink, CancelToken());

      expect(sink.channels.length, 1);
      final Channel ch = sink.channels.single;
      expect(ch.id, 'xt:123');
      expect(ch.url, 'http://cdn.example.com:8080/live/u/p/123.ts');
      expect(ch.group, 'News');
      expect(ch.epgId, 'bbc1.uk');
      expect(ch.catchup.type, CatchupType.xc);
      expect(ch.catchup.days, 7);
      expect(sink.epgUrlValue,
          'http://example.com:8080/xmltv.php?username=u&password=p');
    });

    test('live channels resolve to their static URL (no per-zap step)',
        () async {
      final provider = XtreamProvider(
        ProviderConfig(
            type: ProviderType.xtream, caption: 'x', location: 'http://h'),
      );
      final resolved = await provider.resolveStreamUrl(const Channel(
          id: 'xt:1', name: 'n', url: 'http://h/live/u/p/1.ts'));
      expect(resolved, isNull);
    });
  });
}
