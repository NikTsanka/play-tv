import 'playback_status.dart';

/// Engine-agnostic playback contract. Concrete engines (MediaKitEngine,
/// NativePlayerEngine, CastEngine) implement this; a `PlaybackEnginesManager`
/// (later milestone) picks one per item. See spec §8.
abstract interface class PlaybackEngine {
  /// Stable engine identifier, e.g. `media_kit`.
  String get id;

  /// Latest snapshot (synchronous access).
  PlaybackStatus get status;

  /// Snapshot stream — emits on every state/position/track change.
  Stream<PlaybackStatus> get statusStream;

  Future<void> open(PlayRequest request);
  Future<void> play();
  Future<void> pause();
  Future<void> playPause();
  Future<void> stop();
  Future<void> seek(Duration position);

  /// [volume] is 0..100.
  Future<void> setVolume(double volume);
  Future<void> setMuted(bool muted);
  Future<void> setRate(double rate);

  Future<void> setAudioTrack(String? id);
  Future<void> setSubtitleTrack(String? id);

  /// Captures a frame to [filePath] (PNG). Returns false if unsupported.
  Future<bool> snapshot(String filePath);

  Future<void> dispose();
}
