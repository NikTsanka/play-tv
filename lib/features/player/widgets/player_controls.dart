import 'package:flutter/material.dart';

import '../../../domain/playback/playback_engine.dart';
import '../../../domain/playback/playback_status.dart';
import '../../../l10n/generated/app_localizations.dart';

String _fmt(Duration d) {
  final neg = d.isNegative;
  d = d.abs();
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  final core = h > 0 ? '$h:$m:$s' : '$m:$s';
  return neg ? '-$core' : core;
}

/// Gold-themed transport controls drawn on top of the video. Stateless: reads
/// [status] and drives [engine]; layout callbacks for fit/fullscreen come in.
class PlayerControls extends StatelessWidget {
  const PlayerControls({
    required this.engine,
    required this.status,
    required this.onCycleFit,
    required this.onToggleFullscreen,
    required this.isFullscreen,
    required this.onSnapshot,
    super.key,
  });

  final PlaybackEngine engine;
  final PlaybackStatus status;
  final VoidCallback onCycleFit;
  final VoidCallback onToggleFullscreen;
  final bool isFullscreen;
  final VoidCallback onSnapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    const onDark = Colors.white;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.black.withValues(alpha: 0.55),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.70),
          ],
          stops: const <double>[0, 0.22, 0.6, 1],
        ),
      ),
      child: Column(
        children: <Widget>[
          _TopBar(
            title: status.title,
            l10n: l10n,
            status: status,
            engine: engine,
            onCycleFit: onCycleFit,
            onSnapshot: onSnapshot,
            color: onDark,
          ),
          const Spacer(),
          // Center play/pause.
          IconButton.filled(
            iconSize: 44,
            style: IconButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: Colors.black,
            ),
            icon: Icon(status.isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: engine.playPause,
          ),
          const Spacer(),
          _BottomBar(
            status: status,
            engine: engine,
            l10n: l10n,
            accent: scheme.primary,
            color: onDark,
            isFullscreen: isFullscreen,
            onToggleFullscreen: onToggleFullscreen,
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.l10n,
    required this.status,
    required this.engine,
    required this.onCycleFit,
    required this.onSnapshot,
    required this.color,
  });

  final String? title;
  final AppLocalizations l10n;
  final PlaybackStatus status;
  final PlaybackEngine engine;
  final VoidCallback onCycleFit;
  final VoidCallback onSnapshot;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title ?? l10n.playerNoMedia,
              style: TextStyle(
                  color: color, fontSize: 16, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (status.audioTracks.length > 1)
            _TrackMenu(
              icon: Icons.audiotrack,
              tooltip: l10n.playerAudioTrack,
              tracks: status.audioTracks,
              activeId: status.activeAudioId,
              allowOff: false,
              color: color,
              onSelected: engine.setAudioTrack,
            ),
          if (status.subtitleTracks.isNotEmpty)
            _TrackMenu(
              icon: Icons.subtitles,
              tooltip: l10n.playerSubtitles,
              tracks: status.subtitleTracks,
              activeId: status.activeSubtitleId,
              allowOff: true,
              offLabel: l10n.playerSubtitlesOff,
              color: color,
              onSelected: engine.setSubtitleTrack,
            ),
          IconButton(
            tooltip: l10n.playerAspect,
            color: color,
            icon: const Icon(Icons.aspect_ratio),
            onPressed: onCycleFit,
          ),
          IconButton(
            tooltip: l10n.playerSnapshot,
            color: color,
            icon: const Icon(Icons.photo_camera_outlined),
            onPressed: onSnapshot,
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.status,
    required this.engine,
    required this.l10n,
    required this.accent,
    required this.color,
    required this.isFullscreen,
    required this.onToggleFullscreen,
  });

  final PlaybackStatus status;
  final PlaybackEngine engine;
  final AppLocalizations l10n;
  final Color accent;
  final Color color;
  final bool isFullscreen;
  final VoidCallback onToggleFullscreen;

  @override
  Widget build(BuildContext context) {
    final double dur = status.duration.inMilliseconds.toDouble();
    final double pos =
        status.position.inMilliseconds.clamp(0, dur < 0 ? 0 : dur).toDouble();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (status.isLive)
            Row(
              children: <Widget>[
                _LiveBadge(accent: accent),
                const Spacer(),
              ],
            )
          else
            Row(
              children: <Widget>[
                Text(_fmt(status.position), style: TextStyle(color: color)),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: accent,
                      thumbColor: accent,
                      inactiveTrackColor: color.withValues(alpha: 0.3),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 14),
                    ),
                    child: Slider(
                      value: dur > 0 ? pos : 0,
                      max: dur > 0 ? dur : 1,
                      onChanged: status.canSeek
                          ? (v) => engine
                              .seek(Duration(milliseconds: v.toInt()))
                          : null,
                    ),
                  ),
                ),
                Text(_fmt(status.duration), style: TextStyle(color: color)),
              ],
            ),
          Row(
            children: <Widget>[
              IconButton(
                color: color,
                tooltip: status.muted ? l10n.playerUnmute : l10n.playerMute,
                icon: Icon(status.muted || status.volume == 0
                    ? Icons.volume_off
                    : Icons.volume_up),
                onPressed: () => engine.setMuted(!status.muted),
              ),
              SizedBox(
                width: 120,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: accent,
                    thumbColor: accent,
                    inactiveTrackColor: color.withValues(alpha: 0.3),
                  ),
                  child: Slider(
                    value: status.muted ? 0 : status.volume,
                    max: 100,
                    onChanged: (v) => engine.setVolume(v),
                  ),
                ),
              ),
              IconButton(
                color: color,
                tooltip: l10n.playerStop,
                icon: const Icon(Icons.stop),
                onPressed: engine.stop,
              ),
              const Spacer(),
              if (status.width != null && status.height != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text('${status.width}×${status.height}',
                      style: TextStyle(
                          color: color.withValues(alpha: 0.7), fontSize: 12)),
                ),
              IconButton(
                color: color,
                tooltip: l10n.playerFullscreen,
                icon: Icon(
                    isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen),
                onPressed: onToggleFullscreen,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text('LIVE',
          style: TextStyle(
              color: Colors.black,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1)),
    );
  }
}

class _TrackMenu extends StatelessWidget {
  const _TrackMenu({
    required this.icon,
    required this.tooltip,
    required this.tracks,
    required this.activeId,
    required this.allowOff,
    required this.color,
    required this.onSelected,
    this.offLabel,
  });

  final IconData icon;
  final String tooltip;
  final List<MediaTrack> tracks;
  final String? activeId;
  final bool allowOff;
  final String? offLabel;
  final Color color;
  final void Function(String? id) onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String?>(
      tooltip: tooltip,
      icon: Icon(icon, color: color),
      onSelected: onSelected,
      itemBuilder: (context) => <PopupMenuEntry<String?>>[
        if (allowOff)
          CheckedPopupMenuItem<String?>(
            value: null,
            checked: activeId == null || activeId == 'no',
            child: Text(offLabel ?? 'Off'),
          ),
        for (final t in tracks.where((t) => t.id != 'no' && t.id != 'auto'))
          CheckedPopupMenuItem<String?>(
            value: t.id,
            checked: t.id == activeId,
            child: Text(t.label),
          ),
      ],
    );
  }
}
