import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:streamhub/domain/channels/channel.dart';
import 'package:streamhub/domain/providers/provider.dart';
import 'package:streamhub/domain/providers/provider_config.dart';
import 'package:streamhub/domain/providers/provider_type.dart';
import 'package:streamhub/domain/providers/sources/ott/ott_base_provider.dart';
import 'package:streamhub/domain/providers/sources/ott/ott_models.dart';
import 'package:streamhub/domain/providers/sources/ott/ott_service.dart';
import 'package:streamhub/domain/providers/sources/ott/services/kartina_service.dart';
import 'package:streamhub/domain/providers/sources/ott/services/sovok_service.dart';
import 'package:streamhub/domain/providers/sources/ott/services/tvclub_service.dart';

http.Response _json(Object body) =>
    http.Response(jsonEncode(body), 200, headers: <String, String>{
      'content-type': 'application/json',
    });

ProviderConfig _config(String service) => ProviderConfig(
      type: ProviderType.ott,
      caption: service,
      settings: <String, String>{
        'service': service,
        'username': 'u',
        'password': 'p',
      },
    );

void main() {
  group('ottAbsoluteUrl', () {
    test('passes through absolute, resolves host-less, scheme-relative', () {
      expect(ottAbsoluteUrl('http://b', 'http://x/y'), 'http://x/y');
      expect(ottAbsoluteUrl('http://b', '/live/9.m3u8'), 'http://b/live/9.m3u8');
      expect(ottAbsoluteUrl('http://b/', 'live/9.m3u8'), 'http://b/live/9.m3u8');
      expect(ottAbsoluteUrl('http://b', '//cdn/x'), 'http://cdn/x');
      expect(ottAbsoluteUrl('http://b', ''), isNull);
      expect(ottAbsoluteUrl('http://b', null), isNull);
    });
  });

  group('OttService registry', () {
    test('exposes the three branded services', () {
      expect(ottServices.map((s) => s.id),
          containsAll(<String>['kartina', 'sovok', 'tvclub']));
    });

    test('ottServiceById falls back to the first when unknown', () {
      expect(ottServiceById('sovok'), isA<SovokService>());
      expect(ottServiceById('nope'), same(ottServices.first));
      expect(ottServiceById(null), same(ottServices.first));
    });

    test('isAuthError recognizes session/expired markers', () {
      final OttService s = KartinaService();
      expect(s.isAuthError(<String, dynamic>{'error': 'session expired'}), isTrue);
      expect(
          s.isAuthError(<String, dynamic>{
            'error': <String, dynamic>{'message': 'Auth failed'}
          }),
          isTrue);
      expect(s.isAuthError(<String, dynamic>{'url': 'http://x'}), isFalse);
    });
  });

  group('Kartina (sid query, url field)', () {
    MockClient client() => MockClient((http.Request req) async {
          final String path = req.url.path;
          if (path.endsWith('login')) {
            return _json(<String, dynamic>{'sid': 'S1', 'account': <String, dynamic>{}});
          }
          if (path.endsWith('channel_list')) {
            expect(req.url.queryParameters['sid'], 'S1');
            return _json(<String, dynamic>{
              'groups': <dynamic>[
                <String, dynamic>{
                  'id': 1,
                  'name': 'News',
                  'channels': <dynamic>[
                    <String, dynamic>{
                      'id': 101,
                      'name': 'BBC',
                      'number': 1,
                      'icon': 'http://l/bbc.png',
                      'epg_channel_id': 'bbc.uk',
                      'protected': 0,
                      'have_archive': 1,
                    },
                  ],
                },
              ],
            });
          }
          if (path.endsWith('get_url')) {
            expect(req.url.queryParameters['cid'], '101');
            return _json(
                <String, dynamic>{'url': 'http://cdn/live/101.m3u8?token=abc'});
          }
          return _json(<String, dynamic>{});
        });

    test('builds channels and resolves the per-zap URL', () async {
      final provider =
          OttBaseProvider(KartinaService(), _config('kartina'), httpClient: client());
      final sink = CollectingChannelSink();
      await provider.fetchChannelList(sink, CancelToken());

      expect(sink.channels.length, 1);
      final Channel ch = sink.channels.single;
      expect(ch.id, 'ott:kartina:101');
      expect(ch.group, 'News');
      expect(ch.epgId, 'bbc.uk');
      expect(ch.url, isEmpty); // resolved per zap
      expect(ch.props['cid'], '101');
      expect(ch.props['archive'], 'true');

      final resolved = await provider.resolveStreamUrl(ch);
      expect(resolved, 'http://cdn/live/101.m3u8?token=abc');
    });
  });

  group('Sovok (token carrier, ch/cmd field map)', () {
    MockClient client() => MockClient((http.Request req) async {
          final String path = req.url.path;
          if (path.endsWith('login')) {
            return _json(<String, dynamic>{'token': 'T1'});
          }
          if (path.endsWith('channel_list')) {
            expect(req.url.queryParameters['token'], 'T1');
            return _json(<String, dynamic>{
              'groups': <dynamic>[
                <String, dynamic>{
                  'title': 'Kino',
                  'ch': <dynamic>[
                    <String, dynamic>{
                      'ch_id': '5',
                      'caption': 'Film',
                      'logo': 'http://l/5.png',
                      'have_archive': 1,
                    },
                  ],
                },
              ],
            });
          }
          if (path.endsWith('get_url')) {
            return _json(<String, dynamic>{'cmd': 'http://cdn/5.ts'});
          }
          return _json(<String, dynamic>{});
        });

    test('maps variant fields and resolves cmd', () async {
      final provider =
          OttBaseProvider(SovokService(), _config('sovok'), httpClient: client());
      final sink = CollectingChannelSink();
      await provider.fetchChannelList(sink, CancelToken());

      final Channel ch = sink.channels.single;
      expect(ch.id, 'ott:sovok:5');
      expect(ch.name, 'Film');
      expect(ch.group, 'Kino');

      expect(await provider.resolveStreamUrl(ch), 'http://cdn/5.ts');
    });
  });

  group('TV Club (cookie carrier, host-less url)', () {
    test('sends sid as a cookie and resolves a host-less path', () async {
      String? listCookie;
      final MockClient client = MockClient((http.Request req) async {
        final String path = req.url.path;
        if (path.endsWith('login')) {
          return _json(<String, dynamic>{'sid': 'C1'});
        }
        if (path.endsWith('channel_list')) {
          listCookie = req.headers['cookie'];
          return _json(<String, dynamic>{
            'groups': <dynamic>[
              <String, dynamic>{
                'name': 'All',
                'channels': <dynamic>[
                  <String, dynamic>{'id': '9', 'name': 'Nine'},
                ],
              },
            ],
          });
        }
        if (path.endsWith('get_url')) {
          return _json(<String, dynamic>{'url': '/live/9.m3u8'});
        }
        return _json(<String, dynamic>{});
      });

      final provider = OttBaseProvider(
        TvClubService(),
        ProviderConfig(
          type: ProviderType.ott,
          caption: 'tvclub',
          location: 'http://api.tvclub.cc',
          settings: <String, String>{
            'service': 'tvclub',
            'username': 'u',
            'password': 'p',
          },
        ),
        httpClient: client,
      );
      final sink = CollectingChannelSink();
      await provider.fetchChannelList(sink, CancelToken());

      expect(listCookie, 'sid=C1');
      final resolved = await provider.resolveStreamUrl(sink.channels.single);
      expect(resolved, 'http://api.tvclub.cc/live/9.m3u8');
    });
  });

  group('StackProcessor re-login', () {
    test('re-logs-in once and retries on a session-expired response', () async {
      int logins = 0;
      bool firstGetUrl = true;
      final MockClient client = MockClient((http.Request req) async {
        final String path = req.url.path;
        if (path.endsWith('login')) {
          logins++;
          return _json(<String, dynamic>{'sid': 'S$logins'});
        }
        if (path.endsWith('get_url')) {
          if (firstGetUrl) {
            firstGetUrl = false;
            return _json(<String, dynamic>{'error': 'session expired'});
          }
          return _json(<String, dynamic>{'url': 'http://cdn/ok.m3u8'});
        }
        return _json(<String, dynamic>{});
      });

      final provider =
          OttBaseProvider(KartinaService(), _config('kartina'), httpClient: client);
      final resolved = await provider.resolveStreamUrl(const Channel(
        id: 'ott:kartina:1',
        name: 'n',
        url: '',
        props: <String, String>{'cid': '1'},
      ));

      expect(resolved, 'http://cdn/ok.m3u8');
      expect(logins, 2); // initial + one re-login
    });
  });
}
