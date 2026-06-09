import '../ott_models.dart';
import '../ott_service.dart';
import '../ott_session.dart';

/// Kartina TV — the canonical worked shape (spec C.5): session id carried as a
/// `sid` query param, `{groups:[{channels:[…]}]}` channel list, `{url}` GetUrl.
/// Other services subclass-vary only the field names / carrier.
class KartinaService extends OttService {
  @override
  String get id => 'kartina';

  @override
  String get caption => 'Kartina TV';

  @override
  String get defaultBaseUrl => 'http://api.kartina.tv';

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
  OttRequest channelListRequest(String base, OttSession session) =>
      OttRequest(Uri.parse('$base/api/json/channel_list').replace(
        queryParameters: <String, String>{'sid': session.sid ?? ''},
      ));

  @override
  List<OttGroup> parseChannelList(dynamic json) =>
      parseGroupsChannels(json, channelsKey: 'channels');

  @override
  OttRequest getUrlRequest(String base, OttSession session, OttGetUrlParams p) {
    final Map<String, String> q = <String, String>{
      'cid': p.channelId,
      'sid': session.sid ?? '',
      if (p.protectCode != null) 'protect_code': p.protectCode!,
      if (p.bitrate != null) 'bitrate': p.bitrate!,
      if (p.sourceServer != null) 'srv': p.sourceServer!,
      if (p.timeshiftStart != null)
        'gmt': '${p.timeshiftStart!.toUtc().millisecondsSinceEpoch ~/ 1000}',
    };
    return OttRequest(
        Uri.parse('$base/api/json/get_url').replace(queryParameters: q));
  }

  @override
  String? parseGetUrl(dynamic json, String base) {
    if (json is! Map) return null;
    return ottAbsoluteUrl(base, json['url']?.toString());
  }

  @override
  OttRequest? logoutRequest(String base, OttSession session) =>
      OttRequest(Uri.parse('$base/api/json/logout').replace(
        queryParameters: <String, String>{'sid': session.sid ?? ''},
      ));
}

/// Shared parser for the common `{groups:[{id,name,channels:[…]}]}` shape.
/// Channel field keys are configurable so variant services can reuse it.
List<OttGroup> parseGroupsChannels(
  dynamic json, {
  String groupsKey = 'groups',
  String groupNameKey = 'name',
  String channelsKey = 'channels',
  String idKey = 'id',
  String nameKey = 'name',
  String numberKey = 'number',
  String logoKey = 'icon',
  String epgKey = 'epg_channel_id',
  String protectedKey = 'protected',
  String archiveKey = 'have_archive',
}) {
  if (json is! Map) return const <OttGroup>[];
  final dynamic rawGroups = json[groupsKey];
  if (rawGroups is! List) return const <OttGroup>[];

  return rawGroups.whereType<Map>().map((Map<dynamic, dynamic> g) {
    final dynamic rawChannels = g[channelsKey];
    final List<OttChannel> channels = rawChannels is List
        ? rawChannels.whereType<Map>().map((Map<dynamic, dynamic> c) {
            return OttChannel(
              id: ottAsString(c[idKey]),
              name: ottAsString(c[nameKey]),
              number: ottAsInt(c[numberKey]),
              logo: c[logoKey]?.toString(),
              epgId: c[epgKey]?.toString(),
              protected: ottAsBool(c[protectedKey]),
              hasArchive: ottAsBool(c[archiveKey]),
            );
          }).toList()
        : const <OttChannel>[];
    return OttGroup(name: ottAsString(g[groupNameKey]), channels: channels);
  }).toList();
}
