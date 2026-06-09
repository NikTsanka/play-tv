import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:streamhub/domain/channels/storage/database.dart';
import 'package:streamhub/domain/favorites/favorite_item.dart';
import 'package:streamhub/domain/providers/provider_config.dart';
import 'package:streamhub/domain/providers/provider_type.dart';
import 'package:streamhub/domain/providers/sources/xtream/xtream_provider.dart';
import 'package:streamhub/domain/vod/storage/vod_repository.dart';
import 'package:streamhub/domain/vod/vod_catalog.dart';
import 'package:streamhub/domain/vod/vod_models.dart';

VodItem _movie(String id, String title, String cat, {String? rating}) => VodItem(
      id: id,
      kind: VodKind.movie,
      title: title,
      categoryId: cat,
      categoryName: 'Cat $cat',
      rating: rating,
      url: 'http://h/movie/$id.mkv',
    );

void main() {
  group('VodRepository', () {
    late AppDatabase db;
    late VodRepository repo;
    late int sourceId;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = VodRepository(db);
      sourceId = await db.createPlaylist(PlaylistsCompanion.insert(
        name: 'Panel',
        location: 'http://h',
        kind: const Value('xtream'),
      ));
    });

    tearDown(() async => db.close());

    test('caches and reads movies back', () async {
      await repo.cache(sourceId, VodKind.movie, <VodItem>[
        _movie('1', 'Alpha', '5', rating: '8.0'),
        _movie('2', 'Beta', '5'),
        _movie('3', 'Gamma', '6'),
      ]);

      final List<VodItem> all = await repo.watch(sourceId, VodKind.movie).first;
      expect(all.length, 3);
      expect(await repo.count(sourceId, VodKind.movie), 3);
    });

    test('filters by category and search', () async {
      await repo.cache(sourceId, VodKind.movie, <VodItem>[
        _movie('1', 'Alpha', '5'),
        _movie('2', 'Beta', '5'),
        _movie('3', 'Gamma', '6'),
      ]);

      final inCat5 =
          await repo.watch(sourceId, VodKind.movie, categoryId: '5').first;
      expect(inCat5.length, 2);

      final search =
          await repo.watch(sourceId, VodKind.movie, search: 'amm').first;
      expect(search.single.title, 'Gamma');
    });

    test('lists distinct categories', () async {
      await repo.cache(sourceId, VodKind.movie, <VodItem>[
        _movie('1', 'Alpha', '5'),
        _movie('2', 'Beta', '5'),
        _movie('3', 'Gamma', '6'),
      ]);
      final List<VodCategory> cats = await repo.categories(sourceId, VodKind.movie);
      expect(cats.map((c) => c.id).toSet(), <String>{'5', '6'});
    });

    test('re-caching replaces the previous catalog', () async {
      await repo.cache(sourceId, VodKind.movie, <VodItem>[_movie('1', 'A', '5')]);
      await repo.cache(sourceId, VodKind.movie, <VodItem>[
        _movie('2', 'B', '5'),
        _movie('3', 'C', '5'),
      ]);
      expect(await repo.count(sourceId, VodKind.movie), 2);
    });

    test('movies and series caches are independent', () async {
      await repo.cache(sourceId, VodKind.movie, <VodItem>[_movie('1', 'A', '5')]);
      await repo.cache(sourceId, VodKind.series, <VodItem>[
        const VodItem(id: 's1', kind: VodKind.series, title: 'Show'),
      ]);
      expect(await repo.count(sourceId, VodKind.movie), 1);
      expect(await repo.count(sourceId, VodKind.series), 1);
    });

    test('toggles favorites on and off', () async {
      final FavoriteItem fav =
          FavoriteItem.fromVod(_movie('9', 'Fav', '5'), sourceId);
      expect(await repo.isFavorite(fav.refId), isFalse);

      expect(await repo.toggleFavorite(fav), isTrue);
      expect(await repo.isFavorite(fav.refId), isTrue);
      final List<FavoriteItem> favs = await repo.watchFavorites().first;
      expect(favs.single.title, 'Fav');

      expect(await repo.toggleFavorite(fav), isFalse);
      expect(await repo.isFavorite(fav.refId), isFalse);
    });
  });

  group('FavoriteItem', () {
    test('builds a composite, source-unique refId', () {
      final FavoriteItem a =
          FavoriteItem.fromVod(_movie('1', 'X', '5'), 10);
      expect(a.refId, '10:vodMovie:1');
      expect(a.kind, FavoriteKind.vodMovie);

      final FavoriteItem s = FavoriteItem.fromVod(
          const VodItem(id: '1', kind: VodKind.series, title: 'S'), 10);
      expect(s.refId, '10:vodSeries:1');
    });
  });

  group('Xtream VOD catalog', () {
    MockClient panel() => MockClient((http.Request req) async {
          final String? action = req.url.queryParameters['action'];
          switch (action) {
            case null:
              return http.Response(
                jsonEncode(<String, dynamic>{
                  'user_info': <String, dynamic>{'auth': 1, 'status': 'Active'},
                  'server_info': <String, dynamic>{
                    'url': 'cdn.example.com',
                    'port': '8080',
                    'server_protocol': 'http',
                  },
                }),
                200,
              );
            case 'get_vod_categories':
              return http.Response(
                  jsonEncode(<dynamic>[
                    <String, dynamic>{'category_id': '5', 'category_name': 'Action'},
                  ]),
                  200);
            case 'get_vod_streams':
              return http.Response(
                  jsonEncode(<dynamic>[
                    <String, dynamic>{
                      'stream_id': 999,
                      'name': 'The Movie',
                      'category_id': '5',
                      'container_extension': 'mkv',
                      'rating': '7.5',
                      'stream_icon': 'http://c/m.png',
                    },
                  ]),
                  200);
            case 'get_series_categories':
              return http.Response(
                  jsonEncode(<dynamic>[
                    <String, dynamic>{'category_id': '7', 'category_name': 'Drama'},
                  ]),
                  200);
            case 'get_series':
              return http.Response(
                  jsonEncode(<dynamic>[
                    <String, dynamic>{
                      'series_id': 50,
                      'name': 'The Show',
                      'category_id': '7',
                      'cover': 'http://c/s.png',
                      'plot': 'A drama',
                    },
                  ]),
                  200);
            case 'get_series_info':
              return http.Response(
                  jsonEncode(<String, dynamic>{
                    'episodes': <String, dynamic>{
                      '1': <dynamic>[
                        <String, dynamic>{
                          'id': '1001',
                          'title': 'Pilot',
                          'season': 1,
                          'episode_num': 1,
                          'container_extension': 'mp4',
                        },
                      ],
                    },
                  }),
                  200);
            default:
              return http.Response('[]', 200);
          }
        });

    VodCatalog catalogOf(MockClient client) {
      final provider = XtreamProvider(
        ProviderConfig(
          type: ProviderType.xtream,
          caption: 'Panel',
          location: 'http://example.com:8080',
          settings: <String, String>{'username': 'u', 'password': 'p'},
        ),
        httpClient: client,
      );
      return provider.vodCatalog!;
    }

    test('movies carry category names and a built stream URL', () async {
      final List<VodItem> movies = await catalogOf(panel()).movies();
      expect(movies.length, 1);
      final VodItem m = movies.single;
      expect(m.title, 'The Movie');
      expect(m.categoryName, 'Action');
      expect(m.url, 'http://cdn.example.com:8080/movie/u/p/999.mkv');
    });

    test('series entries have no direct url', () async {
      final List<VodItem> series = await catalogOf(panel()).seriesEntries();
      expect(series.single.kind, VodKind.series);
      expect(series.single.categoryName, 'Drama');
      expect(series.single.url, isNull);
    });

    test('episodes resolve a per-episode series URL', () async {
      final VodCatalog catalog = catalogOf(panel());
      final episodes = await catalog.episodes(
          const VodItem(id: '50', kind: VodKind.series, title: 'The Show'));
      expect(episodes.single.title, 'Pilot');
      expect(episodes.single.season, 1);
      expect(episodes.single.url,
          'http://cdn.example.com:8080/series/u/p/1001.mp4');
    });
  });
}
