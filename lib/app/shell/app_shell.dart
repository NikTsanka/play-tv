import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/window/fullscreen.dart';
import '../../domain/recording/recording_providers.dart';
import '../../domain/recording/schedule.dart';
import '../../l10n/generated/app_localizations.dart';
import '../theme/theme_controller.dart';

/// App shell: a left [NavigationRail] (TV / desktop friendly) hosting the
/// branch pages, plus a top-bar quick light/dark toggle.
class AppShell extends ConsumerWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    // Start the scheduler app-wide and surface fired reminders.
    ref.watch(schedulerProvider);
    ref.listen<AsyncValue<ScheduledTask>>(schedulerEventsProvider,
        (prev, next) {
      final ScheduledTask? task = next.valueOrNull;
      if (task == null) return;
      if (task.kind == ScheduledKind.reminder || task.kind == ScheduledKind.zap) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(task.title ?? task.channelName ?? l10n.navRecordings),
        ));
      }
    });

    final bool fullscreen = ref.watch(fullscreenProvider);
    final ThemeMode mode = ref.watch(themeModeProvider);
    final Brightness platformBrightness =
        MediaQuery.platformBrightnessOf(context);
    final bool isDark = switch (mode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system => platformBrightness == Brightness.dark,
    };

    return Scaffold(
      body: Row(
        children: <Widget>[
          // The whole nav rail collapses in fullscreen (F11) so only the
          // active page is shown.
          if (!fullscreen)
          ColoredBox(
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: <Widget>[
                // Destinations scroll so the rail never overflows on short
                // windows; the theme toggle stays pinned and always tappable.
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: constraints.maxHeight),
                        child: IntrinsicHeight(
                          child: NavigationRail(
                            selectedIndex: navigationShell.currentIndex,
                            onDestinationSelected: (index) =>
                                navigationShell.goBranch(
                              index,
                              initialLocation:
                                  index == navigationShell.currentIndex,
                            ),
                            labelType: NavigationRailLabelType.all,
                            leading: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              child: _BrandMark(title: l10n.appTitle),
                            ),
                            destinations: <NavigationRailDestination>[
                              NavigationRailDestination(
                                icon: const Icon(Icons.home_outlined),
                                selectedIcon: const Icon(Icons.home),
                                label: Text(l10n.navHome),
                              ),
                              NavigationRailDestination(
                                icon: const Icon(Icons.live_tv_outlined),
                                selectedIcon: const Icon(Icons.live_tv),
                                label: Text(l10n.navTv),
                              ),
                              NavigationRailDestination(
                                icon: const Icon(Icons.calendar_month_outlined),
                                selectedIcon: const Icon(Icons.calendar_month),
                                label: Text(l10n.navGuide),
                              ),
                              NavigationRailDestination(
                                icon: const Icon(Icons.movie_outlined),
                                selectedIcon: const Icon(Icons.movie),
                                label: Text(l10n.navVod),
                              ),
                              NavigationRailDestination(
                                icon: const Icon(Icons.play_circle_outline),
                                selectedIcon: const Icon(Icons.play_circle),
                                label: Text(l10n.navPlayer),
                              ),
                              NavigationRailDestination(
                                icon: const Icon(
                                    Icons.fiber_manual_record_outlined),
                                selectedIcon:
                                    const Icon(Icons.fiber_manual_record),
                                label: Text(l10n.navRecordings),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: IconButton(
                    tooltip: l10n.toggleTheme,
                    icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                    onPressed: () => ref
                        .read(themeModeProvider.notifier)
                        .toggle(platformBrightness),
                  ),
                ),
              ],
            ),
          ),
          if (!fullscreen) const VerticalDivider(width: 1),
          // Group page-content focus so D-pad traversal stays within the active
          // page and doesn't jump back to the rail unexpectedly (spec §9).
          Expanded(child: FocusTraversalGroup(child: navigationShell)),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(Icons.live_tv, color: scheme.primary, size: 28),
        const SizedBox(height: 4),
        SizedBox(
          width: 72,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
