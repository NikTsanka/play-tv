import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/playback/playback_providers.dart';
import '../../domain/playback/playback_status.dart';
import '../../l10n/generated/app_localizations.dart';
import 'widgets/open_url_dialog.dart';
import 'widgets/player_surface.dart';

class PlayerPage extends ConsumerWidget {
  const PlayerPage({super.key});

  Future<void> _open(BuildContext context, WidgetRef ref, String url) async {
    if (url.isEmpty) return;
    final engine = ref.read(playbackEngineProvider);
    await engine.open(PlayRequest(url: url, title: url));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final status = ref.watch(currentStatusProvider);
    final bool hasMedia = status.state != PlaybackState.idle;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navPlayer),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.playerOpenUrl,
            icon: const Icon(Icons.add_link),
            onPressed: () async {
              final url = await showOpenUrlDialog(context);
              if (url != null && context.mounted) {
                await _open(context, ref, url);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: hasMedia
          ? PlayerSurface(
              isFullscreen: false,
              onToggleFullscreen: () => _enterFullscreen(context),
            )
          : _EmptyState(
              onOpenUrl: () async {
                final url = await showOpenUrlDialog(context);
                if (url != null && context.mounted) {
                  await _open(context, ref, url);
                }
              },
              onPlayDemo: () => _open(context, ref, kDemoHlsUrl),
            ),
    );
  }

  void _enterFullscreen(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: true,
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
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onOpenUrl, required this.onPlayDemo});

  final VoidCallback onOpenUrl;
  final VoidCallback onPlayDemo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.smart_display_outlined,
              size: 72, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(l10n.playerNoMedia, style: theme.textTheme.titleLarge),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            children: <Widget>[
              FilledButton.icon(
                onPressed: onOpenUrl,
                icon: const Icon(Icons.add_link),
                label: Text(l10n.playerOpenUrl),
              ),
              OutlinedButton.icon(
                onPressed: onPlayDemo,
                icon: const Icon(Icons.play_circle_outline),
                label: Text(l10n.playerPlayDemo),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
