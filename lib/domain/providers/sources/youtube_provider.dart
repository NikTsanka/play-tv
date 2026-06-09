import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yte;

import '../../channels/channel.dart';
import '../provider.dart';
import '../provider_config.dart';
import '../provider_type.dart';

/// YouTube source (spec §4.6, feature-flagged). Turns a channel / playlist /
/// video URL into playable entries; stream URLs are short-lived, so they're
/// resolved per-zap via [resolveStreamUrl]. Uses `youtube_explode_dart`.
class YoutubeProvider extends Provider {
  YoutubeProvider(this.config);

  final ProviderConfig config;
  yte.YoutubeExplode? _yt;

  /// Cap to keep a big channel/playlist fetch bounded.
  static const int _maxVideos = 200;

  yte.YoutubeExplode get _client => _yt ??= yte.YoutubeExplode();

  @override
  String get caption => config.caption;

  @override
  ProviderType get type => ProviderType.youtube;

  @override
  Set<ProviderFunction> get availableFunctions => const <ProviderFunction>{
        ProviderFunction.live,
        ProviderFunction.vod,
        ProviderFunction.logos,
      };

  @override
  Duration get updateInterval => config.updateInterval;

  @override
  Future<void> fetchChannelList(ChannelSink sink, CancelToken ct) async {
    final String url = config.location.trim();
    final List<yte.Video> videos = await _collect(url, ct);

    for (int i = 0; i < videos.length; i++) {
      final yte.Video v = videos[i];
      sink.add(Channel(
        id: 'yt:${v.id.value}',
        name: v.title,
        // Resolved per zap; YouTube stream URLs expire.
        url: '',
        logoUrl: v.thumbnails.mediumResUrl,
        number: i + 1,
        props: <String, String>{'videoId': v.id.value},
      ));
    }
  }

  Future<List<yte.Video>> _collect(String url, CancelToken ct) async {
    final List<yte.Video> out = <yte.Video>[];

    final String? playlistId = yte.PlaylistId.parsePlaylistId(url);
    if (playlistId != null) {
      await for (final yte.Video v
          in _client.playlists.getVideos(yte.PlaylistId(playlistId)).take(_maxVideos)) {
        ct.throwIfCancelled();
        out.add(v);
      }
      return out;
    }

    final String? videoId = yte.VideoId.parseVideoId(url);
    if (videoId != null) {
      out.add(await _client.videos.get(yte.VideoId(videoId)));
      return out;
    }

    final yte.ChannelId? channelId = _channelId(url);
    if (channelId != null) {
      await for (final yte.Video v
          in _client.channels.getUploads(channelId).take(_maxVideos)) {
        ct.throwIfCancelled();
        out.add(v);
      }
      return out;
    }

    throw Exception('Unrecognized YouTube URL');
  }

  yte.ChannelId? _channelId(String url) {
    final RegExpMatch? m =
        RegExp(r'/channel/([A-Za-z0-9_\-]+)').firstMatch(url);
    return m == null ? null : yte.ChannelId(m.group(1)!);
  }

  @override
  Future<String?> resolveStreamUrl(Channel channel) async {
    final String? videoId = channel.props['videoId'];
    if (videoId == null || videoId.isEmpty) return null;
    try {
      final yte.StreamManifest manifest =
          await _client.videos.streamsClient.getManifest(yte.VideoId(videoId));
      if (manifest.muxed.isNotEmpty) {
        return manifest.muxed.withHighestBitrate().url.toString();
      }
      if (manifest.streams.isNotEmpty) {
        return manifest.streams.first.url.toString();
      }
    } catch (_) {
      // Fall through to null → caller keeps the (empty) static URL.
    }
    return null;
  }

  @override
  Future<void> dispose() async {
    _yt?.close();
    _yt = null;
  }
}
