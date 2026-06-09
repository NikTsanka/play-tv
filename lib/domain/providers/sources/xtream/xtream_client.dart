import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/http/user_agents.dart';
import 'xtream_models.dart';

/// Raised on Xtream API / auth failures (HTML error pages, `auth:0`, …).
class XtreamException implements Exception {
  XtreamException(this.message);
  final String message;
  @override
  String toString() => 'XtreamException: $message';
}

/// Thin client for the Xtream Codes / XUI.one `player_api.php` API
/// (spec Appendix A). Needs only base URL + username + password. Stream URLs
/// are deterministic; the per-zap resolver is therefore unnecessary for Xtream.
class XtreamClient {
  XtreamClient({
    required String baseUrl,
    required this.username,
    required this.password,
    http.Client? client,
  })  : baseUrl = _stripSlash(baseUrl),
        _http = client ?? http.Client();

  final String baseUrl;
  final String username;
  final String password;
  final http.Client _http;

  XtreamAccount? _account;
  XtreamAccount? get account => _account;

  static String _stripSlash(String s) {
    String b = s.trim();
    while (b.endsWith('/')) {
      b = b.substring(0, b.length - 1);
    }
    return b;
  }

  // ---- API calls --------------------------------------------------------

  /// Logs in (no `action`) and caches the account. Throws if not active.
  Future<XtreamAccount> login() async {
    final dynamic data = await _getJson(_api(const <String, String>{}));
    if (data is! Map) throw XtreamException('Unexpected login response');
    final XtreamAccount account =
        XtreamAccount.fromJson(data.cast<String, dynamic>());
    _account = account;
    if (!account.isActive) {
      throw XtreamException(
          account.status.isEmpty ? 'Login failed' : 'Account ${account.status}');
    }
    return account;
  }

  Future<List<XtreamCategory>> liveCategories() =>
      _list('get_live_categories', XtreamCategory.fromJson);

  Future<List<XtreamLiveStream>> liveStreams({String? categoryId}) => _list(
        'get_live_streams',
        XtreamLiveStream.fromJson,
        categoryId == null ? null : <String, String>{'category_id': categoryId},
      );

  Future<List<XtreamCategory>> vodCategories() =>
      _list('get_vod_categories', XtreamCategory.fromJson);

  Future<List<XtreamVodStream>> vodStreams({String? categoryId}) => _list(
        'get_vod_streams',
        XtreamVodStream.fromJson,
        categoryId == null ? null : <String, String>{'category_id': categoryId},
      );

  Future<List<XtreamCategory>> seriesCategories() =>
      _list('get_series_categories', XtreamCategory.fromJson);

  Future<List<XtreamSeries>> seriesList({String? categoryId}) => _list(
        'get_series',
        XtreamSeries.fromJson,
        categoryId == null ? null : <String, String>{'category_id': categoryId},
      );

  /// Flattened episodes for a series (across all seasons; `season` is on each).
  Future<List<XtreamEpisode>> seriesEpisodes(int seriesId) async {
    final dynamic data = await _getJson(_api(<String, String>{
      'action': 'get_series_info',
      'series_id': '$seriesId',
    }));
    final List<XtreamEpisode> out = <XtreamEpisode>[];
    if (data is Map) {
      final dynamic episodes = data['episodes'];
      if (episodes is Map) {
        for (final dynamic season in episodes.values) {
          if (season is List) {
            for (final Map<dynamic, dynamic> e in season.whereType<Map>()) {
              out.add(XtreamEpisode.fromJson(e.cast<String, dynamic>()));
            }
          }
        }
      }
    }
    return out;
  }

  /// Short EPG for a live stream (Base64 title/desc decoded by the model).
  Future<List<XtreamEpgListing>> shortEpg(int streamId, {int limit = 10}) async {
    final dynamic data = await _getJson(_api(<String, String>{
      'action': 'get_short_epg',
      'stream_id': '$streamId',
      'limit': '$limit',
    }));
    final dynamic listings = data is Map ? data['epg_listings'] : null;
    if (listings is! List) return const <XtreamEpgListing>[];
    return listings
        .whereType<Map>()
        .map((e) => XtreamEpgListing.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  // ---- stream URL builders ---------------------------------------------

  /// Delivery host — prefer `server_info` (panels often redirect away from the
  /// login host), else the configured base (A.1 note).
  String get streamBase {
    final XtreamAccount? a = _account;
    if (a != null &&
        a.serverProtocol != null &&
        a.serverUrl != null &&
        a.serverUrl!.isNotEmpty) {
      final String port =
          (a.serverPort != null && a.serverPort!.isNotEmpty) ? ':${a.serverPort}' : '';
      return '${a.serverProtocol}://${a.serverUrl}$port';
    }
    return baseUrl;
  }

  String liveUrl(int streamId, {String ext = 'ts'}) =>
      '$streamBase/live/$username/$password/$streamId.$ext';

  String vodUrl(int streamId, String containerExtension) =>
      '$streamBase/movie/$username/$password/$streamId.$containerExtension';

  String seriesEpisodeUrl(String episodeId, String containerExtension) =>
      '$streamBase/series/$username/$password/$episodeId.$containerExtension';

  /// Full XMLTV guide dump (imported through the standard EPG path).
  String xmltvUrl() => Uri.parse('$baseUrl/xmltv.php').replace(
        queryParameters: <String, String>{
          'username': username,
          'password': password,
        },
      ).toString();

  /// Catch-up (timeshift) path form (A.7). `start` = `YYYY-MM-DD:HH-MM` UTC.
  String timeshiftUrl({
    required int streamId,
    required DateTime startUtc,
    required int durationMinutes,
    String ext = 'ts',
  }) {
    final DateTime s = startUtc.toUtc();
    String pad(int v, [int w = 2]) => v.toString().padLeft(w, '0');
    final String start =
        '${pad(s.year, 4)}-${pad(s.month)}-${pad(s.day)}:${pad(s.hour)}-${pad(s.minute)}';
    return '$streamBase/timeshift/$username/$password/$durationMinutes/$start/$streamId.$ext';
  }

  void close() => _http.close();

  // ---- transport --------------------------------------------------------

  Uri _api(Map<String, String> params) {
    return Uri.parse('$baseUrl/player_api.php').replace(
      queryParameters: <String, String>{
        'username': username,
        'password': password,
        ...params,
      },
    );
  }

  Future<List<T>> _list<T>(
    String action,
    T Function(Map<String, dynamic>) fromJson, [
    Map<String, String>? extra,
  ]) async {
    final dynamic data = await _getJson(_api(<String, String>{
      'action': action,
      ...?extra,
    }));
    if (data is! List) return <T>[];
    return data
        .whereType<Map>()
        .map((e) => fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Future<dynamic> _getJson(Uri uri) async {
    final http.Response resp = await _http
        .get(uri, headers: const <String, String>{'User-Agent': UserAgents.iptv});
    if (resp.statusCode != 200) {
      throw XtreamException('HTTP ${resp.statusCode}');
    }
    final String body = resp.body.trim();
    if (body.isEmpty) throw XtreamException('Empty response');
    try {
      return jsonDecode(body);
    } catch (_) {
      throw XtreamException('Non-JSON response (panel error or blocked)');
    }
  }
}
