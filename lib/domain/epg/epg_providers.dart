import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../channels/channels_providers.dart';
import 'epg_matcher.dart';
import 'epg_models.dart';
import 'storage/epg_repository.dart';

final epgRepositoryProvider = Provider<EpgRepository>((ref) {
  return EpgRepository(ref.watch(appDatabaseProvider));
});

/// Number of stored programmes — drives "EPG loaded?" UI and recomputation.
final epgProgrammeCountProvider = StreamProvider<int>((ref) {
  return ref.watch(epgRepositoryProvider).watchProgrammeCount();
});

/// All EPG channels (refreshed when the store changes).
final epgChannelsProvider = FutureProvider<List<EpgChannel>>((ref) {
  ref.watch(epgProgrammeCountProvider);
  return ref.watch(epgRepositoryProvider).epgChannels();
});

/// domain channel id → EPG channel id (tvg-id, then normalized-name match).
final channelEpgMapProvider = FutureProvider<Map<String, String>>((ref) async {
  final channels = ref.watch(flatChannelsProvider);
  final epg = await ref.watch(epgChannelsProvider.future);
  return buildChannelEpgMap(channels, epg);
});

/// Ticks every 30s so now/next and the grid now-line stay current.
final epgClockProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream<DateTime>.periodic(
      const Duration(seconds: 30), (_) => DateTime.now());
});

/// Now/next for a domain channel id (empty if unmatched / no guide).
final nowNextProvider =
    FutureProvider.family<NowNext, String>((ref, channelId) async {
  final clock = ref.watch(epgClockProvider).valueOrNull ?? DateTime.now();
  final map = await ref.watch(channelEpgMapProvider.future);
  final epgId = map[channelId];
  if (epgId == null) return NowNext.empty;
  return ref.watch(epgRepositoryProvider).nowNext(epgId, at: clock);
});
