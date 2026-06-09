import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/http/user_agents.dart';
import 'stalker_models.dart';

/// Raised on Stalker portal failures.
class StalkerException implements Exception {
  StalkerException(this.message);
  final String message;
  @override
  String toString() => 'StalkerException: $message';
}

/// Client for a Stalker / Ministra (MAG) portal (spec Appendix B). Authenticates
/// by MAC + handshake token, then resolves each stream URL on demand via
/// `create_link`. Token is kept in memory and transparently re-handshaked on an
/// empty/`js`-less response.
class StalkerClient {
  StalkerClient({
    required String portalUrl,
    required this.mac,
    this.login,
    this.password,
    http.Client? client,
  })  : _portal = _resolvePortal(portalUrl),
        _origin = _resolveOrigin(portalUrl),
        _http = client ?? http.Client();

  final String mac;
  final String? login;
  final String? password;

  /// Full portal endpoint, e.g. `http://host/c/portal.php`.
  final String _portal;

  /// Scheme + host, used for `Referer`.
  final String _origin;
  final http.Client _http;

  String? _token;
  String? get token => _token;

  // ---- portal/url helpers ----------------------------------------------

  static String _resolvePortal(String url) {
    final String u = url.trim();
    if (u.endsWith('.php')) return u;
    final String base = u.endsWith('/') ? u.substring(0, u.length - 1) : u;
    return '$base/portal.php';
  }

  static String _resolveOrigin(String url) {
    final Uri uri = Uri.parse(url.trim());
    return '${uri.scheme}://${uri.authority}';
  }

  Map<String, String> _headers() {
    final Map<String, String> h = <String, String>{
      'User-Agent': UserAgents.magStb,
      'X-User-Agent': UserAgents.magXUserAgent,
      'Referer': '$_origin/c/',
      'Cookie': 'mac=$mac; stb_lang=en; timezone=Europe/London',
    };
    if (_token != null) h['Authorization'] = 'Bearer $_token';
    return h;
  }

  // ---- auth -------------------------------------------------------------

  /// Performs the handshake and stores the token (B.2 step 1).
  Future<void> handshake() async {
    final dynamic js = await _getJs(<String, String>{
      'type': 'stb',
      'action': 'handshake',
      'token': '',
    }, allowRehandshake: false);
    final String? token = js is Map ? js['token']?.toString() : null;
    if (token == null || token.isEmpty) {
      throw StalkerException('Handshake returned no token');
    }
    _token = token;
    await _getProfile();
  }

  /// Establishes the session profile (B.2 step 2). Minimal params — public
  /// portals accept empty signature / device id.
  Future<void> _getProfile() async {
    await _getJs(<String, String>{
      'type': 'stb',
      'action': 'get_profile',
      'hd': '1',
      'stb_type': 'MAG250',
      'auth_second_step': '0',
      'not_valid_token': '0',
    }, allowRehandshake: false);
  }

  /// Ensures a valid session, handshaking if needed.
  Future<void> ensureSession() async {
    if (_token == null) await handshake();
  }

  // ---- live -------------------------------------------------------------

  Future<List<StalkerGenre>> genres() async {
    await ensureSession();
    final dynamic js =
        await _getJs(<String, String>{'type': 'itv', 'action': 'get_genres'});
    if (js is! List) return const <StalkerGenre>[];
    return js
        .whereType<Map>()
        .map((e) => StalkerGenre.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Future<StalkerPage> orderedList({String genre = '*', int page = 1}) async {
    await ensureSession();
    final dynamic js = await _getJs(<String, String>{
      'type': 'itv',
      'action': 'get_ordered_list',
      'genre': genre,
      'p': '$page',
      'sortby': 'number',
    });
    return StalkerPage.fromJs(js);
  }

  /// Fetches every channel across all pages (honouring `total_items`).
  Future<List<StalkerChannel>> allChannels({int maxPages = 200}) async {
    final StalkerPage first = await orderedList(page: 1);
    final List<StalkerChannel> all = <StalkerChannel>[...first.channels];
    if (first.maxPageItems > 0 && first.totalItems > first.maxPageItems) {
      final int pages =
          (first.totalItems / first.maxPageItems).ceil().clamp(1, maxPages);
      for (int p = 2; p <= pages; p++) {
        final StalkerPage page = await orderedList(page: p);
        if (page.channels.isEmpty) break;
        all.addAll(page.channels);
      }
    }
    return all;
  }

  /// Resolves a playable URL for a channel `cmd` (B.3 — the critical per-zap
  /// step). Strips the engine prefix from `js.cmd`.
  Future<String?> createLink(String cmd) async {
    await ensureSession();
    final dynamic js = await _getJs(<String, String>{
      'type': 'itv',
      'action': 'create_link',
      'cmd': cmd,
      'forced_storage': '0',
      'disable_ad': '0',
    });
    final String? raw = js is Map ? js['cmd']?.toString() : null;
    if (raw == null || raw.isEmpty) return null;
    return stripCmdPrefix(raw);
  }

  /// Removes a leading engine token (`ffmpeg`, `auto`, numeric id) so only the
  /// real URL remains (B.3).
  static String stripCmdPrefix(String cmd) {
    String s = cmd.trim();
    for (final String prefix in <String>['ffmpeg ', 'auto ']) {
      if (s.startsWith(prefix)) s = s.substring(prefix.length).trim();
    }
    final int scheme = s.indexOf(RegExp(r'[a-zA-Z]+://'));
    if (scheme > 0) s = s.substring(scheme);
    return s;
  }

  void close() => _http.close();

  // ---- transport --------------------------------------------------------

  /// GETs `_portal` with the given query (always adds `JsHttpRequest=1-xml`),
  /// unwraps `{"js": …}`, and re-handshakes once on an empty/missing `js`.
  Future<dynamic> _getJs(Map<String, String> params,
      {bool allowRehandshake = true}) async {
    final Uri uri = Uri.parse(_portal).replace(queryParameters: <String, String>{
      ...params,
      'JsHttpRequest': '1-xml',
    });

    final http.Response resp = await _http.get(uri, headers: _headers());
    if (resp.statusCode == 401 && allowRehandshake) {
      _token = null;
      await handshake();
      return _getJs(params, allowRehandshake: false);
    }
    if (resp.statusCode != 200) {
      throw StalkerException('HTTP ${resp.statusCode}');
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(resp.body);
    } catch (_) {
      throw StalkerException('Non-JSON response (portal error?)');
    }

    final bool hasJs = decoded is Map && decoded.containsKey('js');
    if (!hasJs) {
      if (allowRehandshake) {
        _token = null;
        await handshake();
        return _getJs(params, allowRehandshake: false);
      }
      throw StalkerException('Portal returned no js payload');
    }
    return decoded['js'];
  }
}
