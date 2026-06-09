import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/logging/app_logger.dart';
import '../playback/playback_providers.dart';
import '../playback/playback_status.dart';
import '../providers/stream_resolver.dart';
import 'channel.dart';
import 'channels_providers.dart';

@immutable
class ZapState {
  const ZapState({this.current, this.previous, this.numberEntry = ''});

  final Channel? current;
  final Channel? previous;

  /// In-progress channel-number entry (digits), shown on the OSD.
  final String numberEntry;

  ZapState copyWith({
    Object? current = _s,
    Object? previous = _s,
    String? numberEntry,
  }) =>
      ZapState(
        current: current == _s ? this.current : current as Channel?,
        previous: previous == _s ? this.previous : previous as Channel?,
        numberEntry: numberEntry ?? this.numberEntry,
      );

  static const Object _s = Object();
}

/// Owns "what's tuned" + zapping actions (up/down/number/last). Drives the
/// playback engine; the OSD watches [current] (spec §9).
class ZappingController extends Notifier<ZapState> {
  @override
  ZapState build() => const ZapState();

  List<Channel> get _channels => ref.read(flatChannelsProvider);

  Future<void> play(Channel channel) async {
    final engine = ref.read(playbackEngineProvider);
    state = state.copyWith(
      previous: state.current,
      current: channel,
      numberEntry: '',
    );

    // Session-based sources (Stalker/OTT) mint a fresh URL per zap; static
    // sources resolve to null and we play the channel's own URL.
    String url = channel.url;
    try {
      final sourceId = ref.read(currentPlaylistProvider);
      final resolved =
          await ref.read(streamResolverProvider).resolve(channel, sourceId);
      if (resolved != null && resolved.isNotEmpty) url = resolved;
    } catch (e) {
      log.w('Stream resolution failed, using static URL: $e');
    }

    await engine.open(PlayRequest(
      url: url,
      title: channel.name,
      headers: channel.headers,
      alternateUrls: channel.alternateUrls,
      isLiveHint: true,
    ));
  }

  Future<void> next() => _step(1);
  Future<void> previousChannel() => _step(-1);

  Future<void> _step(int delta) async {
    final list = _channels;
    if (list.isEmpty) return;
    final int idx = state.current == null ? -1 : list.indexOf(state.current!);
    final int nextIdx = (idx + delta) % list.length;
    await play(list[(nextIdx + list.length) % list.length]);
  }

  /// Tunes the most-recently-watched channel (last-channel toggle).
  Future<void> lastChannel() async {
    final prev = state.previous;
    if (prev != null) await play(prev);
  }

  void enterDigit(String digit) {
    if (digit.length != 1 || int.tryParse(digit) == null) return;
    state = state.copyWith(numberEntry: (state.numberEntry + digit).substring(
      state.numberEntry.length >= 5 ? 1 : 0,
    ));
  }

  Future<void> commitNumber() async {
    final entry = state.numberEntry;
    state = state.copyWith(numberEntry: '');
    final n = int.tryParse(entry);
    if (n == null) return;
    final match = _channels.where((c) => c.number == n).firstOrNull;
    if (match != null) await play(match);
  }

  void clearNumber() => state = state.copyWith(numberEntry: '');
}

final zappingProvider =
    NotifierProvider<ZappingController, ZapState>(ZappingController.new);
