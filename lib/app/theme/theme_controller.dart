import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/preferences.dart';

/// Persisted [ThemeMode] (System / Light / Dark). Backed by SharedPreferences.
class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return _decode(prefs.getString(PrefKeys.themeMode));
  }

  Future<void> set(ThemeMode mode) async {
    if (mode == state) return;
    state = mode;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(PrefKeys.themeMode, _encode(mode));
  }

  /// Quick top-bar toggle: flips between light and dark. If currently following
  /// the system, flip relative to the platform brightness.
  Future<void> toggle(Brightness platformBrightness) async {
    final bool isDarkNow = switch (state) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system => platformBrightness == Brightness.dark,
    };
    await set(isDarkNow ? ThemeMode.light : ThemeMode.dark);
  }

  static ThemeMode _decode(String? raw) => switch (raw) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  static String _encode(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
}

final themeModeProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);
