import '../ott_models.dart';
import '../ott_service.dart';
import '../ott_session.dart';
import 'kartina_service.dart';

/// TV Club — same flow and field map as Kartina, but the session is carried as a
/// **Cookie** (`Cookie: sid=…`) rather than a query param, and GetUrl may return
/// a host-less path. Demonstrates the auth-carrier override axis (spec C.3:
/// "query `sid=` vs `Cookie: sid=` vs `Authorization: Bearer`").
class TvClubService extends OttService {
  @override
  String get id => 'tvclub';

  @override
  String get caption => 'TV Club';

  @override
  String get defaultBaseUrl => 'http://api.tvclub.cc';

  Map<String, String> _cookie(OttSession s) =>
      <String, String>{'Cookie': 'sid=${s.sid ?? ''}'};

  @override
  OttRequest loginRequest(String base, String username, String password) =>
      OttRequest(Uri.parse('$base/api/json/login').replace(
        queryParameters: <String, String>{'login': username, 'pass': password},
      ));

  @override
  OttSession parseLogin(dynamic json) {
    final Map<String, dynamic> m =
        json is Map ? json.cast<String, dynamic>() : <String, dynamic>{};
    return OttSession(sid: m['sid']?.toString());
  }

  @override
  OttRequest channelListRequest(String base, OttSession session) => OttRequest(
        Uri.parse('$base/api/json/channel_list'),
        headers: _cookie(session),
      );

  @override
  List<OttGroup> parseChannelList(dynamic json) =>
      parseGroupsChannels(json, channelsKey: 'channels');

  @override
  OttRequest getUrlRequest(String base, OttSession session, OttGetUrlParams p) {
    final Map<String, String> q = <String, String>{
      'cid': p.channelId,
      if (p.protectCode != null) 'protect_code': p.protectCode!,
      if (p.timeshiftStart != null)
        'gmt': '${p.timeshiftStart!.toUtc().millisecondsSinceEpoch ~/ 1000}',
    };
    return OttRequest(
      Uri.parse('$base/api/json/get_url').replace(queryParameters: q),
      headers: _cookie(session),
    );
  }

  @override
  String? parseGetUrl(dynamic json, String base) {
    if (json is! Map) return null;
    // May be a host-less path → resolved against base.
    return ottAbsoluteUrl(base, json['url']?.toString());
  }
}
