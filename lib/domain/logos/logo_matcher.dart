/// Pure fuzzy matching of channel names to logo keys (spec §5 — "logo
/// downloader with fuzzy name match"). Normalizes names (lowercase, strip
/// quality tags / punctuation) and scores candidates by token overlap +
/// edit distance, so "BBC One HD" matches a "bbc_one" logo file.
class LogoMatcher {
  const LogoMatcher({this.threshold = 0.5});

  /// Minimum score (0..1) to accept a match.
  final double threshold;

  /// Normalizes a name to a comparison key: lowercase, drop quality suffixes
  /// (HD/FHD/4K/SD…), keep alphanumerics, collapse whitespace.
  static String normalize(String input) {
    String s = input.toLowerCase();
    s = s.replaceAll(RegExp(r'\b(uhd|fhd|hd|sd|4k|hevc|h265|h264|raw)\b'), ' ');
    s = s.replaceAll(RegExp(r'[^a-z0-9]+'), ' ');
    return s.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Best-matching key from [candidates] for [name], or null if none clears
  /// [threshold]. [candidates] maps a key (e.g. logo filename without ext) to
  /// its display/source name.
  String? bestMatch(String name, Map<String, String> candidates) {
    final String target = normalize(name);
    if (target.isEmpty) return null;

    String? best;
    double bestScore = 0;
    for (final MapEntry<String, String> e in candidates.entries) {
      final double score = _score(target, normalize(e.value));
      if (score > bestScore) {
        bestScore = score;
        best = e.key;
      }
    }
    return bestScore >= threshold ? best : null;
  }

  /// Similarity 0..1: exact = 1, else blend of token-set overlap (Jaccard) and
  /// normalized edit distance.
  double score(String a, String b) => _score(normalize(a), normalize(b));

  double _score(String a, String b) {
    if (a == b) return 1;
    if (a.isEmpty || b.isEmpty) return 0;

    final Set<String> ta = a.split(' ').toSet();
    final Set<String> tb = b.split(' ').toSet();
    final int inter = ta.intersection(tb).length;
    final int union = ta.union(tb).length;
    final int minT = ta.length < tb.length ? ta.length : tb.length;
    final int maxT = ta.length > tb.length ? ta.length : tb.length;

    // One name's tokens fully contained in the other (abbreviation / "+ HD"):
    // a strong signal ("cnn" ⊆ "cnn international"). Otherwise use Jaccard,
    // which keeps near-siblings ("bbc one" vs "bbc two") below threshold.
    final bool subset = inter > 0 &&
        (ta.difference(tb).isEmpty || tb.difference(ta).isEmpty);
    final double tokenScore =
        subset ? 0.6 + 0.4 * (minT / maxT) : (union == 0 ? 0 : inter / union);

    final int dist = _levenshtein(a, b);
    final double edit = 1 - dist / (a.length > b.length ? a.length : b.length);

    return tokenScore * 0.6 + edit * 0.4;
  }

  static int _levenshtein(String a, String b) {
    final List<int> prev = List<int>.generate(b.length + 1, (int i) => i);
    final List<int> cur = List<int>.filled(b.length + 1, 0);
    for (int i = 1; i <= a.length; i++) {
      cur[0] = i;
      for (int j = 1; j <= b.length; j++) {
        final int cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
        cur[j] = _min3(cur[j - 1] + 1, prev[j] + 1, prev[j - 1] + cost);
      }
      for (int j = 0; j <= b.length; j++) {
        prev[j] = cur[j];
      }
    }
    return prev[b.length];
  }

  static int _min3(int a, int b, int c) =>
      a < b ? (a < c ? a : c) : (b < c ? b : c);
}
