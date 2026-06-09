import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../domain/favorites/favorite_item.dart';
import '../../../domain/playback/playback_providers.dart';
import '../../../domain/playback/playback_status.dart';
import '../../../domain/vod/vod_models.dart';
import '../../../domain/vod/vod_providers.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Opens [url] in the engine and jumps to the Player tab.
Future<void> playVod(BuildContext context, WidgetRef ref,
    {required String url, required String title}) async {
  if (url.isEmpty) return;
  await ref
      .read(playbackEngineProvider)
      .open(PlayRequest(url: url, title: title));
  if (context.mounted) context.go(Routes.player);
}

/// Bottom sheet with VOD details: cover + meta + Play (movie) or season /
/// episode list (series), plus a favorite toggle (spec §7).
Future<void> showVodDetailSheet(BuildContext context, VodItem item) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _VodDetailSheet(item: item),
  );
}

class _VodDetailSheet extends ConsumerWidget {
  const _VodDetailSheet({required this.item});
  final VodItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final int? sourceId = ref.watch(currentVodSourceProvider);
    final FavoriteKind favKind =
        item.isSeries ? FavoriteKind.vodSeries : FavoriteKind.vodMovie;
    final String refId = FavoriteItem.makeRefId(favKind, sourceId, item.id);
    final bool isFav = ref.watch(favoriteRefIdsProvider).contains(refId);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 110,
                  height: 160,
                  child: _Cover(url: item.cover, isSeries: item.isSeries),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(item.title, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 12,
                      children: <Widget>[
                        if (item.year != null && item.year!.isNotEmpty)
                          Text(item.year!, style: theme.textTheme.bodySmall),
                        if (item.rating != null && item.rating!.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(Icons.star,
                                  size: 14, color: theme.colorScheme.primary),
                              const SizedBox(width: 2),
                              Text(item.rating!,
                                  style: theme.textTheme.bodySmall),
                            ],
                          ),
                        if (item.categoryName != null &&
                            item.categoryName!.isNotEmpty)
                          Text(item.categoryName!,
                              style: theme.textTheme.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        if (!item.isSeries && item.url != null)
                          FilledButton.icon(
                            onPressed: () => playVod(context, ref,
                                url: item.url!, title: item.title),
                            icon: const Icon(Icons.play_arrow),
                            label: Text(l10n.vodPlay),
                          ),
                        if (sourceId != null)
                          IconButton(
                            tooltip: l10n.vodFavorites,
                            icon: Icon(isFav
                                ? Icons.favorite
                                : Icons.favorite_border),
                            color: theme.colorScheme.primary,
                            onPressed: () => ref
                                .read(vodRepositoryProvider)
                                .toggleFavorite(
                                    FavoriteItem.fromVod(item, sourceId)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (item.plot != null && item.plot!.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            Text(item.plot!, style: theme.textTheme.bodyMedium),
          ],
          if (item.isSeries && sourceId != null) ...<Widget>[
            const SizedBox(height: 16),
            _Episodes(sourceId: sourceId, series: item),
          ],
        ],
      ),
    );
  }
}

class _Episodes extends ConsumerWidget {
  const _Episodes({required this.sourceId, required this.series});
  final int sourceId;
  final VodItem series;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return FutureBuilder<List<VodEpisode>>(
      future: ref
          .read(vodCatalogServiceProvider)
          .episodes(sourceId, series),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2)),
                const SizedBox(width: 12),
                Text(l10n.vodLoadingEpisodes),
              ],
            ),
          );
        }
        final List<VodEpisode> episodes =
            snapshot.data ?? const <VodEpisode>[];
        if (episodes.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.vodNoEpisodes),
          );
        }

        // Group by season number.
        final Map<int, List<VodEpisode>> bySeason = <int, List<VodEpisode>>{};
        for (final VodEpisode e in episodes) {
          bySeason.putIfAbsent(e.season, () => <VodEpisode>[]).add(e);
        }
        final List<int> seasons = bySeason.keys.toList()..sort();

        return Column(
          children: <Widget>[
            for (final int season in seasons)
              ExpansionTile(
                title: Text(l10n.vodSeasonLabel(season)),
                initiallyExpanded: season == seasons.first,
                children: <Widget>[
                  for (final VodEpisode e in bySeason[season]!)
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.play_circle_outline),
                      title: Text(e.title),
                      onTap: () =>
                          playVod(context, ref, url: e.url, title: e.title),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.url, required this.isSeries});
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
    );
  }
}
