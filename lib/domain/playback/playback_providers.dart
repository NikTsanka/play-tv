import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'engines/media_kit_engine.dart';
import 'playback_status.dart';

/// The active playback engine. Created lazily on first read (so app boot and
/// non-player screens never touch native libmpv), disposed with the scope.
///
/// Milestone 2 ships a single MediaKitEngine. A `PlaybackEnginesManager`
/// (later) will pick between MediaKit / native / cast engines per item.
final playbackEngineProvider = Provider<MediaKitEngine>((ref) {
  final engine = MediaKitEngine();
  ref.onDispose(engine.dispose);
  return engine;
});

/// Reactive snapshot of the active playback, seeded with the current value.
final playbackStatusProvider = StreamProvider<PlaybackStatus>((ref) {
  final engine = ref.watch(playbackEngineProvider);
  return engine.statusStream;
});

/// Convenience: latest status (or idle before the first event).
final currentStatusProvider = Provider<PlaybackStatus>((ref) {
  final async = ref.watch(playbackStatusProvider);
  final engine = ref.watch(playbackEngineProvider);
  return async.maybeWhen(data: (s) => s, orElse: () => engine.status);
});
