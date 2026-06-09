import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../domain/playback/playback_providers.dart';
import '../../../domain/playback/playback_status.dart';
import 'player_controls.dart';

/// The reusable video surface: the media_kit [Video] with an auto-hiding,
/// gold-themed controls overlay. Used both inline and in the fullscreen route.
class PlayerSurface extends ConsumerStatefulWidget {
  const PlayerSurface({
    required this.isFullscreen,
    required this.onToggleFullscreen,
    super.key,
  });

  final bool isFullscreen;
  final VoidCallback onToggleFullscreen;

  @override
  ConsumerState<PlayerSurface> createState() => _PlayerSurfaceState();
}

class _PlayerSurfaceState extends ConsumerState<PlayerSurface> {
  static const List<BoxFit> _fits = <BoxFit>[
    BoxFit.contain,
    BoxFit.cover,
    BoxFit.fill,
  ];
  int _fitIndex = 0;
  bool _controlsVisible = true;
  Timer? _hideTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  void _showControls() {
    _hideTimer?.cancel();
    if (!_controlsVisible) setState(() => _controlsVisible = true);
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _controlsVisible = false);
    });
  }

  void _snapshot() async {
    final engine = ref.read(playbackEngineProvider);
    final messenger = ScaffoldMessenger.maybeOf(context);
    final dir = await Directory.systemTemp.createTemp('streamhub_shot');
    final path = '${dir.path}/frame.png';
    final ok = await engine.snapshot(path);
    messenger?.showSnackBar(SnackBar(
      content: Text(ok ? 'Snapshot saved: $path' : 'Snapshot not available'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final engine = ref.watch(playbackEngineProvider);
    final status = ref.watch(currentStatusProvider);

    // Keep the screen awake only while actively playing.
    ref.listen<PlaybackStatus>(currentStatusProvider, (prev, next) {
      if (next.isPlaying) {
        WakelockPlus.enable();
      } else {
        WakelockPlus.disable();
      }
    });

    final bool showSpinner = status.state == PlaybackState.opening ||
        status.state == PlaybackState.buffering;

    return MouseRegion(
      onHover: (_) => _showControls(),
      child: GestureDetector(
        onTap: () => setState(() => _controlsVisible = !_controlsVisible),
        onDoubleTap: widget.onToggleFullscreen,
        child: ColoredBox(
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Video(
                controller: engine.videoController,
                controls: NoVideoControls,
                fit: _fits[_fitIndex],
              ),
              if (showSpinner)
                const Center(child: CircularProgressIndicator()),
              if (status.hasError)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      status.error ?? 'Playback error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              AnimatedOpacity(
                opacity: _controlsVisible ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !_controlsVisible,
                  child: PlayerControls(
                    engine: engine,
                    status: status,
                    isFullscreen: widget.isFullscreen,
                    onCycleFit: () =>
                        setState(() => _fitIndex = (_fitIndex + 1) % _fits.length),
                    onToggleFullscreen: widget.onToggleFullscreen,
                    onSnapshot: _snapshot,
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
