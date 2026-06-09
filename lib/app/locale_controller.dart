import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/storage/preferences.dart';

/// Persisted app locale. `null` means "follow the system locale".
class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final String? raw = prefs.getString(PrefKeys.locale);
    if (raw == null || raw.isEmpty) return null;
    return Locale(raw);
  }

  Future<void> set(Locale? locale) async {
    state = locale;
    final prefs = ref.read(sharedPreferencesProvider);
    if (locale == null) {
      await prefs.remove(PrefKeys.locale);
    } else {
      await prefs.setString(PrefKeys.locale, locale.languageCode);
    }
  }
}

final localeProvider =
    NotifierProvider<LocaleController, Locale?>(LocaleController.new);
