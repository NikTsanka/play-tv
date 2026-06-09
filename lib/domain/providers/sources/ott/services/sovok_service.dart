import '../ott_models.dart';
import '../ott_service.dart';
import '../ott_session.dart';
import 'kartina_service.dart';

/// Sovok TV — same flow as Kartina but a different **field map**: the session is
/// a `token` (not `sid`), groups use `title`/`ch`, channels use `ch_id`/`caption`,
/// and GetUrl returns `cmd` (not `url`). Demonstrates the field-mapping override
/// axis (spec C.5: "field names differ per service").
class SovokService extends OttService {
  @override
  String get id => 'sovok';

  @override
  String get caption => 'Sovok TV';

  @override
  String get defaultBaseUrl => 'http://api.sovok.tv';

  @override
  OttRequest loginRequest(String base, String username, String password) =>
      OttRequest(Uri.parse('$base/api/json/login').replace(
        queryParameters: <String, String>{'login': username, 'pass': password},
      ));

  @override
  OttSession parseLogin(dynamic json) {
    final Map<String, dynamic> m =
        json is Map ? json.cast<String, dynamic>() : <String, dynamic>{};
    // Carrier is `token`.
    return OttSession(sid: m['token']?.toString());
  }

  @override
  OttRequest channelListRequest(String base, OttSession session) =>
      OttRequest(Uri.parse('$base/api/json/channel_list').replace(
        queryParameters: <String, String>{'token': session.sid ?? ''},
      ));

  @override
  List<OttGroup> parseChannelList(dynamic json) => parseGroupsChannels(
        json,
        groupNameKey: 'title',
        channelsKey: 'ch',
        idKey: 'ch_id',
        nameKey: 'caption',
        logoKey: 'logo',
        archiveKey: 'have_archive',
      );

  @override
  OttRequest getUrlRequest(String base, OttSession session, OttGetUrlParams p) {
    final Map<String, String> q = <String, String>{
      'cid': p.channelId,
      'token': session.sid ?? '',
      if (p.protectCode != null) 'protect_code': p.protectCode!,
      if (p.timeshiftStart != null)
        'gmt': '${p.timeshiftStart!.toUtc().millisecondsSinceEpoch ~/ 1000}',
    };
    return OttRequest(
        Uri.parse('$base/api/json/get_url').replace(queryParameters: q));
  }

  @override
  String? parseGetUrl(dynamic json, String base) {
    if (json is! Map) return null;
    // Returns `cmd` instead of `url`.
    return ottAbsoluteUrl(base, json['cmd']?.toString());
  }
}
