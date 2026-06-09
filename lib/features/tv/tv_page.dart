import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/channels/channel.dart';
import '../../domain/channels/channels_providers.dart';
import '../../domain/channels/zapping_controller.dart';
import '../../domain/epg/epg_providers.dart';
import '../../domain/playback/playback_providers.dart';
import '../../domain/providers/providers_providers.dart';
import '../../domain/recording/recording_providers.dart';
import '../../l10n/generated/app_localizations.dart';
import '../player/widgets/player_surface.dart';
import '../providers/add_provider_dialog.dart';
import 'widgets/channel_tree_panel.dart';
import 'widgets/osd_channel_info.dart';

/// Main live-TV view: left channel tree + video + OSD, with keyboard zapping
/// (↑/↓ channel, digits + Enter = number, Backspace clears). Spec §9.
class TvPage extends ConsumerStatefulWidget {
  const TvPage({super.key});

  @override
  ConsumerState<TvPage> createState() => _TvPageState();
}

class _TvPageState extends ConsumerState<TvPage> {
  bool _panelCollapsed = false;
  bool _osdVisible = false;
  Timer? _osdTimer;
  final FocusNode _focus = FocusNode(debugLabel: 'tv-zapping');

  @override
  void dispose() {
    _osdTimer?.cancel();
    _focus.dispose();
    super.dispose();
  }

  void _showOsd() {
    _osdTimer?.cancel();
    if (!_osdVisible) setState(() => _osdVisible = true);
    _osdTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _osdVisible = false);
    });
  }

  /// Adjusts volume by [delta] (0..100 scale) and flashes the OSD.
  void _changeVolume(double delta) {
    final engine = ref.read(playbackEngineProvider);
    final double current = ref.read(currentStatusProvider).volume;
    engine.setVolume((current + delta).clamp(0.0, 100.0));
    _showOsd();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final zap = ref.read(zappingProvider.notifier);
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowUp) {
      zap.next();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      zap.previousChannel();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight) {
      _changeVolume(5);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft) {
      _changeVolume(-5);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      zap.commitNumber();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.backspace) {
      zap.clearNumber();
      return KeyEventResult.handled;
    }
    final ch = event.character;
    if (ch != null && ch.length == 1 && '0123456789'.contains(ch)) {
      zap.enterDigit(ch);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Future<void> _import() async {
    await showAddProviderDialog(context);
  }

  Future<void> _deletePlaylist() async {
    final l10n = AppLocalizations.of(context);
    final int? id = ref.read(currentPlaylistProvider);
    if (id == null) return;
    String name = '';
    for (final p in ref.read(playlistsProvider).valueOrNull ?? const []) {
      if (p.id == id) name = p.name;
    }
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.playlistDelete),
        content: Text(l10n.playlistDeleteConfirm(name)),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.commonCancel)),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (confirm != true) return;
    await ref.read(providersManagerProvider).delete(id);
  }

  Future<void> _recordCurrent() async {
    final l10n = AppLocalizations.of(context);
    final Channel? channel = ref.read(zappingProvider).current;
    if (channel == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.recNothingPlaying)));
      return;
    }
    await ref.read(recordingControllerProvider.notifier).recordChannel(
          channel,
          ref.read(currentPlaylistProvider),
        );
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.recStarted)));
    }
  }

  void _enterFullscreen() {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (context, _, __) => Scaffold(
          backgroundColor: Colors.black,
          body: PlayerSurface(
            isFullscreen: true,
            onToggleFullscreen: () => Navigator.of(context).maybePop(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final channels = ref.watch(currentChannelsProvider).valueOrNull;
    final zap = ref.watch(zappingProvider);

    // Reveal the OSD whenever the tuned channel or number-entry changes.
    ref.listen<ZapState>(zappingProvider, (prev, next) {
      if (prev?.current?.id != next.current?.id ||
          prev?.numberEntry != next.numberEntry) {
        if (next.current != null || next.numberEntry.isNotEmpty) _showOsd();
      }
    });

    final bool hasChannels = channels != null && channels.isNotEmpty;

    return Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: _onKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.navTv),
          leading: IconButton(
            tooltip: l10n.tvTogglePanel,
            icon: Icon(_panelCollapsed ? Icons.menu_open : Icons.menu),
            onPressed: () => setState(() => _panelCollapsed = !_panelCollapsed),
          ),
          actions: <Widget>[
            const _PlaylistSelector(),
            IconButton(
              tooltip: l10n.playlistDelete,
              icon: const Icon(Icons.playlist_remove),
              onPressed:
                  ref.watch(currentPlaylistProvider) == null ? null : _deletePlaylist,
            ),
            IconButton(
              tooltip: l10n.recRecordChannel,
              icon: const Icon(Icons.fiber_manual_record, color: Colors.red),
              onPressed: zap.current == null ? null : _recordCurrent,
            ),
            IconButton(
              tooltip: l10n.providersAddTitle,
              icon: const Icon(Icons.playlist_add),
              onPressed: _import,
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Row(
          children: <Widget>[
            if (!_panelCollapsed)
              SizedBox(
                width: 320,
                child: Material(
                  color: scheme.surface,
                  child: const ChannelTreePanel(),
                ),
              ),
            if (!_panelCollapsed)
              VerticalDivider(
                  width: 1,
                  color: scheme.outlineVariant.withValues(alpha: 0.4)),
            Expanded(
              child: hasChannels || zap.current != null
                  ? Listener(
                      // Mouse wheel up / down → volume up / down.
                      onPointerSignal: (PointerSignalEvent signal) {
                        if (signal is PointerScrollEvent) {
                          _changeVolume(signal.scrollDelta.dy < 0 ? 5 : -5);
                        }
                      },
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        // Drag up → next channel, drag down → previous.
                        onVerticalDragEnd: (DragEndDetails d) {
                          final double v = d.primaryVelocity ?? 0;
                          final zapper = ref.read(zappingProvider.notifier);
                          if (v < -100) {
                            zapper.next();
                          } else if (v > 100) {
                            zapper.previousChannel();
                          }
                        },
                        child: _VideoArea(
                          current: zap.current,
                          numberEntry: zap.numberEntry,
                          osdVisible: _osdVisible,
                          onFullscreen: _enterFullscreen,
                        ),
                      ),
                    )
                  : _EmptyState(onImport: _import),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoArea extends StatelessWidget {
  const _VideoArea({
    required this.current,
    required this.numberEntry,
    required this.osdVisible,
    required this.onFullscreen,
  });

  final Channel? current;
  final String numberEntry;
  final bool osdVisible;
  final VoidCallback onFullscreen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (current != null)
            PlayerSurface(isFullscreen: false, onToggleFullscreen: onFullscreen)
          else
            Center(
              child: Text(l10n.tvSelectChannel,
                  style: const TextStyle(color: Colors.white54)),
            ),
          // Number-entry overlay.
          if (numberEntry.isNotEmpty)
            Align(
              alignment: Alignment.topRight,
              child: Container(
                margin: const EdgeInsets.all(20),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: Theme.of(context).colorScheme.primary),
                ),
                child: Text(numberEntry,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          // Channel info OSD with live now/next from the EPG.
          if (osdVisible && current != null)
            IgnorePointer(child: _OsdForChannel(channel: current!)),
        ],
      ),
    );
  }
}

class _OsdForChannel extends ConsumerWidget {
  const _OsdForChannel({required this.channel});
  final Channel channel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nowNext = ref.watch(nowNextProvider(channel.id)).valueOrNull;
    return OsdChannelInfo(
      channel: channel,
      nowTitle: nowNext?.now?.title,
      nextTitle: nowNext?.next?.title,
    );
  }
}

class _PlaylistSelector extends ConsumerWidget {
  const _PlaylistSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistsProvider).valueOrNull;
    final current = ref.watch(currentPlaylistProvider);
    if (playlists == null || playlists.isEmpty) {
      return const SizedBox.shrink();
    }
    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: current,
        items: <DropdownMenuItem<int>>[
          for (final p in playlists)
            DropdownMenuItem<int>(value: p.id, child: Text(p.name)),
        ],
        onChanged: (id) {
          if (id != null) ref.read(currentPlaylistProvider.notifier).select(id);
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onImport});
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.playlist_play,
              size: 72, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(l10n.channelsEmpty, style: theme.textTheme.titleLarge),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onImport,
            icon: const Icon(Icons.playlist_add),
            label: Text(l10n.providersAddTitle),
          ),
        ],
      ),
    );
  }
}
