import '../channels/channel.dart';
import '../vod/vod_catalog.dart';
import 'provider_type.dart';

/// Capabilities a provider can expose (spec §4). Used to drive which trees and
/// actions a source offers (live grid, VOD browser, EPG grid, catch-up, …).
enum ProviderFunction { live, vod, epg, catchup, radio, logos }

/// Where a provider's channel logos come from.
enum LogoSource { playlist, none }

/// Raised by [CancelToken.throwIfCancelled] when a fetch is aborted.
class ProviderCancelled implements Exception {
  const ProviderCancelled();
  @override
  String toString() => 'Provider fetch cancelled';
}

/// Cooperative cancellation handed into a long-running [Provider] fetch so the
/// UI can abort an import (spec §11 — all I/O is cancellable).
class CancelToken {
  bool _cancelled = false;

  bool get isCancelled => _cancelled;

  void cancel() => _cancelled = true;

  void throwIfCancelled() {
    if (_cancelled) throw const ProviderCancelled();
  }
}

/// Receives channels (and incidental metadata) emitted by a [Provider]. The
/// streaming shape lets huge sources push without buffering everything in the
/// provider itself.
abstract class ChannelSink {
  void add(Channel channel);
  void addAll(Iterable<Channel> channels);

  /// EPG guide URL discovered while fetching (e.g. an M3U `url-tvg` header).
  set epgUrl(String? url);
}

/// Default [ChannelSink] that buffers everything into a list — used by the
/// [ProvidersManager] before a single transactional persist.
class CollectingChannelSink implements ChannelSink {
  final List<Channel> channels = <Channel>[];
  String? epgUrlValue;

  @override
  void add(Channel channel) => channels.add(channel);

  @override
  void addAll(Iterable<Channel> cs) => channels.addAll(cs);

  @override
  set epgUrl(String? url) => epgUrlValue = url;
}

/// A channel source. Every backend — M3U, Generic URL, iptv-org today; Xtream,
/// Stalker and the OTT family in later milestones — implements this single
/// interface. Adding a source = adding a class + a [ProviderType] entry (spec §2).
abstract class Provider {
  /// Human label shown in the UI.
  String get caption;

  /// Which registry type produced this provider.
  ProviderType get type;

  /// Capabilities this instance offers.
  Set<ProviderFunction> get availableFunctions;

  /// How often the source should be auto-refreshed (spec §4 update interval).
  Duration get updateInterval;

  /// Where logos are sourced from.
  LogoSource get logoSource => LogoSource.playlist;

  /// Fetches the channel list into [sink]. Implementations own their network /
  /// file IO and must push heavy parsing onto an isolate (spec §12), checking
  /// [ct] between stages so imports stay cancellable.
  Future<void> fetchChannelList(ChannelSink sink, CancelToken ct);

  /// Resolves the actually-playable URL for [channel] at zap time. Most sources
  /// (M3U, Xtream, Generic) embed a static URL and return `null` here, meaning
  /// "play [Channel.url] as-is". Session-based portals (Stalker, OTT) override
  /// this to mint a short-lived URL on every zap (spec §4 — per-zap dynamic
  /// URL). Implementations should cache their session so this stays cheap.
  Future<String?> resolveStreamUrl(Channel channel) async => null;

  /// The VOD catalog for this source, or null if it serves live channels only
  /// (spec §7). Backed by the same session as the live fetch.
  VodCatalog? get vodCatalog => null;

  /// Releases any session/network resources held by the provider.
  Future<void> dispose() async {}
}
