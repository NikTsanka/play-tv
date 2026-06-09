import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import '../../domain/channels/channel.dart';
import '../../domain/channels/channels_providers.dart';
import '../../domain/channels/import/catchup_url_builder.dart';
import '../../domain/epg/epg_models.dart';
import '../../domain/epg/epg_providers.dart';
import '../../domain/playback/playback_providers.dart';
import '../../domain/playback/playback_status.dart';
import '../../domain/recording/recording_providers.dart';
import '../../domain/recording/schedule.dart';
import '../../l10n/generated/app_localizations.dart';
import 'widgets/import_epg_dialog.dart';

const double _pxPerMin = 5;
const double _rowHeight = 56;
const double _headerHeight = 44;
const double _nameColWidth = 210;
const int _windowMinutes = 12 * 60;

class EpgPage extends ConsumerStatefulWidget {
  const EpgPage({super.key});

  @override
  ConsumerState<EpgPage> createState() => _EpgPageState();
}

class _GridData {
  _GridData(this.rows, this.byEpgId);
  final List<MapEntry<Channel, String>> rows; // channel + epg id
  final Map<String, List<EpgProgramme>> byEpgId;
}

class _EpgPageState extends ConsumerState<EpgPage> {
  late final LinkedScrollControllerGroup _hGroup;
  late final LinkedScrollControllerGroup _vGroup;
  late final ScrollController _headerH;
  late final ScrollController _bodyH;
  late final ScrollController _namesV;
  late final ScrollController _bodyV;

  late DateTime _rangeStart;
  String _dataKey = '';
  Future<_GridData>? _dataFuture;
  bool _autoScrolled = false;

  double get _totalWidth => _windowMinutes * _pxPerMin;

  @override
  void initState() {
    super.initState();
    _hGroup = LinkedScrollControllerGroup();
    _vGroup = LinkedScrollControllerGroup();
    _headerH = _hGroup.addAndGet();
    _bodyH = _hGroup.addAndGet();
    _namesV = _vGroup.addAndGet();
    _bodyV = _vGroup.addAndGet();
    final now = DateTime.now();
    final floored = now.subtract(Duration(
        minutes: now.minute % 30, seconds: now.second, milliseconds: now.millisecond));
    _rangeStart = floored.subtract(const Duration(minutes: 60));
  }

  @override
  void dispose() {
    _headerH.dispose();
    _bodyH.dispose();
    _namesV.dispose();
    _bodyV.dispose();
    super.dispose();
  }

  Future<_GridData> _load(List<Channel> channels, Map<String, String> map) async {
    final rows = <MapEntry<Channel, String>>[
      for (final c in channels)
        if (map[c.id] != null) MapEntry(c, map[c.id]!),
    ];
    final epgIds = rows.map((e) => e.value).toSet().toList();
    final progs = await ref.read(epgRepositoryProvider).programmesInWindow(
        epgIds, _rangeStart, _rangeStart.add(const Duration(minutes: _windowMinutes)));
    final byEpgId = <String, List<EpgProgramme>>{};
    for (final p in progs) {
      byEpgId.putIfAbsent(p.channelId, () => <EpgProgramme>[]).add(p);
    }
    return _GridData(rows, byEpgId);
  }

  double _nowX(DateTime now) =>
      (now.difference(_rangeStart).inSeconds / 60.0 * _pxPerMin)
          .clamp(0.0, _totalWidth);

  void _jumpToNow(DateTime now) {
    final target = (_nowX(now) - 240).clamp(0.0, _bodyH.position.maxScrollExtent);
    _bodyH.animateTo(target,
        duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final clock = ref.watch(epgClockProvider).valueOrNull ?? DateTime.now();
    final channels = ref.watch(flatChannelsProvider);
    final mapAsync = ref.watch(channelEpgMapProvider);
    final count = ref.watch(epgProgrammeCountProvider).valueOrNull ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navGuide),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.epgJumpToNow,
            icon: const Icon(Icons.schedule),
            onPressed: () => _jumpToNow(clock),
          ),
          IconButton(
            tooltip: l10n.epgImportTitle,
            icon: const Icon(Icons.download),
            onPressed: () async {
              final n = await showImportEpgDialog(context);
              if (n != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.epgImported(n))));
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: count == 0
          ? _EmptyState(
              onImport: () => showImportEpgDialog(context),
            )
          : mapAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (map) {
                final key = '${channels.length}:${map.length}:$count';
                if (key != _dataKey) {
                  _dataKey = key;
                  _dataFuture = _load(channels, map);
                  _autoScrolled = false;
                }
                return FutureBuilder<_GridData>(
                  future: _dataFuture,
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final data = snap.data!;
                    if (data.rows.isEmpty) {
                      return Center(child: Text(l10n.epgNoMatches));
                    }
                    if (!_autoScrolled) {
                      _autoScrolled = true;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) _jumpToNow(clock);
                      });
                    }
                    return _grid(context, data, clock);
                  },
                );
              },
            ),
    );
  }

  Widget _grid(BuildContext context, _GridData data, DateTime clock) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: <Widget>[
        // Header: corner + time ruler.
        SizedBox(
          height: _headerHeight,
          child: Row(
            children: <Widget>[
              SizedBox(
                width: _nameColWidth,
                child: Center(
                  child: Text(_dayLabel(_rangeStart),
                      style: Theme.of(context).textTheme.labelMedium),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _headerH,
                  physics: const NeverScrollableScrollPhysics(),
                  child: SizedBox(
                      width: _totalWidth,
                      child: _TimeRuler(rangeStart: _rangeStart)),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.4)),
        Expanded(
          child: Row(
            children: <Widget>[
              // Channel name column.
              SizedBox(
                width: _nameColWidth,
                child: ListView.builder(
                  controller: _namesV,
                  itemExtent: _rowHeight,
                  itemCount: data.rows.length,
                  itemBuilder: (context, i) =>
                      _ChannelNameCell(channel: data.rows[i].key),
                ),
              ),
              VerticalDivider(
                  width: 1,
                  color: scheme.outlineVariant.withValues(alpha: 0.4)),
              // Programme grid body.
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _bodyH,
                  child: SizedBox(
                    width: _totalWidth,
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: ListView.builder(
                            controller: _bodyV,
                            itemExtent: _rowHeight,
                            itemCount: data.rows.length,
                            itemBuilder: (context, i) {
                              final ch = data.rows[i].key;
                              final progs =
                                  data.byEpgId[data.rows[i].value] ??
                                      const <EpgProgramme>[];
                              return _ProgrammeRow(
                                channel: ch,
                                programmes: progs,
                                rangeStart: _rangeStart,
                                now: clock,
                                onTap: (p) => _showDetails(context, ch, p),
                              );
                            },
                          ),
                        ),
                        // Now line.
                        Positioned(
                          left: _nowX(clock),
                          top: 0,
                          bottom: 0,
                          width: 2,
                          child: ColoredBox(color: scheme.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDetails(BuildContext context, Channel ch, EpgProgramme p) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(p.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              '${ch.name}  ·  ${_timeLabel(p.start.toLocal())}–${_timeLabel(p.stop.toLocal())}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (p.category != null) ...<Widget>[
              const SizedBox(height: 8),
              Chip(label: Text(p.category!)),
            ],
            if (p.description != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(p.description!),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: <Widget>[
                if (ch.hasArchive && p.start.isBefore(DateTime.now()))
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _watchCatchup(ch, p);
                    },
                    icon: const Icon(Icons.history),
                    label: Text(l10n.epgWatchCatchup),
                  ),
                if (p.stop.isAfter(DateTime.now()))
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _scheduleRecord(ch, p);
                    },
                    icon: const Icon(Icons.fiber_manual_record, color: Colors.red),
                    label: Text(l10n.recRecord),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scheduleRecord(Channel ch, EpgProgramme p) async {
    final l10n = AppLocalizations.of(context);
    final DateTime now = DateTime.now();
    final ScheduledTask task = ScheduledTask(
      kind: ScheduledKind.record,
      fireAt: p.start.isAfter(now) ? p.start : now,
      endAt: p.stop,
      sourceId: ref.read(currentPlaylistProvider),
      channelId: ch.id,
      channelName: ch.name,
      channelUrl: ch.url,
      title: p.title,
    );
    await ref.read(scheduleRepositoryProvider).add(task);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.recScheduled)));
    }
  }

  void _watchCatchup(Channel ch, EpgProgramme p) {
    final url = const CatchupUrlBuilder().build(
      liveUrl: ch.url,
      catchup: ch.catchup,
      startUtc: p.start,
      endUtc: p.stop,
    );
    if (url == null) return;
    ref.read(playbackEngineProvider).open(PlayRequest(
          url: url,
          title: '${ch.name} — ${p.title}',
          headers: ch.headers,
          isLiveHint: false,
        ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${ch.name} — ${p.title}')),
    );
  }
}

class _TimeRuler extends StatelessWidget {
  const _TimeRuler({required this.rangeStart});
  final DateTime rangeStart;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ticks = <Widget>[];
    for (int m = 0; m < _windowMinutes; m += 30) {
      final t = rangeStart.add(Duration(minutes: m)).toLocal();
      ticks.add(Positioned(
        left: m * _pxPerMin,
        top: 0,
        bottom: 0,
        child: Container(
          width: 30 * _pxPerMin,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 6),
          decoration: BoxDecoration(
            border: Border(
                left: BorderSide(
                    color: scheme.outlineVariant.withValues(alpha: 0.4))),
          ),
          child: Text(_timeLabel(t),
              style: TextStyle(
                  fontSize: 12, color: scheme.onSurfaceVariant)),
        ),
      ));
    }
    return Stack(children: ticks);
  }
}

class _ChannelNameCell extends StatelessWidget {
  const _ChannelNameCell({required this.channel});
  final Channel channel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(
                color: scheme.outlineVariant.withValues(alpha: 0.25))),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 26,
            child: Text(channel.number?.toString() ?? '',
                style: TextStyle(
                    fontSize: 12, color: scheme.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(channel.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _ProgrammeRow extends StatelessWidget {
  const _ProgrammeRow({
    required this.channel,
    required this.programmes,
    required this.rangeStart,
    required this.now,
    required this.onTap,
  });

  final Channel channel;
  final List<EpgProgramme> programmes;
  final DateTime rangeStart;
  final DateTime now;
  final void Function(EpgProgramme) onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cells = <Widget>[];
    for (final p in programmes) {
      final double left =
          p.start.difference(rangeStart).inSeconds / 60.0 * _pxPerMin;
      final double width = (p.duration.inSeconds / 60.0 * _pxPerMin) - 2;
      if (width <= 0) continue;
      final bool live = p.isLiveAt(now);
      cells.add(Positioned(
        left: left < 0 ? 0 : left,
        width: left < 0 ? (width + left).clamp(0, _windowMinutes * _pxPerMin) : width,
        top: 3,
        bottom: 3,
        child: _ProgrammeCell(
            programme: p, live: live, onTap: () => onTap(p)),
      ));
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(
                color: scheme.outlineVariant.withValues(alpha: 0.2))),
      ),
      child: Stack(clipBehavior: Clip.hardEdge, children: cells),
    );
  }
}

class _ProgrammeCell extends StatelessWidget {
  const _ProgrammeCell({
    required this.programme,
    required this.live,
    required this.onTap,
  });

  final EpgProgramme programme;
  final bool live;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 2),
      child: Material(
        color: live
            ? scheme.primary.withValues(alpha: 0.22)
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(programme.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: live ? FontWeight.w700 : FontWeight.w500,
                        color: live ? scheme.primary : scheme.onSurface)),
                Text(_timeLabel(programme.start.toLocal()),
                    style: TextStyle(
                        fontSize: 10, color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onImport});
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.calendar_month,
              size: 72, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(l10n.epgEmpty, style: theme.textTheme.titleLarge),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onImport,
            icon: const Icon(Icons.download),
            label: Text(l10n.epgImportTitle),
          ),
        ],
      ),
    );
  }
}

String _timeLabel(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

String _dayLabel(DateTime t) {
  final l = t.toLocal();
  return '${l.day.toString().padLeft(2, '0')}.${l.month.toString().padLeft(2, '0')}';
}
