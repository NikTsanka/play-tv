import 'package:http/http.dart' as http;

import '../../../channels/channel.dart';
import '../../provider.dart';
import '../../provider_config.dart';
import '../../provider_type.dart';
import 'stalker_client.dart';
import 'stalker_models.dart';

/// Stalker / Ministra portal provider (spec §4.3). Builds the channel tree from
/// genres + ordered lists, storing each channel's `cmd`. The real stream URL is
/// minted per zap via [resolveStreamUrl] (`create_link`) since links are
/// short-lived. The portal session (handshake token) lives on a single cached
/// [StalkerClient], reused across zaps by the StreamResolver.
class StalkerProvider extends Provider {
  StalkerProvider(this.config, {http.Client? httpClient})
      : _injectedClient = httpClient;

  final ProviderConfig config;
  final http.Client? _injectedClient;
  StalkerClient? _client;

  String get _portalUrl => config.location;
  String get _mac => config.setting('mac') ?? '';

  StalkerClient get _portal => _client ??= StalkerClient(
        portalUrl: _portalUrl,
        mac: _mac,
        login: config.setting('login'),
        password: config.setting('password'),
        client: _injectedClient,
      );

  @override
  String get caption => config.caption;

  @override
  ProviderType get type => ProviderType.stalker;

  @override
  Set<ProviderFunction> get availableFunctions => const <ProviderFunction>{
        ProviderFunction.live,
        ProviderFunction.vod,
        ProviderFunction.epg,
        ProviderFunction.logos,
      };

  @override
  Duration get updateInterval => config.updateInterval;

  @override
  Future<void> fetchChannelList(ChannelSink sink, CancelToken ct) async {
    await _portal.ensureSession();
    ct.throwIfCancelled();

    final List<StalkerGenre> genres = await _portal.genres();
    final Map<String, String> genreNames = <String, String>{
      for (final StalkerGenre g in genres) g.id: g.title,
    };
    ct.throwIfCancelled();

    final List<StalkerChannel> channels = await _portal.allChannels();
    ct.throwIfCancelled();

    for (final StalkerChannel c in channels) {
      sink.add(Channel(
        id: 'stalker:${c.id}',
        name: c.name,
        // Static reference only; resolveStreamUrl mints the real URL per zap.
        url: c.cmd,
        group: genreNames[c.genreId],
        logoUrl: (c.logo != null && c.logo!.isNotEmpty) ? c.logo : null,
        epgId: (c.xmltvId != null && c.xmltvId!.isNotEmpty) ? c.xmltvId : null,
        number: c.number,
        props: <String, String>{'cmd': c.cmd},
      ));
    }
  }

  @override
  Future<String?> resolveStreamUrl(Channel channel) async {
    final String cmd = channel.props['cmd'] ?? channel.url;
    if (cmd.isEmpty) return null;
    return _portal.createLink(cmd);
  }

  @override
  Future<void> dispose() async {
    if (_injectedClient == null) _client?.close();
    _client = null;
  }
}
