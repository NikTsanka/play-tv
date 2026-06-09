import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/favorites/favorite_item.dart';
import '../../domain/providers/provider_config.dart';
import '../../domain/vod/vod_models.dart';
import '../../domain/vod/vod_providers.dart';
import '../../l10n/generated/app_localizations.dart';
import 'widgets/vod_detail_sheet.dart';

/// Which top-level VOD view is showing.
enum _VodTab { movies, series, favorites }

/// VOD browser (spec §7): source selector + Movies / Series / Favorites, with
/// category filter, search and sort over the offline-cached catalog.
class VodPage extends ConsumerStatefulWidget {
  const VodPage({super.key});

  @override
  ConsumerState<VodPage> createState() => _VodPageState();
}

class _VodPageState extends ConsumerState<VodPage> {
  _VodTab _tab = _VodTab.movies;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _selectTab(_VodTab tab) {
    setState(() => _tab = tab);
    if (tab == _VodTab.movies) {
      ref.read(vodKindProvider.notifier).state = VodKind.movie;
    } else if (tab == _VodTab.series) {
      ref.read(vodKindProvider.notifier).state = VodKind.series;
    }
    // Reset the category filter when switching catalogs.
    ref.read(vodCategoryProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<List<ProviderConfig>> sources =
        ref.watch(vodSourcesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.vodTitle),
        actions: const <Widget>[
          _SourceSelector(),
          _SortMenu(),
          _RefreshButton(),
          SizedBox(width: 8),
        ],
      ),
      body: sources.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (List<ProviderConfig> list) {
          if (list.isEmpty) {
            return _Message(icon: Icons.movie_filter_outlined, text: l10n.vodNoSources);
          }
          return Column(
            children: <Widget>[
              _Tabs(tab: _tab, onSelect: _selectTab),
              if (_tab != _VodTab.favorites) _FilterBar(controller: _searchCtrl),
              const Divider(height: 1),
              Expanded(
                child: _tab == _VodTab.favorites
                    ? const _FavoritesGrid()
                    : const _CatalogGrid(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SourceSelector extends ConsumerWidget {
  const _SourceSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<ProviderConfig> sources =
        ref.watch(vodSourcesProvider).valueOrNull ?? const <ProviderConfig>[];
    final int? current = ref.watch(currentVodSourceProvider);
    if (sources.length < 2) return const SizedBox.shrink();
    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: current,
        items: <DropdownMenuItem<int>>[
          for (final ProviderConfig s in sources)
            if (s.id != null)
              DropdownMenuItem<int>(value: s.id, child: Text(s.caption)),
        ],
        onChanged: (id) {
          if (id != null) {
            ref.read(currentVodSourceProvider.notifier).select(id);
          }
        },
      ),
    );
  }
}

class _SortMenu extends ConsumerWidget {
  const _SortMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final VodSort sort = ref.watch(vodSortProvider);
    return PopupMenuButton<VodSort>(
      icon: const Icon(Icons.sort),
      initialValue: sort,
      tooltip: l10n.vodSortDefault,
      onSelected: (s) => ref.read(vodSortProvider.notifier).state = s,
      itemBuilder: (_) => <PopupMenuEntry<VodSort>>[
        PopupMenuItem<VodSort>(
            value: VodSort.defaultOrder, child: Text(l10n.vodSortDefault)),
        PopupMenuItem<VodSort>(
            value: VodSort.titleAsc, child: Text(l10n.vodSortTitle)),
        PopupMenuItem<VodSort>(
            value: VodSort.ratingDesc, child: Text(l10n.vodSortRating)),
      ],
    );
  }
}

class _RefreshButton extends ConsumerWidget {
  const _RefreshButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<void> state = ref.watch(vodRefreshProvider);
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14),
        child: Center(
          child: SizedBox(
              width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }
    return IconButton(
      tooltip: l10n.vodRefresh,
      icon: const Icon(Icons.refresh),
      onPressed: () async {
        await ref.read(vodRefreshProvider.notifier).refresh();
        final AsyncValue<void> result = ref.read(vodRefreshProvider);
        if (result.hasError && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${result.error}')),
          );
        }
      },
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.tab, required this.onSelect});
  final _VodTab tab;
  final ValueChanged<_VodTab> onSelect;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SegmentedButton<_VodTab>(
        segments: <ButtonSegment<_VodTab>>[
          ButtonSegment<_VodTab>(
              value: _VodTab.movies,
              icon: const Icon(Icons.movie_outlined),
              label: Text(l10n.vodMovies)),
          ButtonSegment<_VodTab>(
              value: _VodTab.series,
              icon: const Icon(Icons.video_library_outlined),
              label: Text(l10n.vodSeries)),
          ButtonSegment<_VodTab>(
              value: _VodTab.favorites,
              icon: const Icon(Icons.favorite_outline),
              label: Text(l10n.vodFavorites)),
        ],
        selected: <_VodTab>{tab},
        onSelectionChanged: (s) => onSelect(s.first),
      ),
    );
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<VodCategory> categories =
        ref.watch(vodCategoriesProvider).valueOrNull ?? const <VodCategory>[];
    final String? selected = ref.watch(vodCategoryProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: <Widget>[
          TextField(
            controller: controller,
            decoration: InputDecoration(
              isDense: true,
              hintText: l10n.vodSearch,
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) =>
                ref.read(vodSearchProvider.notifier).state = v.trim(),
          ),
          if (categories.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: ChoiceChip(
                      label: Text(l10n.vodAllCategories),
                      selected: selected == null,
                      onSelected: (_) =>
                          ref.read(vodCategoryProvider.notifier).state = null,
                    ),
                  ),
                  for (final VodCategory c in categories)
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: ChoiceChip(
                        label: Text(c.name),
                        selected: selected == c.id,
                        onSelected: (_) =>
                            ref.read(vodCategoryProvider.notifier).state = c.id,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CatalogGrid extends ConsumerWidget {
  const _CatalogGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<List<VodItem>> items = ref.watch(vodListProvider);
    final int? sourceId = ref.watch(currentVodSourceProvider);
    final Set<String> favs = ref.watch(favoriteRefIdsProvider);

    return items.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (List<VodItem> list) {
        if (list.isEmpty) {
          return _Message(icon: Icons.movie_outlined, text: l10n.vodEmpty);
        }
        return _PosterGrid(
          count: list.length,
          builder: (i) {
            final VodItem item = list[i];
            final String refId = sourceId == null
                ? item.id
                : FavoriteItem.makeRefId(
                    item.isSeries
                        ? FavoriteKind.vodSeries
                        : FavoriteKind.vodMovie,
                    sourceId,
                    item.id);
            return _PosterCard(
              title: item.title,
              imageUrl: item.cover,
              rating: item.rating,
              isSeries: item.isSeries,
              isFavorite: favs.contains(refId),
              onFavorite: sourceId == null
                  ? null
                  : () => ref
                      .read(vodRepositoryProvider)
                      .toggleFavorite(FavoriteItem.fromVod(item, sourceId)),
              onTap: () => showVodDetailSheet(context, item),
            );
          },
        );
      },
    );
  }
}

class _FavoritesGrid extends ConsumerWidget {
  const _FavoritesGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<FavoriteItem> favs =
        (ref.watch(favoritesProvider).valueOrNull ?? const <FavoriteItem>[])
            .where((f) =>
                f.kind == FavoriteKind.vodMovie ||
                f.kind == FavoriteKind.vodSeries)
            .toList();
    if (favs.isEmpty) {
      return _Message(icon: Icons.favorite_outline, text: l10n.vodFavoritesEmpty);
    }
    return _PosterGrid(
      count: favs.length,
      builder: (i) {
        final FavoriteItem f = favs[i];
        final bool isSeries = f.kind == FavoriteKind.vodSeries;
        return _PosterCard(
          title: f.title,
          imageUrl: f.imageUrl,
          subtitle: f.subtitle,
          isSeries: isSeries,
          isFavorite: true,
          onFavorite: () =>
              ref.read(vodRepositoryProvider).setFavorite(f, on: false),
          onTap: () {
            if (isSeries) {
              showVodDetailSheet(
                context,
                VodItem(
                  id: _idFromRef(f.refId),
                  kind: VodKind.series,
                  title: f.title,
                  cover: f.imageUrl,
                ),
              );
            } else if (f.playUrl != null) {
              playVod(context, ref, url: f.playUrl!, title: f.title);
            }
          },
        );
      },
    );
  }

  static String _idFromRef(String refId) {
    final List<String> parts = refId.split(':');
    return parts.length >= 3 ? parts.sublist(2).join(':') : refId;
  }
}

/// Responsive poster grid.
class _PosterGrid extends StatelessWidget {
  const _PosterGrid({required this.count, required this.builder});
  final int count;
  final Widget Function(int index) builder;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 170,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.58,
      ),
      itemCount: count,
      itemBuilder: (_, i) => builder(i),
    );
  }
}

class _PosterCard extends StatelessWidget {
  const _PosterCard({
    required this.title,
    required this.imageUrl,
    required this.isSeries,
    required this.isFavorite,
    required this.onTap,
    this.onFavorite,
    this.rating,
    this.subtitle,
  });

  final String title;
  final String? imageUrl;
  final bool isSeries;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final String? rating;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _PosterImage(url: imageUrl, isSeries: isSeries),
                ),
                if (rating != null && rating!.isNotEmpty)
                  Positioned(
                    left: 6,
                    top: 6,
                    child: _Badge(
                        icon: Icons.star, label: rating!, color: scheme.primary),
                  ),
                Positioned(
                  right: 2,
                  top: 2,
                  child: IconButton(
                    iconSize: 20,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? scheme.primary : Colors.white,
                    ),
                    onPressed: onFavorite,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall),
          if (subtitle != null && subtitle!.isNotEmpty)
            Text(subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: scheme.outline)),
        ],
      ),
    );
  }
}

class _PosterImage extends StatelessWidget {
  const _PosterImage({required this.url, required this.isSeries});
  final String? url;
  final bool isSeries;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Widget placeholder = ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Icon(isSeries ? Icons.video_library : Icons.movie,
          color: scheme.outline, size: 40),
    );
    if (url == null || url!.isEmpty) return placeholder;
    return Image.network(
      url!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => placeholder,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : placeholder,
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 64, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(text,
                textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
          ),
        ],
      ),
    );
  }
}
