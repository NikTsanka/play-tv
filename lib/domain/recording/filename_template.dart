/// Expands a recording-filename template (spec §10). Tokens are written as
/// `{token}`; unknown tokens are dropped. The result is sanitized of
/// filesystem-illegal characters and guaranteed non-empty.
///
/// Supported tokens: `{channel}`, `{title}` / `{epgTitle}`, `{date}` (YYYY-MM-DD),
/// `{day}`, `{month}`, `{year}`, `{hour}`, `{minute}`, `{second}`,
/// `{time}` (HH-MM-SS), `{datetime}` (date + time).
class FilenameTemplate {
  const FilenameTemplate(this.pattern);

  /// The default StreamHub recording pattern.
  static const String defaultPattern = '{channel} - {epgTitle} - {date} {time}';

  factory FilenameTemplate.standard() =>
      const FilenameTemplate(defaultPattern);

  final String pattern;

  /// Builds a filename (with [ext], no leading dot needed) for a recording of
  /// [channel] / optional [title], stamped at [when] (local time).
  String build({
    required String channel,
    String? title,
    required DateTime when,
    String ext = 'ts',
  }) {
    final DateTime t = when.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    final String date = '${t.year.toString().padLeft(4, '0')}-'
        '${two(t.month)}-${two(t.day)}';
    final String time = '${two(t.hour)}-${two(t.minute)}-${two(t.second)}';

    final Map<String, String> vars = <String, String>{
      'channel': channel,
      'title': title ?? '',
      'epgtitle': title ?? '',
      'date': date,
      'day': two(t.day),
      'month': two(t.month),
      'year': t.year.toString().padLeft(4, '0'),
      'hour': two(t.hour),
      'minute': two(t.minute),
      'second': two(t.second),
      'time': time,
      'datetime': '$date $time',
    };

    final String expanded = pattern.replaceAllMapped(
      RegExp(r'\{([a-zA-Z]+)\}'),
      (Match m) => vars[m.group(1)!.toLowerCase()] ?? '',
    );

    final String name = _sanitize(expanded);
    final String base = name.isEmpty ? 'recording' : name;
    return '$base.${_sanitize(ext)}';
  }

  /// Replaces characters illegal in Windows/POSIX filenames, collapses repeated
  /// separators and trims surrounding dots/spaces.
  static String _sanitize(String input) {
    final String cleaned = input
        .replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F]'), '_')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'_+'), '_')
        .trim();
    return cleaned.replaceAll(RegExp(r'^[.\s]+|[.\s]+$'), '');
  }
}
