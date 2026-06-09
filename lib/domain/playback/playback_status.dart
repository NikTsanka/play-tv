import 'package:flutter/foundation.dart';

/// High-level playback lifecycle state (engine-agnostic).
enum PlaybackState { idle, opening, buffering, playing, paused, ended, error }

/// A selectable audio or subtitle track exposed by an engine.
@immutable
class MediaTrack {
  const MediaTrack({
    required this.id,
    this.title,
    this.language,
  });

  /// `null` id is the conventional "no/disabled track" entry (e.g. subtitles off).
  final String? id;
  final String? title;
  final String? language;

  String get label {
    final parts = <String>[
      if (title != null && title!.isNotEmpty) title!,
      if (language != null && language!.isNotEmpty) '(${language!})',
    ];
    if (parts.isEmpty) return id ?? '—';
    return parts.join(' ');
  }

  @override
  bool operator ==(Object other) =>
      other is MediaTrack &&
      other.id == id &&
      other.title == title &&
      other.language == language;

  @override
  int get hashCode => Object.hash(id, title, language);
}

/// What to play, plus the network context needed to open it.
@immutable
class PlayRequest {
  const PlayRequest({
    required this.url,
    this.title,
    this.headers = const <String, String>{},
    this.isLiveHint = false,
    this.startPosition,
    this.alternateUrls = const <String>[],
    this.autoplay = true,
  });

  final String url;
  final String? title;

  /// Per-request HTTP headers (User-Agent / Referer / auth) — see spec §4/§12.
  final Map<String, String> headers;

  /// Caller's hint that this is a live stream (channels). Engines also infer
  /// liveness from an unknown/zero duration.
  final bool isLiveHint;

  final Duration? startPosition;

  /// Fallback URLs tried in order if the primary fails (spec §8 robustness).
  final List<String> alternateUrls;

  final bool autoplay;
}

/// Immutable snapshot of the active playback, emitted on every change.
@immutable
class PlaybackStatus {
  const PlaybackStatus({
    this.state = PlaybackState.idle,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.buffered = Duration.zero,
    this.isLive = false,
    this.volume = 100,
    this.muted = false,
    this.rate = 1.0,
    this.width,
    this.height,
    this.error,
    this.title,
    this.audioTracks = const <MediaTrack>[],
    this.subtitleTracks = const <MediaTrack>[],
    this.activeAudioId,
    this.activeSubtitleId,
  });

  final PlaybackState state;
  final Duration position;
  final Duration duration;
  final Duration buffered;
  final bool isLive;

  /// 0..100, matching media_kit's scale.
  final double volume;
  final bool muted;
  final double rate;
  final int? width;
  final int? height;
  final String? error;
  final String? title;

  final List<MediaTrack> audioTracks;
  final List<MediaTrack> subtitleTracks;
  final String? activeAudioId;
  final String? activeSubtitleId;

  bool get isPlaying => state == PlaybackState.playing;
  bool get isPaused => state == PlaybackState.paused;
  bool get hasError => state == PlaybackState.error;
  bool get canSeek => !isLive && duration > Duration.zero;
  double? get aspectRatio =>
      (width != null && height != null && height! > 0) ? width! / height! : null;

  PlaybackStatus copyWith({
    PlaybackState? state,
    Duration? position,
    Duration? duration,
    Duration? buffered,
    bool? isLive,
    double? volume,
    bool? muted,
    double? rate,
    int? width,
    int? height,
    Object? error = _sentinel,
    Object? title = _sentinel,
    List<MediaTrack>? audioTracks,
    List<MediaTrack>? subtitleTracks,
    Object? activeAudioId = _sentinel,
    Object? activeSubtitleId = _sentinel,
  }) {
    return PlaybackStatus(
      state: state ?? this.state,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      buffered: buffered ?? this.buffered,
      isLive: isLive ?? this.isLive,
      volume: volume ?? this.volume,
      muted: muted ?? this.muted,
      rate: rate ?? this.rate,
      width: width ?? this.width,
      height: height ?? this.height,
      error: error == _sentinel ? this.error : error as String?,
      title: title == _sentinel ? this.title : title as String?,
      audioTracks: audioTracks ?? this.audioTracks,
      subtitleTracks: subtitleTracks ?? this.subtitleTracks,
      activeAudioId:
          activeAudioId == _sentinel ? this.activeAudioId : activeAudioId as String?,
      activeSubtitleId: activeSubtitleId == _sentinel
          ? this.activeSubtitleId
          : activeSubtitleId as String?,
    );
  }

  static const Object _sentinel = Object();
}
