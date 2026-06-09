import '../channel.dart';

/// Builds an archive / catch-up URL from a live URL + an EPG event window,
/// per spec Appendix D. Pure & testable. Used by the EPG catch-up action
/// (Milestone 4); defined here alongside the parser that fills [CatchupInfo].
class CatchupUrlBuilder {
  const CatchupUrlBuilder();

  /// Returns the archive URL, or `null` if catch-up isn't available.
  String? build({
    required String liveUrl,
    required CatchupInfo catchup,
    required DateTime startUtc,
    required DateTime endUtc,
  }) {
    if (!catchup.hasArchive) return null;

    final DateTime start =
        startUtc.toUtc().add(Duration(hours: catchup.correctionHours));
    final DateTime end =
        endUtc.toUtc().add(Duration(hours: catchup.correctionHours));
    final int durationSecs = end.difference(start).inSeconds.abs();
    final String? src = catchup.source;

    switch (catchup.type) {
      case CatchupType.append:
        return liveUrl + _expand(src ?? '', start, end, durationSecs);
      case CatchupType.shift:
        return src != null && src.isNotEmpty
            ? _expand(src, start, end, durationSecs)
            : _appendQuery(liveUrl, 'utc=${_unix(start)}&lutc=${_nowUnix()}');
      case CatchupType.flussonic:
        return src != null && src.isNotEmpty
            ? _expand(src, start, end, durationSecs)
            : _flussonicFromLive(liveUrl, start, durationSecs);
      case CatchupType.xc:
        return src != null && src.isNotEmpty
            ? _expand(src, start, end, durationSecs)
            : _xcFromLive(liveUrl, start, durationSecs);
      case CatchupType.vod:
        return src != null && src.isNotEmpty
            ? _expand(src, start, end, durationSecs)
            : liveUrl;
      case CatchupType.standard:
      case CatchupType.none:
        return src != null && src.isNotEmpty
            ? _expand(src, start, end, durationSecs)
            : _appendQuery(liveUrl, 'utc=${_unix(start)}&lutc=${_nowUnix()}');
    }
  }

  // ---- placeholder expansion ----------------------------------------------

  String _expand(String template, DateTime start, DateTime end, int durSecs) {
    final int s = _unix(start);
    final int e = _unix(end);
    final int now = _nowUnix();
    final Map<String, String> vars = <String, String>{
      'utc': '$s',
      'start': '$s',
      'utcend': '$e',
      'end': '$e',
      'lutc': '$now',
      'now': '$now',
      'timestamp': '$now',
      'duration': '$durSecs',
      'durmin': '${(durSecs / 60).round()}',
      'offset': '${now - s}',
      'Y': _pad(start.year, 4),
      'm': _pad(start.month, 2),
      'd': _pad(start.day, 2),
      'H': _pad(start.hour, 2),
      'M': _pad(start.minute, 2),
      'S': _pad(start.second, 2),
      'catchup-id': '',
    };

    // Replace both {token} and ${token}; unknown tokens are left intact.
    return template.replaceAllMapped(RegExp(r'\$?\{([a-zA-Z\-]+)(?::\d+)?\}'),
        (m) {
      final String key = m.group(1)!;
      return vars[key] ?? m.group(0)!;
    });
  }

  String _flussonicFromLive(String liveUrl, DateTime start, int durSecs) {
    final int s = _unix(start);
    final RegExp tail = RegExp(r'/(index|mono|video|playlist)\.(m3u8|ts)(\?.*)?$');
    final Match? m = tail.firstMatch(liveUrl);
    if (m != null) {
      final String ext = m.group(2)!;
      final String query = m.group(3) ?? '';
      final String base = liveUrl.substring(0, m.start);
      return '$base/archive-$s-$durSecs.$ext$query';
    }
    // Fall back to a query form when the URL isn't a recognizable Flussonic path.
    return _appendQuery(liveUrl, 'archive=$s&duration=$durSecs');
  }

  String _xcFromLive(String liveUrl, DateTime start, int durSecs) {
    // .../live/{u}/{p}/{id}.ts  ->  .../timeshift/{u}/{p}/{durmin}/{Y-m-d:H-M}/{id}.ts
    final RegExp re =
        RegExp(r'^(.*)/live/([^/]+)/([^/]+)/(\d+)\.(\w+)(\?.*)?$');
    final Match? m = re.firstMatch(liveUrl);
    if (m == null) return _appendQuery(liveUrl, 'utc=${_unix(start)}');
    final String base = m.group(1)!;
    final String user = m.group(2)!;
    final String pass = m.group(3)!;
    final String id = m.group(4)!;
    final String ext = m.group(5)!;
    final int durMin = (durSecs / 60).round();
    final String ts =
        '${_pad(start.year, 4)}-${_pad(start.month, 2)}-${_pad(start.day, 2)}:'
        '${_pad(start.hour, 2)}-${_pad(start.minute, 2)}';
    return '$base/timeshift/$user/$pass/$durMin/$ts/$id.$ext';
  }

  String _appendQuery(String url, String query) =>
      url.contains('?') ? '$url&$query' : '$url?$query';

  int _unix(DateTime dt) => dt.toUtc().millisecondsSinceEpoch ~/ 1000;
  int _nowUnix() => DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
  String _pad(int v, int width) => v.toString().padLeft(width, '0');
}
