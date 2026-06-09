import 'package:flutter/material.dart';

/// StreamHub palette — Gold / White / Black.
///
/// Gold is reserved for accents, focus rings, selection, the EPG "now" line,
/// active tabs and key actions — never large fills. Neutrals are pure white and
/// near-black so the gold reads as luxury, not gaudy.
abstract final class AppColors {
  const AppColors._();

  /// Primary accent (light mode).
  static const Color gold = Color(0xFFD4AF37);

  /// Brighter gold for dark surfaces so the accent pops.
  static const Color goldBright = Color(0xFFE6C463);

  /// Deep gold for pressed/active states and gradients.
  static const Color goldDeep = Color(0xFFB8902A);

  static const Color white = Color(0xFFFFFFFF);

  /// Near-black primary surface (dark mode background).
  static const Color black = Color(0xFF0D0D0D);

  /// Slightly raised near-black for cards / elevated surfaces (dark mode).
  static const Color blackElevated = Color(0xFF1A1A1A);

  /// Soft grey for elevated surfaces in light mode.
  static const Color lightSurface = Color(0xFFF4F4F5);

  static const Color error = Color(0xFFB3261E);
}
