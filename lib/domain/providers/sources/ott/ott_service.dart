import '../../provider.dart';
import 'ott_models.dart';
import 'ott_session.dart';
import 'services/kartina_service.dart';
import 'services/sovok_service.dart';
import 'services/tvclub_service.dart';

/// The per-service override surface of the OttBase framework (spec Appendix C).
/// `OttBaseProvider` owns the *flow* (login → list → per-zap get_url → relogin);
/// each branded subclass owns only the endpoints, field mappings and auth
/// carrier. Target: a new service is ~one small subclass.
abstract class OttService {
  /// Stable id persisted in `ProviderConfig.settings['service']`.
  String get id;

  /// Default display name.
  String get caption;

  /// Pre-filled base URL for the setup form (user-editable).
  String get defaultBaseUrl;

  Set<ProviderFunction> get functions => const <ProviderFunction>{
        ProviderFunction.live,
        ProviderFunction.epg,
        ProviderFunction.logos,
      };

  // ---- command override points -----------------------------------------

  /// Builds the Login request (exchanges credentials for a session).
  OttRequest loginRequest(String base, String username, String password);

  /// Parses the login response into a session (reads sid/token, expiry).
  OttSession parseLogin(dynamic json);

  /// Builds the ChannelList request (groups → channels).
  OttRequest channelListRequest(String base, OttSession session);

  /// Parses the channel list into groups.
  List<OttGroup> parseChannelList(dynamic json);

  /// Builds the per-zap GetUrl request (spec C.4).
  OttRequest getUrlRequest(String base, OttSession session, OttGetUrlParams p);

  /// Extracts the playable URL from the GetUrl response (absolute).
  String? parseGetUrl(dynamic json, String base);

  /// Optional Logout request.
  OttRequest? logoutRequest(String base, OttSession session) => null;

  /// Optional external XMLTV guide URL (imported via the standard EPG path).
  String? epgUrl(String base, OttSession session) => null;

  /// Detects a "session expired / auth" error so the base can re-login once.
  /// The default recognizes the common `{"error": …}` markers; override for
  /// services with a bespoke error shape.
  bool isAuthError(dynamic json) {
    if (json is! Map) return false;
    final dynamic err = json['error'];
    if (err == null) return false;
    final String s = err is Map
        ? (err['message'] ?? err['code'] ?? '').toString()
        : err.toString();
    final String l = s.toLowerCase();
    return l.contains('session') ||
        l.contains('auth') ||
        l.contains('login') ||
        l.contains('expired') ||
        s == '401';
  }
}

/// All branded services wired in this build (spec §4.4 lists many more; these
/// three exercise the three override axes: field names, sid param, auth carrier).
final List<OttService> ottServices = <OttService>[
  KartinaService(),
  SovokService(),
  TvClubService(),
];

/// Looks up a service by id, defaulting to the first when unknown/null so a
/// stale config never crashes the registry.
OttService ottServiceById(String? id) => ottServices.firstWhere(
      (OttService s) => s.id == id,
      orElse: () => ottServices.first,
    );
