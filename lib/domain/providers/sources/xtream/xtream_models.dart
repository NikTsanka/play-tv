import 'dart:convert';

/// Typed views over the Xtream Codes `player_api.php` JSON (spec Appendix A).
/// All parsing is tolerant: panels vary and send numbers as strings, so every
/// accessor coerces defensively.

int? _asInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v.trim());
  return null;
}

String _asString(dynamic v) => v?.toString() ?? '';

/// Account + server info from a no-action login call (A.1).
class XtreamAccount {
  XtreamAccount({
    required this.authenticated,
    required this.status,
    required this.expDate,
    required this.maxConnections,
    required this.serverProtocol,
    required this.serverUrl,
    required this.serverPort,
    required this.allowedFormats,
  });

  final bool authenticated;
  final String status;
  final DateTime? expDate;
  final int maxConnections;
  final String? serverProtocol;
  final String? serverUrl;
  final String? serverPort;
  final List<String> allowedFormats;

  bool get isActive => authenticated && status.toLowerCase() == 'active';

  factory XtreamAccount.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> user =
        (json['user_info'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{};
    final Map<String, dynamic> server =
        (json['server_info'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{};
    final int? exp = _asInt(user['exp_date']);
    return XtreamAccount(
      authenticated: _asInt(user['auth']) == 1,
      status: _asString(user['status']),
      expDate: exp == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true),
      maxConnections: _asInt(user['max_connections']) ?? 1,
      serverProtocol: (server['server_protocol'] as Object?)?.toString(),
      serverUrl: (server['url'] as Object?)?.toString(),
      serverPort: (server['port'] as Object?)?.toString(),
      allowedFormats: (user['allowed_output_formats'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const <String>[],
    );
  }
}

/// A live / VOD / series category (A.2).
class XtreamCategory {
  XtreamCategory({required this.id, required this.name});

  final String id;
  final String name;

  factory XtreamCategory.fromJson(Map<String, dynamic> json) => XtreamCategory(
        id: _asString(json['category_id']),
        name: _asString(json['category_name']),
      );
}

/// A live stream item (A.3).
class XtreamLiveStream {
  XtreamLiveStream({
    required this.streamId,
    required this.name,
    required this.num,
    required this.icon,
    required this.epgChannelId,
    required this.categoryId,
    required this.archiveDays,
  });

  final int streamId;
  final String name;
  final int? num;
  final String? icon;
  final String? epgChannelId;
  final String? categoryId;

  /// Catch-up depth in days (`tv_archive_duration`); 0 = no archive.
  final int archiveDays;

  bool get hasArchive => archiveDays > 0;

  factory XtreamLiveStream.fromJson(Map<String, dynamic> json) {
    final int archive =
        _asInt(json['tv_archive']) == 1 ? (_asInt(json['tv_archive_duration']) ?? 0) : 0;
    return XtreamLiveStream(
      streamId: _asInt(json['stream_id']) ?? 0,
      name: _asString(json['name']),
      num: _asInt(json['num']),
      icon: (json['stream_icon'] as Object?)?.toString(),
      epgChannelId: (json['epg_channel_id'] as Object?)?.toString(),
      categoryId: (json['category_id'] as Object?)?.toString(),
      archiveDays: archive,
    );
  }
}

/// A VOD (movie) list item (A.4).
class XtreamVodStream {
  XtreamVodStream({
    required this.streamId,
    required this.name,
    required this.icon,
    required this.categoryId,
    required this.containerExtension,
    required this.rating,
  });

  final int streamId;
  final String name;
  final String? icon;
  final String? categoryId;
  final String containerExtension;
  final String? rating;

  factory XtreamVodStream.fromJson(Map<String, dynamic> json) => XtreamVodStream(
        streamId: _asInt(json['stream_id']) ?? 0,
        name: _asString(json['name']),
        icon: (json['stream_icon'] as Object?)?.toString(),
        categoryId: (json['category_id'] as Object?)?.toString(),
        containerExtension: _asString(json['container_extension']).isEmpty
            ? 'mp4'
            : _asString(json['container_extension']),
        rating: (json['rating'] as Object?)?.toString(),
      );
}

/// A series list item (A.5).
class XtreamSeries {
  XtreamSeries({
    required this.seriesId,
    required this.name,
    required this.cover,
    required this.categoryId,
    required this.plot,
  });

  final int seriesId;
  final String name;
  final String? cover;
  final String? categoryId;
  final String? plot;

  factory XtreamSeries.fromJson(Map<String, dynamic> json) => XtreamSeries(
        seriesId: _asInt(json['series_id']) ?? 0,
        name: _asString(json['name']),
        cover: (json['cover'] as Object?)?.toString(),
        categoryId: (json['category_id'] as Object?)?.toString(),
        plot: (json['plot'] as Object?)?.toString(),
      );
}

/// A single episode under a season (A.5 `get_series_info`).
class XtreamEpisode {
  XtreamEpisode({
    required this.id,
    required this.title,
    required this.season,
    required this.episodeNum,
    required this.containerExtension,
  });

  final String id;
  final String title;
  final int season;
  final int? episodeNum;
  final String containerExtension;

  factory XtreamEpisode.fromJson(Map<String, dynamic> json) => XtreamEpisode(
        id: _asString(json['id']),
        title: _asString(json['title']),
        season: _asInt(json['season']) ?? 0,
        episodeNum: _asInt(json['episode_num']),
        containerExtension: _asString(json['container_extension']).isEmpty
            ? 'mp4'
            : _asString(json['container_extension']),
      );
}

/// A short-EPG listing (A.6). `title`/`description` arrive Base64-encoded.
class XtreamEpgListing {
  XtreamEpgListing({
    required this.title,
    required this.description,
    required this.start,
    required this.stop,
  });

  final String title;
  final String description;
  final DateTime? start;
  final DateTime? stop;

  factory XtreamEpgListing.fromJson(Map<String, dynamic> json) {
    final int? startTs = _asInt(json['start_timestamp']);
    final int? stopTs = _asInt(json['stop_timestamp']);
    return XtreamEpgListing(
      title: _decodeB64(_asString(json['title'])),
      description: _decodeB64(_asString(json['description'])),
      start: startTs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(startTs * 1000, isUtc: true),
      stop: stopTs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(stopTs * 1000, isUtc: true),
    );
  }

  static String _decodeB64(String s) {
    if (s.isEmpty) return '';
    try {
      return utf8.decode(base64.decode(base64.normalize(s)));
    } catch (_) {
      return s; // Some panels send plain text.
    }
  }
}
