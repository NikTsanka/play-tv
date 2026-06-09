import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/window/fullscreen.dart';
import '../l10n/generated/app_localizations.dart';
import 'locale_controller.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

class StreamHubApp extends ConsumerStatefulWidget {
  const StreamHubApp({super.key});

  @override
  ConsumerState<StreamHubApp> createState() => _StreamHubAppState();
}

class _StreamHubAppState extends ConsumerState<StreamHubApp> {
  @override
  void initState() {
    super.initState();
    // App-wide F11 → toggle real window fullscreen (desktop).
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  bool _onKey(KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.f11) {
      ref.read(fullscreenProvider.notifier).toggle();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeMode themeMode = ref.watch(themeModeProvider);
    final Locale? locale = ref.watch(localeProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      // Animate light/dark transitions.
      themeAnimationDuration: const Duration(milliseconds: 350),
      themeAnimationCurve: Curves.easeInOut,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: appRouter,
    );
  }
}
