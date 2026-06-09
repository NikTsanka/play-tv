import 'package:go_router/go_router.dart';

import '../features/epg/epg_page.dart';
import '../features/home/home_page.dart';
import '../features/player/player_page.dart';
import '../features/recording/recordings_page.dart';
import '../features/settings/settings_page.dart';
import '../features/theme_showcase/theme_showcase_page.dart';
import '../features/tv/tv_page.dart';
import '../features/vod/vod_page.dart';
import 'shell/app_shell.dart';

/// Route path constants (avoids stringly-typed navigation).
abstract final class Routes {
  const Routes._();
  static const String home = '/';
  static const String tv = '/tv';
  static const String guide = '/guide';
  static const String vod = '/vod';
  static const String player = '/player';
  static const String recordings = '/recordings';
  static const String settings = '/settings';
  static const String showcase = '/showcase';
}

final GoRouter appRouter = GoRouter(
  initialLocation: Routes.home,
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: Routes.home,
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: Routes.tv,
              builder: (context, state) => const TvPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: Routes.guide,
              builder: (context, state) => const EpgPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: Routes.vod,
              builder: (context, state) => const VodPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: Routes.player,
              builder: (context, state) => const PlayerPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: Routes.recordings,
              builder: (context, state) => const RecordingsPage(),
            ),
          ],
        ),
      ],
    ),
    // Settings & Theme showcase live outside the rail (reached from Home /
    // top-bar), so they're pushed full-screen with a back button.
    GoRoute(
      path: Routes.settings,
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: Routes.showcase,
      builder: (context, state) => const ThemeShowcasePage(),
    ),
  ],
);
