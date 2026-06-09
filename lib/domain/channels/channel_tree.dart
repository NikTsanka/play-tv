import 'channel.dart';

/// A named group of channels in the left-side tree (spec §5).
class ChannelGroup {
  ChannelGroup(this.title, this.channels);
  final String title;
  final List<Channel> channels;
}

/// Groups a flat channel list by `group-title`, preserving first-seen order of
/// both groups and channels. Ungrouped channels collect under [ungroupedLabel].
List<ChannelGroup> groupChannels(
  List<Channel> channels, {
  String ungroupedLabel = 'Ungrouped',
}) {
  final Map<String, List<Channel>> map = <String, List<Channel>>{};
  final List<String> order = <String>[];
  for (final c in channels) {
    final String key = (c.group != null && c.group!.isNotEmpty)
        ? c.group!
        : ungroupedLabel;
    final list = map.putIfAbsent(key, () {
      order.add(key);
      return <Channel>[];
    });
    list.add(c);
  }
  return order.map((k) => ChannelGroup(k, map[k]!)).toList(growable: false);
}

/// Case-insensitive substring filter over channel name / group / number.
List<Channel> filterChannels(List<Channel> channels, String query) {
  final String q = query.trim().toLowerCase();
  if (q.isEmpty) return channels;
  return channels.where((c) {
    return c.name.toLowerCase().contains(q) ||
        (c.group?.toLowerCase().contains(q) ?? false) ||
        (c.number?.toString() == q);
  }).toList();
}
