import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/app_info.dart';

/// Result of an update check (spec §11). [available] is true when [latest] is
/// newer than the running [AppInfo.appVersion].
@immutable
class UpdateInfo {
  const UpdateInfo({
    required this.available,
    required this.current,
    required this.latest,
    this.changelog,
    this.downloadUrl,
  });

  final bool available;
  final String current;
  final String latest;
  final String? changelog;
  final String? downloadUrl;

  factory UpdateInfo.upToDate(String current) =>
      UpdateInfo(available: false, current: current, latest: current);
}

/// Compares two dot-separated versions. Returns >0 if [a] > [b], <0 if a < b,
/// 0 if equal. Non-numeric / missing segments are treated as 0.
int compareVersions(String a, String b) {
  final List<int> pa = _segments(a);
  final List<int> pb = _segments(b);
  final int len = pa.length > pb.length ? pa.length : pb.length;
  for (int i = 0; i < len; i++) {
    final int x = i < pa.length ? pa[i] : 0;
    final int y = i < pb.length ? pb[i] : 0;
    if (x != y) return x.compareTo(y);
  }
  return 0;
}

/// True if [candidate] is strictly newer than [current].
bool isNewerVersion(String current, String candidate) =>
    compareVersions(candidate, current) > 0;

List<int> _segments(String v) {
  // Drop a build suffix ("1.2.3+4") and pre-release tag ("1.2.3-beta").
  final String core = v.trim().split('+').first.split('-').first;
  return core.split('.').map((String s) => int.tryParse(s.trim()) ?? 0).toList();
}

/// Checks a JSON manifest for a newer build. Manifest shape:
/// `{ "version": "1.2.0", "changelog": "…", "url": "https://…" }`.
/// Gated/feature-flagged per platform/store at the call site.
class UpdateService {
  UpdateService({required this.manifestUrl, http.Client? client})
      : _client = client ?? http.Client();

  final String manifestUrl;
  final http.Client _client;

  Future<UpdateInfo> check({String current = AppInfo.appVersion}) async {
    final http.Response resp = await _client.get(Uri.parse(manifestUrl));
    if (resp.statusCode != 200) {
      throw Exception('Update check failed (HTTP ${resp.statusCode})');
    }
    final dynamic data = jsonDecode(resp.body);
    if (data is! Map) throw Exception('Malformed update manifest');

    final String latest = (data['version'] ?? current).toString();
    return UpdateInfo(
      available: isNewerVersion(current, latest),
      current: current,
      latest: latest,
      changelog: data['changelog']?.toString(),
      downloadUrl: data['url']?.toString(),
    );
  }

  void close() => _client.close();
}

/// The update manifest endpoint (placeholder; gate behind a store check before
/// surfacing in production).
const String kUpdateManifestUrl =
    'https://raw.githubusercontent.com/NikTsanka/play-tv/main/update.json';

final updateServiceProvider = Provider<UpdateService>((ref) {
  final UpdateService service = UpdateService(manifestUrl: kUpdateManifestUrl);
  ref.onDispose(service.close);
  return service;
});
