import '../channels/channel.dart';
import 'media_types.dart';

/// Input to [buildLocalChannels] (a record so it crosses an isolate boundary
/// for `compute`).
typedef LocalScanInput = ({String root, List<String> paths});

/// Pure: turns scanned file [paths] under [root] into [Channel]s — classifying
/// by extension, grouping by relative subdirectory, titling from the filename,
/// and flagging audio as radio (spec §4.5). Isolate-friendly.
List<Channel> buildLocalChannels(LocalScanInput input) {
  final List<String> media =
      input.paths.where(isMediaFile).toList()..sort();
  final List<Channel> channels = <Channel>[];
  for (int i = 0; i < media.length; i++) {
    final String path = media[i];
    channels.add(Channel(
      id: 'local:$path',
      name: fileTitle(path),
      url: Uri.file(path).toString(),
      group: _groupFor(input.root, path),
      isRadio: isAudioMedia(path),
      number: i + 1,
    ));
  }
  return channels;
}

/// The relative subdirectory of [path] under [root] (forward-slashed), or null
/// when the file sits directly in [root].
String? _groupFor(String root, String path) {
  String rel = path.replaceAll('\\', '/');
  final String r = root.replaceAll('\\', '/');
  if (rel.startsWith(r)) rel = rel.substring(r.length);
  rel = rel.replaceFirst(RegExp(r'^/+'), '');
  final int idx = rel.lastIndexOf('/');
  if (idx <= 0) return null;
  return rel.substring(0, idx);
}
