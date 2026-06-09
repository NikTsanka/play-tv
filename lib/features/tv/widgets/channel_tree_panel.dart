import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/channels/channel.dart';
import '../../../domain/channels/channel_tree.dart';
import '../../../domain/channels/channels_providers.dart';
import '../../../domain/channels/zapping_controller.dart';
import '../../../domain/favorites/favorite_item.dart';
import '../../../domain/parental/parental_control.dart';
import '../../../domain/vod/vod_providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../settings/widgets/pin_dialog.dart';

/// Left-side channel tree: search + collapsible groups. Flattened into a single
/// virtualized list so 10k+ channels scroll smoothly (spec §5/§12).
class ChannelTreePanel extends ConsumerStatefulWidget {
  const ChannelTreePanel({super.key});

  @override
  ConsumerState<ChannelTreePanel> createState() => _ChannelTreePanelState();
}

class _ChannelTreePanelState extends ConsumerState<ChannelTreePanel> {
  final Set<String> _expanded = <String>{};
  String _query = '';
  static const double _itemExtent = 44;

  final ScrollController _scrollController = ScrollController();
  List<_Row> _rows = const <_Row>[];
  String? _lastScrolledId;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Scrolls so the tuned channel's row stays on screen during zapping.
  void _ensureVisible(String channelId) {
    final int index =
        _rows.indexWhere((_Row r) => r.channel?.id == channelId);
    if (index < 0 || !_scrollController.hasClients) return;
    final double offset = index * _itemExtent;
    final ScrollPosition pos = _scrollController.position;
    final double top = pos.pixels;
    final double bottom = top + pos.viewportDimension;
    if (offset < top || offset + _itemExtent > bottom) {
      final double target = (offset - pos.viewportDimension / 2 + _itemExtent / 2)
          .clamp(0.0, pos.maxScrollExtent);
      _scrollController.animateTo(target,
          duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    }
  }

  /// Plays [c] within category [scope], prompting for the parental PIN first if
  /// it's locked (spec §9).
  Future<void> _playChannel(Channel c, List<Channel> scope) async {
    final ParentalController parental =
        ref.read(parentalControllerProvider.notifier);
    if (parental.isLocked(c)) {
      final l10n = AppLocalizations.of(context);
      final String? pin =
          await showPinDialog(context, title: l10n.parentalEnterPin);
      if (pin == null) return;
      if (!parental.unlock(pin)) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l10n.parentalWrongPin)));
        }
        return;
      }
    }
    await ref.read(zappingProvider.notifier).play(c, scope: scope);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final all = ref.watch(currentChannelsProvider).valueOrNull ?? const <Channel>[];
    final current = ref.watch(zappingProvider).current;
    final ParentalState parental = ref.watch(parentalControllerProvider);
    final Set<String> favIds = ref.watch(favoriteRefIdsProvider);
    final int? sourceId = ref.watch(currentPlaylistProvider);

    String refOf(Channel c) =>
        FavoriteItem.makeRefId(FavoriteKind.channel, sourceId, c.id);
    bool isFav(Channel c) => favIds.contains(refOf(c));

    final filtered = filterChannels(all, _query);
    final groups = groupChannels(filtered, ungroupedLabel: l10n.channelsUngrouped);

    // When searching, expand everything so matches are visible.
    final bool searching = _query.trim().isNotEmpty;
    final rows = <_Row>[];

    // A "Favorites" pseudo-group at the top (current source's favorites).
    final List<Channel> favChannels =
        filtered.where(isFav).toList();
    if (favChannels.isNotEmpty) {
      final bool open = searching || _expanded.contains(l10n.vodFavorites);
      rows.add(_Row.group(l10n.vodFavorites, favChannels.length, open));
      if (open) {
        for (final c in favChannels) {
          rows.add(_Row.channel(c, favChannels));
        }
      }
    }

    for (final g in groups) {
      final bool open = searching || _expanded.contains(g.title);
      rows.add(_Row.group(g.title, g.channels.length, open));
      if (open) {
        for (final c in g.channels) {
          rows.add(_Row.channel(c, g.channels));
        }
      }
    }
    _rows = rows;

    // Reveal the tuned channel when it changes OR when the panel is (re)shown:
    // expand its group and scroll it into view, keeping it highlighted. This
    // restores the same category + selection after the list was hidden.
    if (current != null && current.id != _lastScrolledId) {
      _lastScrolledId = current.id;
      final String title = current.group ?? l10n.channelsUngrouped;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_query.trim().isEmpty && !_expanded.contains(title)) {
          setState(() => _expanded.add(title));
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _ensureVisible(current.id);
          });
        } else {
          _ensureVisible(current.id);
        }
      });
    }

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: TextField(
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: const Icon(Icons.search, size: 20),
              hintText: l10n.channelsSearch,
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        if (all.isEmpty)
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.channelsEmpty,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: scheme.onSurfaceVariant)),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: rows.length,
              itemExtent: _itemExtent,
              itemBuilder: (context, i) {
                final row = rows[i];
                if (row.isGroup) {
                  return _GroupHeader(
                    title: row.title!,
                    count: row.count,
                    expanded: row.expanded,
                    onTap: searching
                        ? null
                        : () => setState(() {
                              if (!_expanded.remove(row.title)) {
                                _expanded.add(row.title!);
                              }
                            }),
                  );
                }
                final c = row.channel!;
                return _ChannelTile(
                  channel: c,
                  selected: current?.id == c.id,
                  locked: parental.isLocked(c),
                  favorite: isFav(c),
                  onFavorite: () => ref
                      .read(vodRepositoryProvider)
                      .toggleFavorite(FavoriteItem.fromChannel(c, sourceId)),
                  onTap: () => _playChannel(c, row.scope),
                );
              },
            ),
          ),
        Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.4)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: <Widget>[
              Text('${all.length} ${l10n.channelsCountSuffix}',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _Row {
  _Row.group(this.title, this.count, this.expanded)
      : isGroup = true,
        channel = null,
        scope = const <Channel>[];
  _Row.channel(this.channel, this.scope)
      : isGroup = false,
        title = null,
        count = 0,
        expanded = false;

  final bool isGroup;
  final String? title;
  final int count;
  final bool expanded;
  final Channel? channel;

  /// The category list this channel belongs to (for scoped zapping).
  final List<Channel> scope;
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.title,
    required this.count,
    required this.expanded,
    required this.onTap,
  });

  final String title;
  final int count;
  final bool expanded;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: <Widget>[
            Icon(expanded ? Icons.expand_more : Icons.chevron_right,
                size: 20, color: scheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Expanded(
              child: Text(title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            Text('$count',
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _ChannelTile extends StatelessWidget {
  const _ChannelTile({
    required this.channel,
    required this.selected,
    required this.locked,
    required this.favorite,
    required this.onFavorite,
    required this.onTap,
  });

  final Channel channel;
  final bool selected;
  final bool locked;
  final bool favorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? scheme.primary.withValues(alpha: 0.15) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 28,
                child: Text(
                  channel.number?.toString() ?? '',
                  style: TextStyle(
                      color: scheme.onSurfaceVariant, fontSize: 12),
                ),
              ),
              _Logo(url: channel.logoUrl, isRadio: channel.isRadio),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  channel.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? scheme.primary : scheme.onSurface,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              if (locked)
                Icon(Icons.lock_outline, size: 14, color: scheme.onSurfaceVariant)
              else if (channel.hasArchive)
                Icon(Icons.history, size: 14, color: scheme.onSurfaceVariant),
              InkResponse(
                radius: 18,
                onTap: onFavorite,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Icon(
                    favorite ? Icons.star : Icons.star_border,
                    size: 16,
                    color: favorite ? scheme.primary : scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.url, required this.isRadio});
  final String? url;
  final bool isRadio;

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(isRadio ? Icons.radio : Icons.live_tv,
        size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant);
    if (url == null || url!.isEmpty) {
      return SizedBox(width: 24, height: 24, child: fallback);
    }
    return SizedBox(
      width: 24,
      height: 24,
      child: Image.network(
        url!,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => fallback,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : fallback,
      ),
    );
  }
}
