/// A persisted OTT session (spec Appendix C.1). Holds the service session id /
/// token, its validity window, and a free-form [extra] map for service-specific
/// state (salt, csrf, chosen server host, …). Currently kept in memory on the
/// cached provider instance (like Stalker); [toJson]/[fromJson] make it ready to
/// persist between launches.
class OttSession {
  OttSession({
    this.sid,
    this.issuedAt,
    this.expiresAt,
    Map<String, String>? extra,
  }) : extra = extra ?? <String, String>{};

  /// Session id / token (carried as a query param, cookie or bearer).
  String? sid;
  DateTime? issuedAt;

  /// When the session is no longer valid; `null` = no known expiry.
  DateTime? expiresAt;

  /// Service-specific session state (e.g. chosen CDN host).
  final Map<String, String> extra;

  bool get isValid =>
      sid != null &&
      sid!.isNotEmpty &&
      (expiresAt == null || DateTime.now().isBefore(expiresAt!));

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (sid != null) 'sid': sid,
        if (issuedAt != null) 'issuedAt': issuedAt!.toIso8601String(),
        if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
        'extra': extra,
      };

  factory OttSession.fromJson(Map<String, dynamic> json) => OttSession(
        sid: json['sid'] as String?,
        issuedAt: DateTime.tryParse(json['issuedAt']?.toString() ?? ''),
        expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? ''),
        extra: (json['extra'] as Map?)
                ?.map((k, v) => MapEntry(k.toString(), v.toString())) ??
            <String, String>{},
      );
}
