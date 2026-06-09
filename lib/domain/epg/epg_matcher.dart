import '../channels/channel.dart';
import 'epg_models.dart';

/// Resolves which EPG channel id backs each [Channel] (spec §5 relations):
/// exact `tvg-id` match first, then a normalized-name match. Returns a map of
/// domain channel id → EPG channel id for the ones that matched.
Map<String, String> buildChannelEpgMap(
  List<Channel> channels,
  List<EpgChannel> epgChannels,
) {
  final Map<String, String> byLowerId = <String, String>{};
  final Map<String, String> byName = <String, String>{};

  for (final e in epgChannels) {
    byLowerId[e.id.toLowerCase()] = e.id;
    for (final n in <String>[e.id, ...e.displayNames]) {
      final String key = normalizeChannelName(n);
      if (key.isNotEmpty) byName.putIfAbsent(key, () => e.id);
    }
  }

  final Map<String, String> result = <String, String>{};
  for (final c in channels) {
    final String? viaId = c.epgId != null ? byLowerId[c.epgId!.toLowerCase()] : null;
    if (viaId != null) {
      result[c.id] = viaId;
      continue;
    }
    final String? viaName = byName[normalizeChannelName(c.name)];
    if (viaName != null) result[c.id] = viaName;
  }
  return result;
}

final RegExp _nonAlnum = RegExp(r'[^a-z0-9]+');
final RegExp _qualityTokens =
    RegExp(r'\b(hd|fhd|uhd|sd|4k|2k|hq|hevc|h265|h264|raw|backup)\b');

/// Lowercases, strips quality tokens and non-alphanumerics so "BBC One HD" and
/// "bbc.one" collapse to a comparable key.
String normalizeChannelName(String name) {
  var s = name.toLowerCase();
  s = s.replaceAll(_qualityTokens, ' ');
  s = s.replaceAll(_nonAlnum, '');
  return s;
}
