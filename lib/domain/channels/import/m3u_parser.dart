import 'dart:convert';
import 'dart:typed_data';

import '../channel.dart';

/// Result of parsing an M3U/M3U8 playlist.
class M3uParseResult {
  M3uParseResult({required this.channels, required this.attributes});

  final List<Channel> channels;

  /// `#EXTM3U` header attributes, e.g. `url-tvg` / `x-tvg-url` (EPG source).
  final Map<String, String> attributes;

  /// EPG guide URL declared in the header, if any.
  String? get epgUrl => attributes['url-tvg'] ?? attributes['x-tvg-url'];
}

/// Decodes raw playlist bytes, auto-detecting the codepage: UTF-8 first
/// (allowing malformed), falling back to Latin-1 if it clearly isn't UTF-8.
String decodeM3uBytes(Uint8List bytes) {
  try {
    return const Utf8Decoder(allowMalformed: false).convert(bytes);
  } catch (_) {
    return const Latin1Decoder().convert(bytes);
  }
}

/// Parses M3U/M3U8 content into channels. Pure & isolate-friendly (run via
/// `compute`). Handles `#EXTINF` attributes, `#EXTGRP`, `#EXTVLCOPT`,
/// `#KODIPROP`, `#EXTHTTP`, and catch-up declarations (spec §4.1 + Appendix D).
M3uParseResult parseM3u(String content) {
  final List<Channel> channels = <Channel>[];
  final Map<String, String> headerAttrs = <String, String>{};

  final List<String> lines = const LineSplitter().convert(content);
  int seq = 0;

  // Accumulators for the channel currently being assembled.
  _PendingChannel? pending;

  for (var raw in lines) {
    final String line = raw.trim();
    if (line.isEmpty) continue;

    if (line.startsWith('#EXTM3U')) {
      headerAttrs.addAll(_parseAttributes(line.substring('#EXTM3U'.length)));
      continue;
    }

    if (line.startsWith('#EXTINF:')) {
      pending = _parseExtInf(line.substring('#EXTINF:'.length));
      continue;
    }

    if (line.startsWith('#EXTGRP:')) {
      pending ??= _PendingChannel();
      pending.group ??= line.substring('#EXTGRP:'.length).trim();
      continue;
    }

    if (line.startsWith('#EXTVLCOPT:')) {
      pending ??= _PendingChannel();
      _applyVlcOpt(pending, line.substring('#EXTVLCOPT:'.length));
      continue;
    }

    if (line.startsWith('#KODIPROP:')) {
      pending ??= _PendingChannel();
      _applyKodiProp(pending, line.substring('#KODIPROP:'.length));
      continue;
    }

    if (line.startsWith('#EXTHTTP:')) {
      pending ??= _PendingChannel();
      _applyExtHttp(pending, line.substring('#EXTHTTP:'.length));
      continue;
    }

    if (line.startsWith('#')) continue; // unknown directive

    // A non-comment line is the stream URL for the pending channel.
    final p = pending ?? _PendingChannel();
    pending = null;
    final ch = p.build(line, seq);
    if (ch != null) {
      channels.add(ch);
      seq++;
    }
  }

  return M3uParseResult(channels: channels, attributes: headerAttrs);
}

// ---------------------------------------------------------------------------

class _PendingChannel {
  String? name;
  String? group;
  String? logo;
  String? epgId;
  int? number;
  bool isRadio = false;
  final Map<String, String> headers = <String, String>{};
  final Map<String, String> props = <String, String>{};
  CatchupInfo catchup = const CatchupInfo();

  Channel? build(String url, int seq) {
    if (url.isEmpty) return null;
    final String channelName = (name ?? '').isNotEmpty ? name! : 'Channel ${seq + 1}';
    final String id = (epgId != null && epgId!.isNotEmpty)
        ? epgId!
        : _stableId(channelName, url);
    return Channel(
      id: id,
      name: channelName,
      url: url,
      group: (group != null && group!.isNotEmpty) ? group : null,
      logoUrl: logo,
      epgId: (epgId != null && epgId!.isNotEmpty) ? epgId : null,
      isRadio: isRadio,
      number: number ?? (seq + 1),
      catchup: catchup,
      headers: Map<String, String>.unmodifiable(headers),
      props: Map<String, String>.unmodifiable(props),
    );
  }
}

_PendingChannel _parseExtInf(String body) {
  final c = _PendingChannel();
  final int comma = _findNameComma(body);
  final String attrsPart = comma >= 0 ? body.substring(0, comma) : body;
  c.name = comma >= 0 ? body.substring(comma + 1).trim() : null;

  final Map<String, String> attrs = _parseAttributes(attrsPart);
  c.epgId = attrs['tvg-id'];
  c.logo = attrs['tvg-logo'];
  // tvg-name is a fallback display name only if the trailing name is empty.
  if ((c.name ?? '').isEmpty) c.name = attrs['tvg-name'];
  c.group = attrs['group-title'];
  c.number = _toInt(attrs['tvg-chno'] ?? attrs['tvg-num'] ?? attrs['channel-number']);
  if ((attrs['radio'] ?? '').toLowerCase() == 'true') c.isRadio = true;

  if (attrs['tvg-id'] != null) c.epgId = attrs['tvg-id'];
  final ua = attrs['user-agent'];
  if (ua != null && ua.isNotEmpty) c.headers['User-Agent'] = ua;
  final ref = attrs['referer'] ?? attrs['referrer'];
  if (ref != null && ref.isNotEmpty) c.headers['Referer'] = ref;

  c.catchup = _parseCatchup(attrs);
  return c;
}

CatchupInfo _parseCatchup(Map<String, String> a) {
  final String? rawType = a['catchup'] ?? a['catchup-type'] ?? a['tvg-rec'];
  final String? source = a['catchup-source'];
  final int days = _toInt(a['catchup-days']) ??
      ((_toInt(a['catchup-time']) ?? 0) ~/ 86400);
  final int correction = _toInt(a['catchup-correction']) ?? 0;

  CatchupType type = CatchupType.none;
  switch ((rawType ?? '').toLowerCase()) {
    case 'default':
      type = CatchupType.standard;
    case 'append':
      type = CatchupType.append;
    case 'shift':
    case 'timeshift':
      type = CatchupType.shift;
    case 'flussonic':
    case 'flussonic-hls':
    case 'flussonic-ts':
    case 'fs':
      type = CatchupType.flussonic;
    case 'xc':
    case 'xtream':
      type = CatchupType.xc;
    case 'vod':
      type = CatchupType.vod;
    case '':
      // tvg-rec="1" / a bare catchup-source implies a default archive.
      if (source != null || days > 0) type = CatchupType.standard;
    default:
      if (source != null) type = CatchupType.standard;
  }
  if (type == CatchupType.none && days == 0 && source == null) {
    return const CatchupInfo();
  }
  return CatchupInfo(
      type: type, source: source, days: days, correctionHours: correction);
}

void _applyVlcOpt(_PendingChannel c, String body) {
  final int eq = body.indexOf('=');
  if (eq < 0) return;
  final String key = body.substring(0, eq).trim().toLowerCase();
  final String value = _unquote(body.substring(eq + 1).trim());
  switch (key) {
    case 'http-user-agent':
      c.headers['User-Agent'] = value;
    case 'http-referrer':
    case 'http-referer':
      c.headers['Referer'] = value;
    case 'http-origin':
      c.headers['Origin'] = value;
    default:
      c.props[key] = value;
  }
}

void _applyKodiProp(_PendingChannel c, String body) {
  final int eq = body.indexOf('=');
  if (eq < 0) return;
  final String key = body.substring(0, eq).trim();
  final String value = body.substring(eq + 1).trim();
  final String lower = key.toLowerCase();
  if (lower == 'http-user-agent' || lower.endsWith('user_agent')) {
    c.headers['User-Agent'] = value;
  } else if (lower.contains('referer') || lower.contains('referrer')) {
    c.headers['Referer'] = value;
  } else {
    c.props[key] = value;
  }
}

void _applyExtHttp(_PendingChannel c, String body) {
  try {
    final dynamic json = jsonDecode(body.trim());
    if (json is Map) {
      json.forEach((k, v) => c.headers[k.toString()] = v.toString());
    }
  } catch (_) {
    // ignore malformed EXTHTTP
  }
}

// ---- attribute parsing helpers -------------------------------------------

final RegExp _attrRegex =
    RegExp(r'([a-zA-Z0-9_\-]+)=(?:"([^"]*)"|(\S+))');

Map<String, String> _parseAttributes(String input) {
  final Map<String, String> out = <String, String>{};
  for (final m in _attrRegex.allMatches(input)) {
    final String key = m.group(1)!.toLowerCase();
    final String value = m.group(2) ?? m.group(3) ?? '';
    out[key] = value;
  }
  return out;
}

/// Finds the first comma that is not inside double quotes — the EXTINF
/// display-name separator. Returns -1 if none.
int _findNameComma(String s) {
  bool inQuotes = false;
  for (int i = 0; i < s.length; i++) {
    final String ch = s[i];
    if (ch == '"') {
      inQuotes = !inQuotes;
    } else if (ch == ',' && !inQuotes) {
      return i;
    }
  }
  return -1;
}

int? _toInt(String? v) => v == null ? null : int.tryParse(v.trim());

String _unquote(String v) {
  if (v.length >= 2 && v.startsWith('"') && v.endsWith('"')) {
    return v.substring(1, v.length - 1);
  }
  return v;
}

String _stableId(String name, String url) {
  // FNV-1a 32-bit over name+url — deterministic, collision-safe enough for ids.
  const int prime = 0x01000193;
  int hash = 0x811c9dc5;
  final String s = '$name|$url';
  for (int i = 0; i < s.length; i++) {
    hash ^= s.codeUnitAt(i) & 0xff;
    hash = (hash * prime) & 0xffffffff;
  }
  return 'm3u_${hash.toRadixString(16)}';
}
