import 'package:flutter/foundation.dart';

/// How a channel's archive / catch-up URL is derived (spec Appendix D).
enum CatchupType { none, standard, append, shift, flussonic, xc, vod }

@immutable
class CatchupInfo {
  const CatchupInfo({
    this.type = CatchupType.none,
    this.source,
    this.days = 0,
    this.correctionHours = 0,
  });

  final CatchupType type;
  final String? source;
  final int days;
  final int correctionHours;

  bool get hasArchive => type != CatchupType.none || days > 0;

  CatchupInfo copyWith({CatchupType? type, String? source, int? days, int? correctionHours}) =>
      CatchupInfo(
        type: type ?? this.type,
        source: source ?? this.source,
        days: days ?? this.days,
        correctionHours: correctionHours ?? this.correctionHours,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type.name,
        if (source != null) 'source': source,
        'days': days,
        'correction': correctionHours,
      };

  factory CatchupInfo.fromJson(Map<String, dynamic> j) => CatchupInfo(
        type: CatchupType.values.firstWhere(
          (t) => t.name == j['type'],
          orElse: () => CatchupType.none,
        ),
        source: j['source'] as String?,
        days: (j['days'] as num?)?.toInt() ?? 0,
        correctionHours: (j['correction'] as num?)?.toInt() ?? 0,
      );
}

/// A single playable channel (live or radio). Engine-agnostic; the playback
/// layer turns [url] (+ [headers]) into a stream. Parsed from M3U today; the
/// same shape is produced by every provider (spec §4/§5).
@immutable
class Channel {
  const Channel({
    required this.id,
    required this.name,
    required this.url,
    this.alternateUrls = const <String>[],
    this.group,
    this.logoUrl,
    this.epgId,
    this.epgAliases = const <String>[],
    this.isRadio = false,
    this.number,
    this.catchup = const CatchupInfo(),
    this.headers = const <String, String>{},
    this.props = const <String, String>{},
  });

  /// Stable id within a source — `tvg-id` when present, else a name+url hash.
  final String id;
  final String name;
  final String url;
  final List<String> alternateUrls;
  final String? group;
  final String? logoUrl;

  /// `tvg-id` used to bind EPG (Milestone 4).
  final String? epgId;
  final List<String> epgAliases;

  final bool isRadio;
  final int? number;
  final CatchupInfo catchup;

  /// Per-channel HTTP headers (User-Agent / Referer / auth).
  final Map<String, String> headers;

  /// Misc passthrough properties (Kodi props, VLC opts not otherwise mapped).
  final Map<String, String> props;

  bool get hasArchive => catchup.hasArchive;

  Channel copyWith({int? number, String? group}) => Channel(
        id: id,
        name: name,
        url: url,
        alternateUrls: alternateUrls,
        group: group ?? this.group,
        logoUrl: logoUrl,
        epgId: epgId,
        epgAliases: epgAliases,
        isRadio: isRadio,
        number: number ?? this.number,
        catchup: catchup,
        headers: headers,
        props: props,
      );

  @override
  bool operator ==(Object other) => other is Channel && other.id == id && other.url == url;

  @override
  int get hashCode => Object.hash(id, url);
}
