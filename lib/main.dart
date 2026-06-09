import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/logging/app_logger.dart';
import 'core/storage/app_paths.dart';
import 'core/storage/preferences.dart';
import 'core/window/fullscreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the playback core (libmpv) before any engine is created.
  MediaKit.ensureInitialized();

  // Desktop window control (enables F11 fullscreen).
  await Fullscreen.init();

  // Bootstrap: app-data folders + simple settings store.
  await AppPaths.init();
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  log.i('StreamHub starting up');

  runApp(
    ProviderScope(
      overrides: <Override>[
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const StreamHubApp(),
    ),
  );
}
