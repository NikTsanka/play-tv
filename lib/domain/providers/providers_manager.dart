import '../../core/logging/app_logger.dart';
import '../channels/channel.dart';
import '../channels/storage/channel_repository.dart';
import 'provider.dart';
import 'provider_config.dart';
import 'provider_type.dart';

/// Owns and persists every channel source (spec §2 — "A ProvidersManager owns &
/// persists them"). Bridges the [ProviderRegistry] (how to fetch) and the
/// [ChannelRepository] (where channels live), turning a [ProviderConfig] into
/// a stored, channel-bearing playlist.
class ProvidersManager {
  ProvidersManager(this._repo, this._registry);

  final ChannelRepository _repo;
  final ProviderRegistry _registry;

  ProviderRegistry get registry => _registry;

  /// All persisted provider configurations.
  Future<List<ProviderConfig>> list() => _repo.listProviderConfigs();

  /// Persists [config] (insert when [ProviderConfig.id] is null, else update)
  /// without fetching. Returns the source id.
  Future<int> save(ProviderConfig config) => _repo.upsertProviderConfig(config);

  Future<void> delete(int id) => _repo.deletePlaylist(id);

  /// Persists [config], runs its provider's channel fetch, and stores the
  /// resulting channels (replacing any previous ones). Also records the EPG url
  /// when the source advertises one. Returns the source id.
  ///
  /// Re-running against an existing config refreshes it in place (the auto-update
  /// path of spec §4 / §10).
  Future<int> import(ProviderConfig config, {CancelToken? cancelToken}) async {
    final CancelToken ct = cancelToken ?? CancelToken();
    final int id = await _repo.upsertProviderConfig(config);
    final ProviderConfig stored = config.copyWith(id: id);

    log.i('Importing provider "${stored.caption}" (${stored.type.id})');
    final Provider provider = _registry.build(stored);
    final CollectingChannelSink sink = CollectingChannelSink();
    try {
      await provider.fetchChannelList(sink, ct);
    } on ProviderCancelled {
      log.w('Import cancelled for "${stored.caption}"');
      rethrow;
    } finally {
      // The import-time instance is transient; the VOD/resolver paths build
      // their own. Release any session/client it opened.
      await provider.dispose();
    }

    await _repo.saveChannels(id, sink.channels);
    if (sink.epgUrlValue != null && sink.epgUrlValue!.isNotEmpty) {
      await _repo.updateEpgUrl(id, sink.epgUrlValue!);
    }
    log.i('Stored ${sink.channels.length} channels for source $id');
    return id;
  }

  /// Refreshes an already-persisted source from its provider.
  Future<int> refresh(ProviderConfig config, {CancelToken? cancelToken}) {
    assert(config.id != null, 'refresh() needs a persisted config');
    return import(config, cancelToken: cancelToken);
  }

  /// Convenience used by tests / callers needing the fetched channels directly.
  Future<List<Channel>> channelsOf(int id) => _repo.channelsOf(id);
}
