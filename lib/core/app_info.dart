/// Static app identity. [appVersion] mirrors `pubspec.yaml` `version` (without
/// the build number) and is the baseline for update checks (spec §11).
abstract final class AppInfo {
  const AppInfo._();
  static const String appName = 'StreamHub';
  static const String appVersion = '0.1.0';
}
