import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/theme_controller.dart';
import '../../l10n/generated/app_localizations.dart';

/// Demonstrates the gold / white / black palette in both Light and Dark — a
/// required milestone-1 deliverable. Doubles as a quick visual regression check.
class ThemeShowcasePage extends ConsumerWidget {
  const ThemeShowcasePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final Brightness platformBrightness =
        MediaQuery.platformBrightnessOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.showcaseTitle),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.toggleTheme,
            icon: Icon(theme.brightness == Brightness.dark
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () => ref
                .read(themeModeProvider.notifier)
                .toggle(platformBrightness),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: <Widget>[
          _Header(l10n.showcaseColors),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: <Widget>[
              _Swatch(label: l10n.showcaseGold, color: AppColors.gold),
              _Swatch(
                  label: '${l10n.showcaseGold} (dark)',
                  color: AppColors.goldBright),
              _Swatch(
                  label: l10n.showcaseWhite,
                  color: AppColors.white,
                  border: true),
              _Swatch(label: l10n.showcaseBlack, color: AppColors.black),
            ],
          ),
          const SizedBox(height: 32),
          _Header(l10n.showcaseSampleHeading),
          const SizedBox(height: 8),
          Text(l10n.showcaseSampleHeading,
              style: theme.textTheme.displaySmall),
          const SizedBox(height: 12),
          Text(l10n.showcaseSampleBody, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 32),
          _Header(l10n.showcaseButtons),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              FilledButton(
                onPressed: () {},
                child: Text(l10n.showcasePrimaryAction),
              ),
              OutlinedButton(
                onPressed: () {},
                child: Text(l10n.showcaseSecondaryAction),
              ),
              TextButton(onPressed: () {}, child: const Text('Text')),
              const Chip(label: Text('Tag')),
              Icon(Icons.star, color: theme.colorScheme.primary),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Card surface', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 0.62,
                    color: theme.colorScheme.primary,
                    backgroundColor:
                        theme.colorScheme.onSurface.withValues(alpha: 0.12),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      Switch(value: true, onChanged: (_) {}),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Slider(value: 0.4, onChanged: (_) {}),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Text(
      text.toUpperCase(),
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.primary,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.label,
    required this.color,
    this.border = false,
  });

  final String label;
  final Color color;
  final bool border;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 96,
          height: 72,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: border
                ? Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outlineVariant
                        .withValues(alpha: 0.6),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 96,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
