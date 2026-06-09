import 'package:http/http.dart' as http;

import '../../../channels/channel.dart';
import '../../../vod/vod_catalog.dart';
import '../../../vod/vod_models.dart';
import '../../provider.dart';
import '../../provider_config.dart';
import '../../provider_type.dart';
import 'xtream_client.dart';
import 'xtream_models.dart';

/// Xtream Codes provider (spec §4.2). Logs in, builds the live channel tree from
/// categories, hands the panel's `xmltv.php` to the EPG path, and exposes a
/// [VodCatalog] for the VOD browser (spec §7). Live URLs are deterministic, so
/// [resolveStreamUrl] stays the default no-op. The client is kept alive (logged
/// in once) and reused for channels + VOD; [dispose] closes it.
class XtreamProvider extends Provider {
  XtreamProvider(this.config, {http.Client? httpClient})
      : _injectedClient = httpClient;

  final ProviderConfig config;
  final http.Client? _injectedClient;
  XtreamClient? _clientInstance;
  late final VodCatalog _catalog = _XtreamVodCatalog(this);

  String get _baseUrl => config.location;
  String get _username => config.setting('username') ?? '';
  String get _password => config.setting('password') ?? '';

  XtreamClient get _client => _clientInstance ??= XtreamClient(
        baseUrl: _baseUrl,
        username: _username,
        password: _password,
        client: _injectedClient,
      );

  Future<void> _ensureLogin() async {
    if (_client.account == null) await _client.login();
  }

  @override
  String get caption => config.caption;

  @override
  ProviderType get type => ProviderType.xtream;

  @override
  Set<ProviderFunction> get availableFunctions => const <ProviderFunction>{
        ProviderFunction.live,
        ProviderFunction.vod,
        ProviderFunction.epg,
        ProviderFunction.catchup,
        ProviderFunction.logos,
      };

  @override
  Duration get updateInterval => config.updateInterval;

  @override
  VodCatalog? get vodCatalog => _catalog;

  @override
  Future<void> fetchChannelList(ChannelSink sink, CancelToken ct) async {
    await _ensureLogin();
    ct.throwIfCancelled();

    final List<XtreamCategory> categories = await _client.liveCategories();
    final Map<String, String> categoryNames = <String, String>{
      for (final XtreamCategory c in categories) c.id: c.name,
    };
    ct.throwIfCancelled();

    final List<XtreamLiveStream> streams = await _client.liveStreams();
    ct.throwIfCancelled();

    for (final XtreamLiveStream s in streams) {
      sink.add(Channel(
        id: 'xt:${s.streamId}',
        name: s.name,
        url: _client.liveUrl(s.streamId),
        group: categoryNames[s.categoryId],
        logoUrl: (s.icon != null && s.icon!.isNotEmpty) ? s.icon : null,
        epgId: (s.epgChannelId != null && s.epgChannelId!.isNotEmpty)
            ? s.epgChannelId
            : null,
        number: s.num,
        catchup: s.hasArchive
            ? CatchupInfo(type: CatchupType.xc, days: s.archiveDays)
            : const CatchupInfo(),
      ));
    }

    sink.epgUrl = _client.xmltvUrl();
  }

  @override
  Future<void> dispose() async {
    if (_injectedClient == null) _clientInstance?.close();
    _clientInstance = null;
  }
}

/// VOD catalog backed by [XtreamProvider]'s client (spec Appendix A.4/A.5).
class _XtreamVodCatalog implements VodCatalog {
  _XtreamVodCatalog(this._provider);

  final XtreamProvider _provider;
  XtreamClient get _c => _provider._client;

  @override
  Future<List<VodCategory>> movieCategories() async {
    await _provider._ensureLogin();
    return <VodCategory>[
      for (final XtreamCategory c in await _c.vodCategories())
        VodCategory(id: c.id, name: c.name),
    ];
  }

  @override
  Future<List<VodItem>> movies({String? categoryId}) async {
    await _provider._ensureLogin();
    final Map<String, String> names = <String, String>{
      for (final XtreamCategory c in await _c.vodCategories()) c.id: c.name,
    };
    final List<XtreamVodStream> streams =
        await _c.vodStreams(categoryId: categoryId);
    return <VodItem>[
      for (final XtreamVodStream s in streams)
        VodItem(
          id: '${s.streamId}',
          kind: VodKind.movie,
          title: s.name,
          cover: s.icon,
          categoryId: s.categoryId,
          categoryName: names[s.categoryId],
          rating: s.rating,
          url: _c.vodUrl(s.streamId, s.containerExtension),
        ),
    ];
  }

  @override
  Future<List<VodCategory>> seriesCategories() async {
    await _provider._ensureLogin();
    return <VodCategory>[
      for (final XtreamCategory c in await _c.seriesCategories())
        VodCategory(id: c.id, name: c.name),
    ];
  }

  @override
  Future<List<VodItem>> seriesEntries({String? categoryId}) async {
    await _provider._ensureLogin();
    final Map<String, String> names = <String, String>{
      for (final XtreamCategory c in await _c.seriesCategories()) c.id: c.name,
    };
    final List<XtreamSeries> series = await _c.seriesList(categoryId: categoryId);
    return <VodItem>[
      for (final XtreamSeries s in series)
        VodItem(
          id: '${s.seriesId}',
          kind: VodKind.series,
          title: s.name,
          cover: s.cover,
          categoryId: s.categoryId,
          categoryName: names[s.categoryId],
          plot: s.plot,
        ),
    ];
  }

  @override
  Future<List<VodEpisode>> episodes(VodItem series) async {
    await _provider._ensureLogin();
    final List<XtreamEpisode> eps =
        await _c.seriesEpisodes(int.tryParse(series.id) ?? 0);
    return <VodEpisode>[
      for (final XtreamEpisode e in eps)
        VodEpisode(
          id: e.id,
          title: e.title.isEmpty
              ? 'S${e.season}E${e.episodeNum ?? '?'}'
              : e.title,
          season: e.season,
          episode: e.episodeNum,
          url: _c.seriesEpisodeUrl(e.id, e.containerExtension),
        ),
    ];
  }
}
