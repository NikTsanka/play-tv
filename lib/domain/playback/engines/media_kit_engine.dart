import 'dart:async';
import 'dart:io';

import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../core/logging/app_logger.dart';
import '../playback_engine.dart';
import '../playback_status.dart';

/// Primary engine: media_kit (libmpv + FFmpeg). Covers HTTP(S)/HLS/DASH/RTSP/
/// RTP-UDP/SRT/local files with hardware decoding and multi-track support.
class MediaKitEngine implements PlaybackEngine {
  MediaKitEngine() {
    _controller = VideoController(_player);
    _wire();
    // Drive volume/mute from our own fields for predictable mute emulation.
    _player.setVolume(_userVolume);
  }

  final Player _player = Player();
  late final VideoController _controller;

  /// Exposed so the media_kit `Video` widget can attach to this engine.
  VideoController get videoController => _controller;

  final StreamController<PlaybackStatus> _statusCtrl =
      StreamController<PlaybackStatus>.broadcast();
  final List<StreamSubscription<dynamic>> _subs = <StreamSubscription<dynamic>>[];

  PlaybackStatus _status = const PlaybackStatus();
  PlayRequest? _request;
  List<String> _pendingFallbacks = <String>[];

  // Local mirrors used to derive the high-level state.
  bool _playing = false;
  bool _buffering = false;
  bool _completed = false;
  double _userVolume = 100;
  bool _muted = false;

  @override
  String get id => 'media_kit';

  @override
  PlaybackStatus get status => _status;

  @override
  Stream<PlaybackStatus> get statusStream => _statusCtrl.stream;

  void _wire() {
    final s = _player.stream;
    _subs.addAll(<StreamSubscription<dynamic>>[
      s.playing.listen((v) {
        _playing = v;
        _recompute();
      }),
      s.buffering.listen((v) {
        _buffering = v;
        _recompute();
      }),
      s.completed.listen((v) {
        _completed = v;
        _recompute();
      }),
      s.position.listen((v) => _emit(_status.copyWith(position: v))),
      s.duration.listen((v) => _emit(
            _status.copyWith(
              duration: v,
              isLive: (_request?.isLiveHint ?? false) || v <= Duration.zero,
            ),
          )),
      s.buffer.listen((v) => _emit(_status.copyWith(buffered: v))),
      s.rate.listen((v) => _emit(_status.copyWith(rate: v))),
      s.width.listen((v) => _emit(_status.copyWith(width: v))),
      s.height.listen((v) => _emit(_status.copyWith(height: v))),
      s.tracks.listen((t) => _emit(_status.copyWith(
            audioTracks: _map(t.audio),
            subtitleTracks: _map(t.subtitle),
          ))),
      s.track.listen((t) => _emit(_status.copyWith(
            activeAudioId: t.audio.id,
            activeSubtitleId: t.subtitle.id,
          ))),
      s.error.listen(_onError),
    ]);
  }

  List<MediaTrack> _map(List<dynamic> tracks) => tracks
      .map((dynamic t) => MediaTrack(
            id: t.id as String?,
            title: t.title as String?,
            language: t.language as String?,
          ))
      .toList(growable: false);

  void _recompute() {
    final PlaybackState next;
    if (_completed) {
      next = PlaybackState.ended;
    } else if (_buffering) {
      next = PlaybackState.buffering;
    } else if (_playing) {
      next = PlaybackState.playing;
    } else if (_status.state == PlaybackState.idle ||
        _status.state == PlaybackState.opening ||
        _status.state == PlaybackState.error) {
      next = _status.state;
    } else {
      next = PlaybackState.paused;
    }
    // Clear error message when playback recovers.
    if (_status.hasError && next != PlaybackState.error) {
      _emit(_status.copyWith(state: next, error: null));
    } else {
      _emit(_status.copyWith(state: next));
    }
  }

  void _emit(PlaybackStatus next) {
    _status = next;
    if (!_statusCtrl.isClosed) _statusCtrl.add(next);
  }

  Future<void> _onError(String message) async {
    log.w('Playback error: $message');
    // Robustness (spec §8): fall back to alternate URLs in order.
    if (_pendingFallbacks.isNotEmpty && _request != null) {
      final String nextUrl = _pendingFallbacks.removeAt(0);
      log.i('Trying fallback URL: $nextUrl');
      await _player.open(
        Media(nextUrl, httpHeaders: _request!.headers),
        play: true,
      );
      return;
    }
    _completed = false;
    _emit(_status.copyWith(state: PlaybackState.error, error: message));
  }

  @override
  Future<void> open(PlayRequest request) async {
    _request = request;
    _pendingFallbacks = List<String>.of(request.alternateUrls);
    _completed = false;
    _emit(_status.copyWith(
      state: PlaybackState.opening,
      title: request.title,
      isLive: request.isLiveHint,
      error: null,
      position: Duration.zero,
      duration: Duration.zero,
    ));
    await _player.open(
      Media(request.url, httpHeaders: request.headers),
      play: request.autoplay,
    );
    if (request.startPosition != null) {
      await _player.seek(request.startPosition!);
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> playPause() => _player.playOrPause();

  @override
  Future<void> stop() async {
    await _player.stop();
    _playing = false;
    _buffering = false;
    _completed = false;
    _emit(_status.copyWith(state: PlaybackState.idle, position: Duration.zero));
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> setVolume(double volume) async {
    _userVolume = volume.clamp(0, 100).toDouble();
    if (!_muted) {
      await _player.setVolume(_userVolume);
    }
    _emit(_status.copyWith(volume: _userVolume));
  }

  @override
  Future<void> setMuted(bool muted) async {
    _muted = muted;
    await _player.setVolume(muted ? 0 : _userVolume);
    _emit(_status.copyWith(muted: muted, volume: _userVolume));
  }

  @override
  Future<void> setRate(double rate) => _player.setRate(rate);

  @override
  Future<void> setAudioTrack(String? id) async {
    final AudioTrack track = id == null
        ? AudioTrack.auto()
        : _player.state.tracks.audio.firstWhere(
            (t) => t.id == id,
            orElse: AudioTrack.auto,
          );
    await _player.setAudioTrack(track);
  }

  @override
  Future<void> setSubtitleTrack(String? id) async {
    final SubtitleTrack track = (id == null || id == 'no')
        ? SubtitleTrack.no()
        : _player.state.tracks.subtitle.firstWhere(
            (t) => t.id == id,
            orElse: SubtitleTrack.no,
          );
    await _player.setSubtitleTrack(track);
  }

  @override
  Future<bool> snapshot(String filePath) async {
    final bytes = await _player.screenshot(format: 'image/png');
    if (bytes == null) return false;
    await File(filePath).writeAsBytes(bytes);
    return true;
  }

  @override
  Future<void> dispose() async {
    for (final sub in _subs) {
      await sub.cancel();
    }
    await _statusCtrl.close();
    await _player.dispose();
  }
}
