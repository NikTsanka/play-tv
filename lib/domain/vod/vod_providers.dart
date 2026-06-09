import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/preferences.dart';
import '../channels/channels_providers.dart';
import '../favorites/favorite_item.dart';
import '../providers/provider_config.dart';
import '../providers/providers_providers.dart';
import '../providers/stream_resolver.dart';
import 'storage/vod_repository.dart';
import 'vod_catalog.dart';
import 'vod_models.dart';

/// How the browse grid is ordered (spec §7 sort).
enum VodSort { defaultOrder, titleAsc, ratingDesc }

final vodRepositoryProvider = Provider<VodRepository>((ref) {
  return VodRepository(ref.watch(appDatabaseProvider));
});

/// Sources that can serve a VOD catalog (currently Xtream). Refreshes when the
/// playlist set changes.
final vodSourcesProvider = FutureProvider<List<ProviderConfig>>((ref) async {
  ref.watch(playlistsProvider);
  final List<ProviderConfig> configs =
      await ref.watch(providersManagerProvider).list();
  final registry = ref.watch(providerRegistryProvider);
  return <ProviderConfig>[
    for (final ProviderConfig c in configs)
      if (registry.build(c).vodCatalog != null) c,
  ];
});

/// The selected VOD source (persisted); falls back to the first VOD-capable one.
class CurrentVodSourceController extends Notifier<int?> {
  @override
  int? build() {
    final stored =
        ref.watch(sharedPreferencesProvider).getInt(PrefKeys.currentVodSource);
    final sources = ref.watch(vodSourcesProvider).valueOrNull;
    if (sources != null && sources.isNotEmpty) {
      final ids = sources.map((s) => s.id).whereType<int>().toSet();
      if (stored != null && ids.contains(stored)) return stored;
      return sources.first.id;
    }
    return stored;
  }

  Future<void> select(int id) async {
    state = id;
    await ref
        .read(sharedPreferencesProvider)
        .setInt(PrefKeys.currentVodSource, id);
  }
}

final currentVodSourceProvider =
    NotifierProvider<CurrentVodSourceController, int?>(
        CurrentVodSourceController.new);

/// Browse facets.
final vodKindProvider = StateProvider<VodKind>((ref) => VodKind.movie);
final vodCategoryProvider = StateProvider<String?>((ref) => null);
final vodSearchProvider = StateProvider<String>((ref) => '');
final vodSortProvider = StateProvider<VodSort>((ref) => VodSort.defaultOrder);

/// Cached catalog list for the current source/kind/category/search, sorted.
final vodListProvider = StreamProvider.autoDispose<List<VodItem>>((ref) {
  final int? sourceId = ref.watch(currentVodSourceProvider);
  if (sourceId == null) return Stream<List<VodItem>>.value(const <VodItem>[]);

  final VodKind kind = ref.watch(vodKindProvider);
  final String? category = ref.watch(vodCategoryProvider);
  final String search = ref.watch(vodSearchProvider);
  final VodSort sort = ref.watch(vodSortProvider);
  final VodRepository repo = ref.watch(vodRepositoryProvider);

  return repo
      .watch(sourceId, kind, categoryId: category, search: search)
      .map((List<VodItem> list) => _sorted(list, sort));
});

/// Distinct categories present in the cache for the current source/kind.
final vodCategoriesProvider =
    FutureProvider.autoDispose<List<VodCategory>>((ref) async {
  final int? sourceId = ref.watch(currentVodSourceProvider);
  if (sourceId == null) return const <VodCategory>[];
  final VodKind kind = ref.watch(vodKindProvider);
  return ref.watch(vodRepositoryProvider).categories(sourceId, kind);
});

/// All favorites; the VOD page filters to the VOD kinds.
final favoritesProvider = StreamProvider<List<FavoriteItem>>((ref) {
  return ref.watch(vodRepositoryProvider).watchFavorites();
});

/// Set of favorited refIds for quick membership checks in the grid.
final favoriteRefIdsProvider = Provider<Set<String>>((ref) {
  final List<FavoriteItem> favs =
      ref.watch(favoritesProvider).valueOrNull ?? const <FavoriteItem>[];
  return <String>{for (final FavoriteItem f in favs) f.refId};
});

/// Fetches catalog/episodes from a source's provider and writes the cache.
class VodCatalogService {
  VodCatalogService(this._resolver, this._repo);

  final StreamResolver _resolver;
  final VodRepository _repo;

  Future<VodCatalog?> _catalog(int sourceId) async =>
      (await _resolver.providerFor(sourceId))?.vodCatalog;

  /// Pulls the [kind] catalog from the network and replaces the cache.
  Future<void> refresh(int sourceId, VodKind kind) async {
    final VodCatalog? catalog = await _catalog(sourceId);
    if (catalog == null) {
      throw StateError('Source $sourceId has no VOD catalog');
    }
    final List<VodItem> items = kind == VodKind.movie
        ? await catalog.movies()
        : await catalog.seriesEntries();
    await _repo.cache(sourceId, kind, items);
  }

  Future<List<VodEpisode>> episodes(int sourceId, VodItem series) async {
    final VodCatalog? catalog = await _catalog(sourceId);
    if (catalog == null) return const <VodEpisode>[];
    return catalog.episodes(series);
  }
}

final vodCatalogServiceProvider = Provider<VodCatalogService>((ref) {
  return VodCatalogService(
    ref.watch(streamResolverProvider),
    ref.watch(vodRepositoryProvider),
  );
});

/// Drives the "refresh from network" button (loading / error for the UI).
class VodRefreshController extends AutoDisposeNotifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData<void>(null);

  Future<void> refresh() async {
    final int? sourceId = ref.read(currentVodSourceProvider);
    if (sourceId == null) return;
    final VodKind kind = ref.read(vodKindProvider);
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(
        () => ref.read(vodCatalogServiceProvider).refresh(sourceId, kind));
  }
}

final vodRefreshProvider =
    AutoDisposeNotifierProvider<VodRefreshController, AsyncValue<void>>(
        VodRefreshController.new);

List<VodItem> _sorted(List<VodItem> list, VodSort sort) {
  switch (sort) {
    case VodSort.defaultOrder:
      return list;
    case VodSort.titleAsc:
      final List<VodItem> copy = <VodItem>[...list];
      copy.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      return copy;
    case VodSort.ratingDesc:
      final List<VodItem> copy = <VodItem>[...list];
      copy.sort((a, b) =>
          (double.tryParse(b.rating ?? '') ?? 0)
              .compareTo(double.tryParse(a.rating ?? '') ?? 0));
      return copy;
  }
}
