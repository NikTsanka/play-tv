import 'dart:io';

import 'package:window_manager/window_manager.dart';

/// Real OS-level window fullscreen (desktop only) — F11 behaviour that hides
/// the title bar / taskbar, like other apps. No-ops on mobile.
abstract final class Fullscreen {
  const Fullscreen._();

  static bool get isSupported =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  /// Must run after `WidgetsFlutterBinding.ensureInitialized()` in `main`.
  static Future<void> init() async {
    if (!isSupported) return;
    await windowManager.ensureInitialized();
  }

  /// Toggles the window between fullscreen and normal.
  static Future<void> toggle() async {
    if (!isSupported) return;
    final bool on = await windowManager.isFullScreen();
    await windowManager.setFullScreen(!on);
  }

  static Future<void> set(bool on) async {
    if (!isSupported) return;
    await windowManager.setFullScreen(on);
  }
}
