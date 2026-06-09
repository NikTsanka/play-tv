import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/locale_controller.dart';
import '../../app/theme/theme_controller.dart';
import '../../l10n/generated/app_localizations.dart';

/// Settings — milestone 1 covers Appearance (theme mode + language) + About.
/// The full settings groups (Playback, Video, Audio, Network, Record, …) land
/// in later milestones.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ThemeMode mode = ref.watch(themeModeProvider);
    final Locale? locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: <Widget>[
          _SectionHeader(l10n.settingsAppearance),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: Text(l10n.settingsThemeMode),
            trailing: SegmentedButton<ThemeMode>(
              segments: <ButtonSegment<ThemeMode>>[
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text(l10n.settingsThemeSystem),
                  icon: const Icon(Icons.brightness_auto),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(l10n.settingsThemeLight),
                  icon: const Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text(l10n.settingsThemeDark),
                  icon: const Icon(Icons.dark_mode),
                ),
              ],
              selected: <ThemeMode>{mode},
              onSelectionChanged: (sel) =>
                  ref.read(themeModeProvider.notifier).set(sel.first),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.settingsLanguage),
            trailing: DropdownButton<String>(
              value: locale?.languageCode ?? 'system',
              underline: const SizedBox.shrink(),
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem(value: 'system', child: Text('System')),
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'ka', child: Text('ქართული')),
                DropdownMenuItem(value: 'ru', child: Text('Русский')),
              ],
              onChanged: (code) => ref.read(localeProvider.notifier).set(
                    code == null || code == 'system' ? null : Locale(code),
                  ),
            ),
          ),
          const Divider(height: 32),
          _SectionHeader(l10n.settingsAbout),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.appTitle),
            subtitle: Text(l10n.settingsVersion('0.1.0')),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 8, bottom: 4),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
