import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    // Mobile: hide/show the system status + navigation bars (immersive).
    if (Platform.isAndroid || Platform.isIOS) {
      await SystemChrome.setEnabledSystemUIMode(
        on ? SystemUiMode.immersiveSticky : SystemUiMode.manual,
        overlays: on ? const <SystemUiOverlay>[] : SystemUiOverlay.values,
      );
      return;
    }
    // Desktop: toggle the OS window fullscreen.
    if (!isSupported) return;
    await windowManager.setFullScreen(on);
    // Toggling fullscreen de-activates the native window on Windows, which
    // swallows keyboard/mouse input until re-focused.
    await windowManager.focus();
  }
}

/// App-wide fullscreen state. Toggling it drives both the OS window
/// ([Fullscreen.set]) and the UI (the shell hides the nav rail when true).
class FullscreenController extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> toggle() => set(!state);

  Future<void> set(bool on) async {
    state = on;
    await Fullscreen.set(on);
  }
}

final fullscreenProvider =
    NotifierProvider<FullscreenController, bool>(FullscreenController.new);
