import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../l10n/generated/app_localizations.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.live_tv, size: 64, color: theme.colorScheme.primary),
                const SizedBox(height: 24),
                Text(l10n.homeWelcomeTitle,
                    style: theme.textTheme.headlineMedium),
                const SizedBox(height: 12),
                Text(l10n.homeWelcomeBody, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    FilledButton.icon(
                      onPressed: () => context.go(Routes.settings),
                      icon: const Icon(Icons.settings),
                      label: Text(l10n.homeOpenSettings),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.go(Routes.showcase),
                      icon: const Icon(Icons.palette),
                      label: Text(l10n.homeOpenShowcase),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
