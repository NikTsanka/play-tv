/// Classifies local files by extension (spec §4.5).
enum MediaKind { video, audio, audiobook, unknown }

/// Recognized media extensions (lowercase, no dot).
abstract final class MediaExtensions {
  const MediaExtensions._();

  static const Set<String> video = <String>{
    'mp4', 'mkv', 'avi', 'mov', 'm4v', 'webm', 'ts', 'mpg', 'mpeg', 'wmv', 'flv',
  };
  static const Set<String> audio = <String>{
    'mp3', 'flac', 'aac', 'm4a', 'ogg', 'oga', 'opus', 'wav', 'wma', 'alac',
  };
  static const Set<String> audiobook = <String>{'m4b', 'aa', 'aax'};
}

/// The extension of [path] (lowercase, without the dot), or '' if none.
String fileExtension(String path) {
  final int slash = _lastSep(path);
  final String name = slash >= 0 ? path.substring(slash + 1) : path;
  final int dot = name.lastIndexOf('.');
  if (dot <= 0 || dot == name.length - 1) return '';
  return name.substring(dot + 1).toLowerCase();
}

/// File name without directory or extension.
String fileTitle(String path) {
  final int slash = _lastSep(path);
  final String name = slash >= 0 ? path.substring(slash + 1) : path;
  final int dot = name.lastIndexOf('.');
  return dot > 0 ? name.substring(0, dot) : name;
}

int _lastSep(String path) {
  final int a = path.lastIndexOf('/');
  final int b = path.lastIndexOf('\\');
  return a > b ? a : b;
}

/// Maps a file path to its [MediaKind].
MediaKind classifyMedia(String path) {
  final String ext = fileExtension(path);
  if (MediaExtensions.audiobook.contains(ext)) return MediaKind.audiobook;
  if (MediaExtensions.video.contains(ext)) return MediaKind.video;
  if (MediaExtensions.audio.contains(ext)) return MediaKind.audio;
  return MediaKind.unknown;
}

/// Whether [path] is a playable media file.
bool isMediaFile(String path) => classifyMedia(path) != MediaKind.unknown;

/// Whether [path] is audio-only (audio or audiobook).
bool isAudioMedia(String path) {
  final MediaKind kind = classifyMedia(path);
  return kind == MediaKind.audio || kind == MediaKind.audiobook;
}
