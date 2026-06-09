import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streamhub/app/app.dart';
import 'package:streamhub/core/storage/preferences.dart';
import 'package:streamhub/domain/recording/recording_providers.dart';

/// Common overrides: a non-ticking scheduler (its real Timer.periodic would
/// keep pumpAndSettle from ever settling).
List<Override> _overrides(SharedPreferences prefs) => <Override>[
      sharedPreferencesProvider.overrideWithValue(prefs),
      schedulerProvider.overrideWith((ref) => SchedulerService(ref)),
    ];

void main() {
  testWidgets('App boots to the home page', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(prefs),
        child: const StreamHubApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Welcome copy from the home page is present.
    expect(find.textContaining('StreamHub'), findsWidgets);
  });

  testWidgets('Theme toggle flips brightness', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'app.themeMode': 'light',
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(prefs),
        child: const StreamHubApp(),
      ),
    );
    await tester.pumpAndSettle();

    final BuildContext ctx = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(ctx).brightness, Brightness.light);

    // Tap the rail's dark-mode toggle.
    await tester.tap(find.byIcon(Icons.dark_mode).first);
    await tester.pumpAndSettle();

    final BuildContext ctx2 = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(ctx2).brightness, Brightness.dark);
  });
}
