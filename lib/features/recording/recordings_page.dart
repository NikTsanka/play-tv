import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../domain/channels/channels_providers.dart';
import '../../domain/channels/zapping_controller.dart';
import '../../domain/playback/playback_providers.dart';
import '../../domain/playback/playback_status.dart';
import '../../domain/recording/recorded_file.dart';
import '../../domain/recording/recorder.dart';
import '../../domain/recording/recording_providers.dart';
import '../../domain/recording/schedule.dart';
import '../../l10n/generated/app_localizations.dart';

/// Recordings hub (spec §10): in-flight recordings, scheduled tasks, and the
/// recorded-files browser. Records the currently-tuned channel on demand.
class RecordingsPage extends ConsumerWidget {
  const RecordingsPage({super.key});

  Future<void> _recordCurrent(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final channel = ref.read(zappingProvider).current;
    if (channel == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.recNothingPlaying)));
      return;
    }
    final int? sourceId = ref.read(currentPlaylistProvider);
    await ref
        .read(recordingControllerProvider.notifier)
        .recordChannel(channel, sourceId);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.recStarted)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.navRecordings),
          actions: <Widget>[
            IconButton(
              tooltip: l10n.recRecordChannel,
              icon: const Icon(Icons.fiber_manual_record, color: Colors.red),
              onPressed: () => _recordCurrent(context, ref),
            ),
            const SizedBox(width: 8),
          ],
          bottom: TabBar(
            tabs: <Widget>[
              Tab(text: l10n.recTabActive),
              Tab(text: l10n.recTabScheduled),
              Tab(text: l10n.recTabFiles),
            ],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[
            _ActiveTab(),
            _ScheduledTab(),
            _FilesTab(),
          ],
        ),
      ),
    );
  }
}

class _ActiveTab extends ConsumerWidget {
  const _ActiveTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<RecordingStatus> recordings =
        ref.watch(recordingControllerProvider);
    if (recordings.isEmpty) {
      return _Empty(icon: Icons.fiber_manual_record_outlined, text: l10n.recNoActive);
    }
    return ListView.separated(
      itemCount: recordings.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final RecordingStatus r = recordings[i];
        final String state = switch (r.state) {
          RecordingState.connecting => l10n.recConnecting,
          RecordingState.error => '${l10n.recError}: ${r.error ?? ''}',
          _ => l10n.recRecording,
        };
        return ListTile(
          leading: Icon(Icons.fiber_manual_record,
              color: r.state == RecordingState.error
                  ? Theme.of(context).colorScheme.error
                  : Colors.red),
          title: Text(r.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text('$state  ·  ${_bytes(r.bytes)}'),
          trailing: IconButton(
            tooltip: l10n.recStop,
            icon: const Icon(Icons.stop),
            onPressed: () =>
                ref.read(recordingControllerProvider.notifier).stop(r.id),
          ),
        );
      },
    );
  }
}

class _ScheduledTab extends ConsumerWidget {
  const _ScheduledTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<ScheduledTask> tasks =
        ref.watch(scheduledTasksProvider).valueOrNull ?? const <ScheduledTask>[];
    if (tasks.isEmpty) {
      return _Empty(icon: Icons.event_outlined, text: l10n.recNoScheduled);
    }
    return ListView.separated(
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final ScheduledTask t = tasks[i];
        return ListTile(
          leading: Icon(_kindIcon(t.kind)),
          title: Text(t.title ?? t.channelName ?? t.kind.id,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(_when(t.fireAt.toLocal())),
          trailing: IconButton(
            tooltip: l10n.recDelete,
            icon: const Icon(Icons.delete_outline),
            onPressed: t.id == null
                ? null
                : () => ref.read(scheduleRepositoryProvider).delete(t.id!),
          ),
        );
      },
    );
  }

  static IconData _kindIcon(ScheduledKind kind) => switch (kind) {
        ScheduledKind.record => Icons.fiber_manual_record,
        ScheduledKind.reminder => Icons.notifications_outlined,
        ScheduledKind.zap => Icons.swap_horiz,
        ScheduledKind.sleepTimer => Icons.bedtime_outlined,
      };
}

class _FilesTab extends ConsumerWidget {
  const _FilesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<List<RecordedFile>> files = ref.watch(recordedFilesProvider);
    return files.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (List<RecordedFile> list) {
        if (list.isEmpty) {
          return _Empty(icon: Icons.video_file_outlined, text: l10n.recNoFiles);
        }
        return ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final RecordedFile f = list[i];
            return ListTile(
              leading: const Icon(Icons.movie_outlined),
              title: Text(f.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text('${f.sizeLabel}  ·  ${_when(f.modified)}'),
              onTap: () async {
                await ref.read(playbackEngineProvider).open(
                    PlayRequest(url: Uri.file(f.path).toString(), title: f.name));
                if (context.mounted) context.go(Routes.player);
              },
              trailing: IconButton(
                tooltip: l10n.recDelete,
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  await File(f.path).delete();
                  ref.invalidate(recordedFilesProvider);
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 64, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(text, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}

String _bytes(int b) {
  const List<String> units = <String>['B', 'KB', 'MB', 'GB'];
  double size = b.toDouble();
  int u = 0;
  while (size >= 1024 && u < units.length - 1) {
    size /= 1024;
    u++;
  }
  return '${size.toStringAsFixed(u == 0 ? 0 : 1)} ${units[u]}';
}

String _when(DateTime t) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${t.year}-${two(t.month)}-${two(t.day)} ${two(t.hour)}:${two(t.minute)}';
}
