import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../channels/channels_providers.dart';
import 'provider_config.dart';
import 'provider_type.dart';
import 'providers_manager.dart';

/// The provider-type registry (single instance for the app session).
final providerRegistryProvider = Provider<ProviderRegistry>((ref) {
  return ProviderRegistry();
});

/// Owns & persists every channel source (spec §2).
final providersManagerProvider = Provider<ProvidersManager>((ref) {
  return ProvidersManager(
    ref.watch(channelRepositoryProvider),
    ref.watch(providerRegistryProvider),
  );
});

/// All persisted provider configurations, refreshed whenever the playlist set
/// changes (so add/delete is reflected in management UI).
final providerConfigsProvider = FutureProvider<List<ProviderConfig>>((ref) {
  // Re-run when playlists change.
  ref.watch(playlistsProvider);
  return ref.watch(providersManagerProvider).list();
});
