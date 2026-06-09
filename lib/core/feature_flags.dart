/// Compile-time feature flags. YouTube is gated off by default (spec §4.6 —
/// "feature-flagged") so the source isn't offered unless a build opts in.
abstract final class FeatureFlags {
  const FeatureFlags._();

  /// Offer the YouTube source in the add-provider UI.
  static const bool youtube =
      bool.fromEnvironment('STREAMHUB_YOUTUBE', defaultValue: false);

  /// Chromecast sender (spec §8 — flagged; the CastEngine isn't wired yet).
  static const bool chromecast =
      bool.fromEnvironment('STREAMHUB_CHROMECAST', defaultValue: false);
}
