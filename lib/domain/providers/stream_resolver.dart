import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../channels/channel.dart';
import '../channels/channels_providers.dart';
import '../channels/storage/channel_repository.dart';
import 'provider.dart' as domain;
import 'provider_config.dart';
import 'provider_type.dart';
import 'providers_providers.dart';

/// Resolves the playable URL for a channel just before it is opened, delegating
/// to the owning source's [domain.Provider]. Built providers are cached per
/// source id so a session-based portal (Stalker/OTT) keeps its handshake token
/// across zaps instead of re-authenticating every channel change.
class StreamResolver {
  StreamResolver(this._repo, this._registry);

  final ChannelRepository _repo;
  final ProviderRegistry _registry;
  final Map<int, domain.Provider> _providers = <int, domain.Provider>{};

  /// Returns a resolved URL for [channel], or `null` to play [Channel.url]
  /// as-is. Never throws — resolution failures fall back to the static URL.
  Future<String?> resolve(Channel channel, int? sourceId) async {
    if (sourceId == null) return null;
    final domain.Provider? provider = await providerFor(sourceId);
    if (provider == null) return null;
    return provider.resolveStreamUrl(channel);
  }

  /// The (cached) runtime provider for a source — shared by live resolution and
  /// the VOD browser so a session-based source authenticates once.
  Future<domain.Provider?> providerFor(int sourceId) async {
    final domain.Provider? cached = _providers[sourceId];
    if (cached != null) return cached;

    final ProviderConfig? config = await _repo.providerConfig(sourceId);
    if (config == null) return null;

    final domain.Provider provider = _registry.build(config);
    _providers[sourceId] = provider;
    return provider;
  }

  /// Drops a cached provider (e.g. after delete / credential change) so the next
  /// play re-authenticates.
  void invalidate(int sourceId) {
    _providers.remove(sourceId)?.dispose();
  }

  void dispose() {
    for (final domain.Provider p in _providers.values) {
      p.dispose();
    }
    _providers.clear();
  }
}

final streamResolverProvider = Provider<StreamResolver>((ref) {
  final StreamResolver resolver = StreamResolver(
    ref.watch(channelRepositoryProvider),
    ref.watch(providerRegistryProvider),
  );
  ref.onDispose(resolver.dispose);
  return resolver;
});
