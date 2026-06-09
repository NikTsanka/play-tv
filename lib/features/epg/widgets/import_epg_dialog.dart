import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/channels/channels_providers.dart';
import '../../../domain/epg/epg_providers.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Imports an XMLTV guide (URL or file). Returns programme count, or null.
Future<int?> showImportEpgDialog(BuildContext context) {
  return showDialog<int>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _ImportEpgDialog(),
  );
}

class _ImportEpgDialog extends ConsumerStatefulWidget {
  const _ImportEpgDialog();

  @override
  ConsumerState<_ImportEpgDialog> createState() => _ImportEpgDialogState();
}

class _ImportEpgDialogState extends ConsumerState<_ImportEpgDialog> {
  late final TextEditingController _urlCtrl;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Pre-fill from the current playlist's discovered `url-tvg`, if any.
    final playlists = ref.read(playlistsProvider).valueOrNull;
    final current = ref.read(currentPlaylistProvider);
    final epgUrl = playlists
        ?.where((p) => p.id == current)
        .map((p) => p.epgUrl)
        .firstWhere((u) => u != null, orElse: () => null);
    _urlCtrl = TextEditingController(text: epgUrl ?? '');
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _run(Future<int> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final count = await action();
      if (mounted) Navigator.of(context).pop(count);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _importUrl() async {
    final url = _urlCtrl.text.trim();
    if (url.isEmpty) {
      setState(() => _error = 'Enter a URL');
      return;
    }
    await _run(() => ref.read(epgRepositoryProvider).importFromUrl(url));
  }

  Future<void> _importFile() async {
    const group =
        XTypeGroup(label: 'XMLTV', extensions: ['xml', 'xmltv', 'gz']);
    final file = await openFile(acceptedTypeGroups: [group]);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    await _run(() => ref.read(epgRepositoryProvider).importFromBytes(bytes));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.epgImportTitle),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _urlCtrl,
              enabled: !_busy,
              decoration: InputDecoration(
                labelText: l10n.epgImportUrl,
                hintText: 'https://…/guide.xml(.gz)',
                prefixIcon: const Icon(Icons.link),
              ),
              onSubmitted: (_) => _busy ? null : _importUrl(),
            ),
            if (_error != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(_error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            if (_busy) ...const <Widget>[
              SizedBox(height: 16),
              LinearProgressIndicator(),
            ],
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        OutlinedButton.icon(
          onPressed: _busy ? null : _importFile,
          icon: const Icon(Icons.folder_open),
          label: Text(l10n.channelsImportFile),
        ),
        FilledButton.icon(
          onPressed: _busy ? null : _importUrl,
          icon: const Icon(Icons.download),
          label: Text(l10n.channelsImportFromUrl),
        ),
      ],
    );
  }
}
