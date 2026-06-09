// Value types shared by the OttBase framework (spec Appendix C). Field names in
// the wire JSON vary per service, so the typed shapes below are produced by each
// OttService's parse methods, not by direct deserialization.

/// Raised on OTT login / API failures.
class OttException implements Exception {
  OttException(this.message);
  final String message;
  @override
  String toString() => 'OttException: $message';
}

/// A built request: the URL plus any carrier headers (Cookie / Bearer).
class OttRequest {
  const OttRequest(this.uri, {this.headers = const <String, String>{}});
  final Uri uri;
  final Map<String, String> headers;
}

/// A channel as exposed by a `channel_list` command.
class OttChannel {
  OttChannel({
    required this.id,
    required this.name,
    this.number,
    this.logo,
    this.epgId,
    this.protected = false,
    this.hasArchive = false,
  });

  final String id;
  final String name;
  final int? number;
  final String? logo;
  final String? epgId;

  /// Requires a parental PIN at GetUrl time (spec C.4 rule 3).
  final bool protected;

  /// Catch-up / archive available (resolved via GetUrl timeshift).
  final bool hasArchive;
}

/// A channel group / category from `channel_list`.
class OttGroup {
  OttGroup({required this.name, required this.channels});
  final String name;
  final List<OttChannel> channels;
}

/// Inputs to the per-zap GetUrl call (spec C.4).
class OttGetUrlParams {
  OttGetUrlParams({
    required this.channelId,
    this.protectCode,
    this.bitrate,
    this.sourceServer,
    this.timeshiftStart,
  });

  final String channelId;
  final String? protectCode;
  final String? bitrate;
  final String? sourceServer;

  /// Catch-up: the EPG event start; null = live edge.
  final DateTime? timeshiftStart;
}

/// Tolerant coercion helpers (services send numbers/bools as strings).
String ottAsString(dynamic v) => v?.toString() ?? '';

int? ottAsInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v.trim());
  return null;
}

bool ottAsBool(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    final String s = v.trim().toLowerCase();
    return s == '1' || s == 'true' || s == 'yes';
  }
  return false;
}

/// Resolves a possibly host-less / relative stream URL against [base]
/// (spec C.4 rule 5). Returns null for empty input.
String? ottAbsoluteUrl(String base, String? raw) {
  if (raw == null) return null;
  final String s = raw.trim();
  if (s.isEmpty) return null;
  if (s.startsWith('http://') || s.startsWith('https://')) return s;
  if (s.startsWith('//')) return 'http:$s';
  final String b = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
  return '$b/${s.replaceFirst(RegExp(r'^/+'), '')}';
}
