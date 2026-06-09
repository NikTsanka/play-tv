import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the [SharedPreferences] instance for simple key/value settings.
///
/// Overridden with a concrete instance in `main()` so the rest of the app reads
/// it synchronously via Riverpod.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope.',
  ),
);

/// Centralized preference keys to avoid stringly-typed drift.
abstract final class PrefKeys {
  const PrefKeys._();
  static const String themeMode = 'app.themeMode';
  static const String locale = 'app.locale';
  static const String currentPlaylist = 'channels.currentPlaylist';
  static const String currentVodSource = 'vod.currentSource';
  static const String recordingTemplate = 'recording.filenameTemplate';
  static const String parentalPinHash = 'parental.pinHash';
  static const String parentalSalt = 'parental.salt';
}
