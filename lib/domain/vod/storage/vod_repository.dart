import 'package:drift/drift.dart';

import '../../channels/storage/database.dart' as db;
import '../../favorites/favorite_item.dart';
import '../vod_models.dart';

/// Bridges the drift store and the VOD domain models: the offline catalog cache
/// and the (generic) favorites table (spec §7).
class VodRepository {
  VodRepository(this._db);

  final db.AppDatabase _db;

  // ---- catalog cache ----------------------------------------------------

  /// Replaces the cached [kind] entries for [sourceId] (the offline cache).
  Future<void> cache(int sourceId, VodKind kind, List<VodItem> items) {
    final List<db.VodEntriesCompanion> rows = <db.VodEntriesCompanion>[
      for (int i = 0; i < items.length; i++) _toCompanion(sourceId, items[i], i),
    ];
    return _db.replaceVodEntries(sourceId, kind.id, rows);
  }

  Stream<List<VodItem>> watch(
    int sourceId,
    VodKind kind, {
    String? categoryId,
    String? search,
  }) =>
      _db
          .watchVodEntries(sourceId, kind.id,
              categoryId: categoryId, search: search)
          .map((rows) => rows.map(_toDomain).toList());

  Future<int> count(int sourceId, VodKind kind) =>
      _db.vodEntryCount(sourceId, kind.id);

  Future<List<VodCategory>> categories(int sourceId, VodKind kind) async {
    final List<({String id, String name})> rows =
        await _db.vodCategoriesOf(sourceId, kind.id);
    return <VodCategory>[
      for (final ({String id, String name}) r in rows)
        VodCategory(id: r.id, name: r.name),
    ];
  }

  // ---- favorites --------------------------------------------------------

  Stream<List<FavoriteItem>> watchFavorites([FavoriteKind? kind]) =>
      _db.watchFavorites(kind?.id).map((rows) => rows.map(_favFromRow).toList());

  Future<bool> isFavorite(String refId) => _db.isFavorite(refId);

  Future<void> setFavorite(FavoriteItem item, {required bool on}) => on
      ? _db.addFavorite(_favCompanion(item))
      : _db.removeFavorite(item.refId);

  /// Flips and returns the new state.
  Future<bool> toggleFavorite(FavoriteItem item) async {
    final bool on = await _db.isFavorite(item.refId);
    await setFavorite(item, on: !on);
    return !on;
  }

  // ---- mapping ----------------------------------------------------------

  db.VodEntriesCompanion _toCompanion(int sourceId, VodItem v, int position) =>
      db.VodEntriesCompanion.insert(
        sourceId: sourceId,
        entryId: v.id,
        kind: v.kind.id,
        title: v.title,
        cover: Value(v.cover),
        categoryId: Value(v.categoryId),
        categoryName: Value(v.categoryName),
        plot: Value(v.plot),
        rating: Value(v.rating),
        year: Value(v.year),
        url: Value(v.url),
        position: Value(position),
      );

  VodItem _toDomain(db.VodEntry r) => VodItem(
        id: r.entryId,
        kind: VodKindId.fromId(r.kind),
        title: r.title,
        cover: r.cover,
        categoryId: r.categoryId,
        categoryName: r.categoryName,
        plot: r.plot,
        rating: r.rating,
        year: r.year,
        url: r.url,
      );

  FavoriteItem _favFromRow(db.Favorite r) => FavoriteItem(
        refId: r.refId,
        kind: FavoriteKindId.fromId(r.kind),
        title: r.title,
        sourceId: r.sourceId,
        subtitle: r.subtitle,
        imageUrl: r.imageUrl,
        playUrl: r.playUrl,
      );

  db.FavoritesCompanion _favCompanion(FavoriteItem item) =>
      db.FavoritesCompanion.insert(
        refId: item.refId,
        kind: item.kind.id,
        title: item.title,
        sourceId: Value(item.sourceId),
        subtitle: Value(item.subtitle),
        imageUrl: Value(item.imageUrl),
        playUrl: Value(item.playUrl),
      );
}
