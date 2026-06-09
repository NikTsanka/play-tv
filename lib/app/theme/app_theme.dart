import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Builds the light and dark [ThemeData] for StreamHub.
///
/// Material 3, seeded from gold, with explicit neutrals (white / near-black) and
/// a refined serif display family for headings + a clean sans for body.
abstract final class AppTheme {
  const AppTheme._();

  // Headings use a serif for an elegant, "premium" feel; body stays sans.
  // 'serif'/'sans-serif' are guaranteed platform fallbacks — a bundled font
  // (e.g. Playfair Display) can be dropped in later without touching call sites.
  static const String _displayFamily = 'serif';

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color accent = isDark ? AppColors.goldBright : AppColors.gold;

    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.gold,
      brightness: brightness,
      primary: accent,
      onPrimary: isDark ? AppColors.black : AppColors.black,
      secondary: accent,
      surface: isDark ? AppColors.black : AppColors.white,
      onSurface: isDark ? AppColors.white : AppColors.black,
      surfaceContainerHighest:
          isDark ? AppColors.blackElevated : AppColors.lightSurface,
      error: AppColors.error,
    );

    final ThemeData base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );

    return base.copyWith(
      textTheme: _textTheme(base.textTheme, scheme),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: _displayFamily,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerHighest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.4)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: AppColors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: accent, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      // A visible gold focus highlight is essential for 10-foot / D-pad nav.
      focusColor: accent.withValues(alpha: 0.30),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: accent.withValues(alpha: 0.18),
        selectedIconTheme: IconThemeData(color: accent),
        selectedLabelTextStyle: TextStyle(color: scheme.onSurface),
        unselectedIconTheme:
            IconThemeData(color: scheme.onSurface.withValues(alpha: 0.6)),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.5),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base, ColorScheme scheme) {
    TextStyle display(TextStyle? s) => (s ?? const TextStyle()).copyWith(
          fontFamily: _displayFamily,
          color: scheme.onSurface,
        );
    return base.copyWith(
      displayLarge: display(base.displayLarge),
      displayMedium: display(base.displayMedium),
      displaySmall: display(base.displaySmall),
      headlineLarge: display(base.headlineLarge),
      headlineMedium: display(base.headlineMedium),
      headlineSmall: display(base.headlineSmall),
      titleLarge: display(base.titleLarge).copyWith(fontWeight: FontWeight.w600),
    );
  }
}
