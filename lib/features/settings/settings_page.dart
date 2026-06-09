import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/locale_controller.dart';
import '../../app/theme/theme_controller.dart';
import '../../core/app_info.dart';
import '../../core/feature_flags.dart';
import '../../core/storage/preferences.dart';
import '../../domain/logos/logo_service.dart';
import '../../domain/parental/parental_control.dart';
import '../../domain/recording/recording_providers.dart';
import '../../domain/tasks/task_manager.dart';
import '../../domain/update/update_service.dart';
import '../../l10n/generated/app_localizations.dart';
import 'widgets/pin_dialog.dart';

/// Settings: Appearance, Maintenance (logos + background tasks), Updates, About.
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
          _SectionHeader(l10n.settingsMaintenance),
          ListTile(
            leading: const Icon(Icons.image_outlined),
            title: Text(l10n.settingsDownloadLogos),
            subtitle: Text(l10n.settingsDownloadLogosSub),
            trailing: const Icon(Icons.download),
            onTap: () => ref.read(downloadCurrentLogosProvider)(),
          ),
          const _TasksPanel(),
          const Divider(height: 32),
          _SectionHeader(l10n.settingsParental),
          const _ParentalTile(),
          const Divider(height: 32),
          _SectionHeader(l10n.settingsRecording),
          const _RecordingTemplateTile(),
          if (FeatureFlags.chromecast) ...<Widget>[
            const Divider(height: 32),
            _SectionHeader(l10n.settingsCast),
            ListTile(
              leading: const Icon(Icons.cast),
              title: Text(l10n.settingsCast),
              subtitle: Text(l10n.settingsCastSoon),
              enabled: false,
            ),
          ],
          const Divider(height: 32),
          _SectionHeader(l10n.settingsUpdates),
          const _UpdatesTile(),
          const Divider(height: 32),
          _SectionHeader(l10n.settingsAbout),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.appTitle),
            subtitle: Text(l10n.settingsVersion(AppInfo.appVersion)),
          ),
        ],
      ),
    );
  }
}

/// Live list of background tasks with progress + cancel (spec §11).
class _TasksPanel extends ConsumerWidget {
  const _TasksPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final List<TaskProgress> tasks =
        ref.watch(tasksStreamProvider).valueOrNull ?? const <TaskProgress>[];
    if (tasks.isEmpty) {
      return ListTile(
        leading: const Icon(Icons.checklist_outlined),
        title: Text(l10n.settingsTasks),
        subtitle: Text(l10n.settingsNoTasks),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
          child: Row(
            children: <Widget>[
              Expanded(child: Text(l10n.settingsTasks)),
              TextButton(
                onPressed: () =>
                    ref.read(taskManagerProvider).clearFinished(),
                child: Text(l10n.settingsClearTasks),
              ),
            ],
          ),
        ),
        for (final TaskProgress t in tasks)
          ListTile(
            dense: true,
            leading: _statusIcon(context, t.status),
            title: Text(t.message ?? t.label,
                maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: t.isActive
                ? LinearProgressIndicator(value: t.progress)
                : Text(t.error ?? t.status.name),
            trailing: t.isActive
                ? IconButton(
                    tooltip: l10n.taskCancel,
                    icon: const Icon(Icons.close),
                    onPressed: () => ref.read(taskManagerProvider).cancel(t.id),
                  )
                : null,
          ),
      ],
    );
  }

  Widget _statusIcon(BuildContext context, TaskStatus status) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return switch (status) {
      TaskStatus.completed => Icon(Icons.check_circle, color: scheme.primary),
      TaskStatus.failed => Icon(Icons.error_outline, color: scheme.error),
      TaskStatus.cancelled => const Icon(Icons.cancel_outlined),
      _ => const Icon(Icons.downloading_outlined),
    };
  }
}

/// "Check for updates" with an inline result (spec §11).
class _UpdatesTile extends ConsumerStatefulWidget {
  const _UpdatesTile();

  @override
  ConsumerState<_UpdatesTile> createState() => _UpdatesTileState();
}

class _UpdatesTileState extends ConsumerState<_UpdatesTile> {
  bool _busy = false;
  String? _result;
  bool _isError = false;

  Future<void> _check() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _result = null;
      _isError = false;
    });
    try {
      final UpdateInfo info = await ref.read(updateServiceProvider).check();
      if (!mounted) return;
      setState(() {
        _result = info.available
            ? l10n.settingsUpdateAvailable(info.latest)
            : l10n.settingsUpToDate(info.current);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _result = l10n.settingsUpdateFailed;
        _isError = true;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      leading: const Icon(Icons.system_update_outlined),
      title: Text(l10n.settingsCheckUpdates),
      subtitle: _result == null
          ? null
          : Text(_result!,
              style: _isError
                  ? TextStyle(color: Theme.of(context).colorScheme.error)
                  : null),
      trailing: _busy
          ? const SizedBox(
              width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.refresh),
      onTap: _busy ? null : _check,
    );
  }
}

/// Set / change / remove the parental PIN (spec §9).
class _ParentalTile extends ConsumerWidget {
  const _ParentalTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ParentalState state = ref.watch(parentalControllerProvider);
    final ParentalController ctrl =
        ref.read(parentalControllerProvider.notifier);

    Future<void> setPin() async {
      final String? pin =
          await showPinDialog(context, title: l10n.parentalNewPin);
      if (pin != null) await ctrl.setPin(pin);
    }

    Future<void> changePin() async {
      final String? current =
          await showPinDialog(context, title: l10n.parentalCurrentPin);
      if (current == null || !ctrl.unlock(current)) {
        if (context.mounted && current != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l10n.parentalWrongPin)));
        }
        return;
      }
      if (!context.mounted) return;
      final String? next =
          await showPinDialog(context, title: l10n.parentalNewPin);
      if (next != null) await ctrl.setPin(next);
    }

    Future<void> removePin() async {
      final String? current =
          await showPinDialog(context, title: l10n.parentalCurrentPin);
      if (current == null) return;
      final bool ok = await ctrl.removePin(current);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.parentalWrongPin)));
      }
    }

    return ListTile(
      leading: Icon(state.hasPin ? Icons.lock : Icons.lock_open_outlined),
      title: Text(l10n.settingsParental),
      subtitle:
          Text(state.hasPin ? l10n.settingsParentalOn : l10n.settingsParentalOff),
      trailing: state.hasPin
          ? Wrap(
              spacing: 4,
              children: <Widget>[
                TextButton(
                    onPressed: changePin, child: Text(l10n.settingsChangePin)),
                TextButton(
                    onPressed: removePin, child: Text(l10n.settingsRemovePin)),
              ],
            )
          : FilledButton(onPressed: setPin, child: Text(l10n.settingsSetPin)),
    );
  }
}

/// Edits the recording filename template (wired to PrefKeys.recordingTemplate).
class _RecordingTemplateTile extends ConsumerWidget {
  const _RecordingTemplateTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final String template = ref.watch(recordingTemplateProvider);

    Future<void> edit() async {
      final TextEditingController controller =
          TextEditingController(text: template);
      final String? result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.settingsFilenameTemplate),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: '{channel} - {epgTitle} - {date} {time}',
            ),
            onSubmitted: (v) => Navigator.of(context).pop(v.trim()),
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.commonCancel)),
            FilledButton(
                onPressed: () =>
                    Navigator.of(context).pop(controller.text.trim()),
                child: Text(l10n.commonSave)),
          ],
        ),
      );
      if (result != null && result.isNotEmpty) {
        await ref
            .read(sharedPreferencesProvider)
            .setString(PrefKeys.recordingTemplate, result);
        ref.invalidate(recordingTemplateProvider);
      }
    }

    return ListTile(
      leading: const Icon(Icons.text_fields),
      title: Text(l10n.settingsFilenameTemplate),
      subtitle: Text(template, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.edit_outlined),
      onTap: edit,
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
