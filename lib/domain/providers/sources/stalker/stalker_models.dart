// Typed views over Stalker / Ministra portal JSON (spec Appendix B). Field
// names vary across forks, so parsing is tolerant.

String _asString(dynamic v) => v?.toString() ?? '';

int? _asInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v.trim());
  return null;
}

/// A live genre / category (`type=itv&action=get_genres`).
class StalkerGenre {
  StalkerGenre({required this.id, required this.title});

  final String id;
  final String title;

  factory StalkerGenre.fromJson(Map<String, dynamic> json) => StalkerGenre(
        id: _asString(json['id']),
        title: _asString(json['title']),
      );
}

/// A channel item from `get_all_channels` / `get_ordered_list` (`js.data[]`).
class StalkerChannel {
  StalkerChannel({
    required this.id,
    required this.name,
    required this.number,
    required this.cmd,
    required this.logo,
    required this.genreId,
    required this.xmltvId,
  });

  final String id;
  final String name;
  final int? number;

  /// The raw `cmd` (e.g. `ffmpeg http://localhost/ch/1234_`); resolved to a
  /// playable URL on demand via `create_link`.
  final String cmd;
  final String? logo;
  final String? genreId;
  final String? xmltvId;

  factory StalkerChannel.fromJson(Map<String, dynamic> json) => StalkerChannel(
        id: _asString(json['id']),
        name: _asString(json['name']),
        number: _asInt(json['number']),
        cmd: _asString(json['cmd']),
        logo: (json['logo'] as Object?)?.toString(),
        genreId: (json['tv_genre_id'] as Object?)?.toString(),
        xmltvId: (json['xmltv_id'] as Object?)?.toString(),
      );
}

/// One page of an ordered list: rows + pagination counters.
class StalkerPage {
  StalkerPage({
    required this.channels,
    required this.totalItems,
    required this.maxPageItems,
  });

  final List<StalkerChannel> channels;
  final int totalItems;
  final int maxPageItems;

  factory StalkerPage.fromJs(dynamic js) {
    if (js is! Map) {
      return StalkerPage(
          channels: const <StalkerChannel>[], totalItems: 0, maxPageItems: 0);
    }
    final dynamic data = js['data'];
    final List<StalkerChannel> channels = data is List
        ? data
            .whereType<Map>()
            .map((e) => StalkerChannel.fromJson(e.cast<String, dynamic>()))
            .toList()
        : const <StalkerChannel>[];
    return StalkerPage(
      channels: channels,
      totalItems: _asInt(js['total_items']) ?? channels.length,
      maxPageItems: _asInt(js['max_page_items']) ?? channels.length,
    );
  }
}
