import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/feature_flags.dart';
import '../../domain/channels/channels_providers.dart';
import '../../domain/providers/provider_config.dart';
import '../../domain/providers/provider_type.dart';
import '../../domain/providers/providers_providers.dart';
import '../../domain/providers/sources/iptv_org_provider.dart';
import '../../domain/providers/sources/ott/ott_service.dart';
import '../../l10n/generated/app_localizations.dart';

/// Two-step "add a source" flow: pick a [ProviderType], then fill the
/// type-specific setup form. On success the new source is imported, selected,
/// and its id returned (spec §4 / §9 — provider setup dialogs). Returns `null`
/// if cancelled.
Future<int?> showAddProviderDialog(BuildContext context) {
  return showDialog<int>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _AddProviderDialog(),
  );
}

/// UI metadata for a provider type (icon + localized labels).
class _TypeInfo {
  const _TypeInfo(this.type, this.icon, this.title, this.description);
  final ProviderType type;
  final IconData icon;
  final String title;
  final String description;
}

List<_TypeInfo> _types(AppLocalizations l10n) => <_TypeInfo>[
      _TypeInfo(ProviderType.xtream, Icons.dns_outlined, l10n.providerXtream,
          l10n.providerXtreamDesc),
      _TypeInfo(ProviderType.stalker, Icons.settings_input_antenna,
          l10n.providerStalker, l10n.providerStalkerDesc),
      _TypeInfo(ProviderType.ott, Icons.tv, l10n.providerOtt, l10n.providerOttDesc),
      _TypeInfo(ProviderType.m3uUrl, Icons.link, l10n.providerM3uUrl,
          l10n.providerM3uUrlDesc),
      _TypeInfo(ProviderType.m3uFile, Icons.insert_drive_file_outlined,
          l10n.providerM3uFile, l10n.providerM3uFileDesc),
      _TypeInfo(ProviderType.genericUrl, Icons.play_circle_outline,
          l10n.providerGenericUrl, l10n.providerGenericUrlDesc),
      _TypeInfo(ProviderType.iptvOrg, Icons.public, l10n.providerIptvOrg,
          l10n.providerIptvOrgDesc),
      _TypeInfo(ProviderType.localFolder, Icons.folder_outlined,
          l10n.providerLocalFolder, l10n.providerLocalFolderDesc),
      if (FeatureFlags.youtube)
        _TypeInfo(ProviderType.youtube, Icons.smart_display_outlined,
            l10n.providerYoutube, l10n.providerYoutubeDesc),
    ];

class _AddProviderDialog extends ConsumerStatefulWidget {
  const _AddProviderDialog();

  @override
  ConsumerState<_AddProviderDialog> createState() => _AddProviderDialogState();
}

class _AddProviderDialogState extends ConsumerState<_AddProviderDialog> {
  ProviderType? _type;
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();
  final TextEditingController _codeCtrl = TextEditingController();
  final TextEditingController _userCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _macCtrl = TextEditingController();
  final TextEditingController _loginCtrl = TextEditingController();
  String? _filePath;
  String? _folderPath;
  bool _isRadio = false;
  IptvOrgScope _scope = IptvOrgScope.all;
  OttService _ottService = ottServices.first;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _codeCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    _macCtrl.dispose();
    _loginCtrl.dispose();
    super.dispose();
  }

  void _selectType(ProviderType type, String defaultName) {
    setState(() {
      _type = type;
      _error = null;
      if (_nameCtrl.text.trim().isEmpty) _nameCtrl.text = defaultName;
      // Pre-fill the (editable) base URL for OTT services.
      if (type == ProviderType.ott && _locationCtrl.text.trim().isEmpty) {
        _locationCtrl.text = _ottService.defaultBaseUrl;
      }
    });
  }

  Future<void> _pickFile() async {
    const XTypeGroup group =
        XTypeGroup(label: 'Playlists', extensions: <String>['m3u', 'm3u8']);
    final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[group]);
    if (file == null) return;
    setState(() {
      _filePath = file.path;
      if (_nameCtrl.text.trim().isEmpty) _nameCtrl.text = file.name;
    });
  }

  Future<void> _pickFolder() async {
    final String? dir = await getDirectoryPath();
    if (dir == null) return;
    setState(() {
      _folderPath = dir;
      if (_nameCtrl.text.trim().isEmpty) {
        _nameCtrl.text = dir.split(RegExp(r'[\\/]')).last;
      }
    });
  }

  ProviderConfig? _buildConfig() {
    final ProviderType type = _type!;
    final Map<String, String> settings = <String, String>{};
    String location = '';

    switch (type) {
      case ProviderType.m3uUrl:
        location = _locationCtrl.text.trim();
        if (location.isEmpty) return _fail('Enter a playlist URL');
      case ProviderType.m3uFile:
        if (_filePath == null) return _fail('Choose a file');
        location = _filePath!;
      case ProviderType.genericUrl:
        location = _locationCtrl.text.trim();
        if (location.isEmpty) return _fail('Enter a stream URL');
        settings['isRadio'] = _isRadio.toString();
      case ProviderType.iptvOrg:
        settings['scope'] = _scope.id;
        if (_scope != IptvOrgScope.all) {
          final String code = _codeCtrl.text.trim();
          if (code.isEmpty) return _fail('Enter a code');
          settings['code'] = code;
        }
      case ProviderType.xtream:
        location = _locationCtrl.text.trim();
        if (location.isEmpty) return _fail('Enter the server URL');
        final String user = _userCtrl.text.trim();
        if (user.isEmpty) return _fail('Enter a username');
        settings['username'] = user;
        settings['password'] = _passCtrl.text;
      case ProviderType.stalker:
        location = _locationCtrl.text.trim();
        if (location.isEmpty) return _fail('Enter the portal URL');
        final String mac = _macCtrl.text.trim();
        if (mac.isEmpty) return _fail('Enter a MAC address');
        settings['mac'] = mac;
        if (_loginCtrl.text.trim().isNotEmpty) {
          settings['login'] = _loginCtrl.text.trim();
          settings['password'] = _passCtrl.text;
        }
      case ProviderType.ott:
        location = _locationCtrl.text.trim().isEmpty
            ? _ottService.defaultBaseUrl
            : _locationCtrl.text.trim();
        final String user = _userCtrl.text.trim();
        if (user.isEmpty) return _fail('Enter a username');
        settings['service'] = _ottService.id;
        settings['username'] = user;
        settings['password'] = _passCtrl.text;
        if (_codeCtrl.text.trim().isNotEmpty) {
          settings['parentalCode'] = _codeCtrl.text.trim();
        }
      case ProviderType.localFolder:
        if (_folderPath == null) return _fail('Choose a folder');
        location = _folderPath!;
      case ProviderType.youtube:
        location = _locationCtrl.text.trim();
        if (location.isEmpty) return _fail('Enter a YouTube URL');
    }

    final String name =
        _nameCtrl.text.trim().isEmpty ? type.name : _nameCtrl.text.trim();
    return ProviderConfig(
        type: type, caption: name, location: location, settings: settings);
  }

  ProviderConfig? _fail(String message) {
    setState(() => _error = message);
    return null;
  }

  Future<void> _submit() async {
    final ProviderConfig? config = _buildConfig();
    if (config == null) return;

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final int id = await ref.read(providersManagerProvider).import(config);
      await ref.read(currentPlaylistProvider.notifier).select(id);
      if (mounted) Navigator.of(context).pop(id);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return _type == null ? _buildChooser(l10n) : _buildForm(l10n);
  }

  // ---- Step 1: choose a type -------------------------------------------

  Widget _buildChooser(AppLocalizations l10n) {
    return AlertDialog(
      title: Text(l10n.providersChooseType),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (final _TypeInfo info in _types(l10n))
              ListTile(
                leading: Icon(info.icon,
                    color: Theme.of(context).colorScheme.primary),
                title: Text(info.title),
                subtitle: Text(info.description),
                onTap: () => _selectType(info.type, info.title),
              ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
      ],
    );
  }

  // ---- Step 2: type-specific form --------------------------------------

  Widget _buildForm(AppLocalizations l10n) {
    final _TypeInfo info =
        _types(l10n).firstWhere((t) => t.type == _type);
    return AlertDialog(
      title: Row(
        children: <Widget>[
          Icon(info.icon),
          const SizedBox(width: 10),
          Expanded(child: Text(info.title)),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _nameCtrl,
              enabled: !_busy,
              decoration: InputDecoration(labelText: l10n.providerName),
            ),
            const SizedBox(height: 12),
            ..._fields(l10n),
            if (_error != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(_error!,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            if (_busy) ...<Widget>[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              Text(l10n.providerImporting,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _busy ? null : () => setState(() => _type = null),
          child: Text(l10n.commonBack),
        ),
        FilledButton.icon(
          onPressed: _busy ? null : _submit,
          icon: const Icon(Icons.download),
          label: Text(l10n.providerImport),
        ),
      ],
    );
  }

  List<Widget> _fields(AppLocalizations l10n) {
    switch (_type!) {
      case ProviderType.m3uUrl:
        return <Widget>[
          TextField(
            controller: _locationCtrl,
            enabled: !_busy,
            decoration: InputDecoration(
              labelText: l10n.providerPlaylistUrl,
              hintText: 'https://…/playlist.m3u',
              prefixIcon: const Icon(Icons.link),
            ),
            onSubmitted: (_) => _busy ? null : _submit(),
          ),
        ];
      case ProviderType.m3uFile:
        return <Widget>[
          Row(
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: _busy ? null : _pickFile,
                icon: const Icon(Icons.folder_open),
                label: Text(l10n.providerChooseFile),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _filePath ?? l10n.providerNoFile,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ];
      case ProviderType.genericUrl:
        return <Widget>[
          TextField(
            controller: _locationCtrl,
            enabled: !_busy,
            decoration: InputDecoration(
              labelText: l10n.providerStreamUrl,
              hintText: 'http(s):// , rtsp:// , udp:// …',
              prefixIcon: const Icon(Icons.play_circle_outline),
            ),
            onSubmitted: (_) => _busy ? null : _submit(),
          ),
          const SizedBox(height: 4),
          CheckboxListTile(
            value: _isRadio,
            onChanged: _busy
                ? null
                : (v) => setState(() => _isRadio = v ?? false),
            title: Text(l10n.providerIsRadio),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ];
      case ProviderType.iptvOrg:
        return <Widget>[
          DropdownButtonFormField<IptvOrgScope>(
            initialValue: _scope,
            decoration: InputDecoration(labelText: l10n.providerScope),
            items: <DropdownMenuItem<IptvOrgScope>>[
              DropdownMenuItem<IptvOrgScope>(
                  value: IptvOrgScope.all, child: Text(l10n.providerScopeAll)),
              DropdownMenuItem<IptvOrgScope>(
                  value: IptvOrgScope.country,
                  child: Text(l10n.providerScopeCountry)),
              DropdownMenuItem<IptvOrgScope>(
                  value: IptvOrgScope.category,
                  child: Text(l10n.providerScopeCategory)),
              DropdownMenuItem<IptvOrgScope>(
                  value: IptvOrgScope.language,
                  child: Text(l10n.providerScopeLanguage)),
            ],
            onChanged: _busy
                ? null
                : (v) => setState(() => _scope = v ?? IptvOrgScope.all),
          ),
          if (_scope != IptvOrgScope.all) ...<Widget>[
            const SizedBox(height: 12),
            TextField(
              controller: _codeCtrl,
              enabled: !_busy,
              decoration: InputDecoration(
                labelText: l10n.providerScopeCode,
                hintText: l10n.providerScopeCodeHint,
              ),
              onSubmitted: (_) => _busy ? null : _submit(),
            ),
          ],
        ];
      case ProviderType.xtream:
        return <Widget>[
          TextField(
            controller: _locationCtrl,
            enabled: !_busy,
            decoration: InputDecoration(
              labelText: l10n.providerServerUrl,
              hintText: 'http://example.com:8080',
              prefixIcon: const Icon(Icons.dns_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _userCtrl,
            enabled: !_busy,
            decoration: InputDecoration(
              labelText: l10n.providerUsername,
              prefixIcon: const Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passCtrl,
            enabled: !_busy,
            obscureText: true,
            decoration: InputDecoration(
              labelText: l10n.providerPassword,
              prefixIcon: const Icon(Icons.lock_outline),
            ),
            onSubmitted: (_) => _busy ? null : _submit(),
          ),
        ];
      case ProviderType.stalker:
        return <Widget>[
          TextField(
            controller: _locationCtrl,
            enabled: !_busy,
            decoration: InputDecoration(
              labelText: l10n.providerPortalUrl,
              hintText: 'http://host/c/',
              prefixIcon: const Icon(Icons.settings_input_antenna),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _macCtrl,
            enabled: !_busy,
            decoration: InputDecoration(
              labelText: l10n.providerMac,
              hintText: '00:1A:79:XX:XX:XX',
              prefixIcon: const Icon(Icons.memory),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _loginCtrl,
            enabled: !_busy,
            decoration: InputDecoration(
              labelText: l10n.providerLoginOptional,
              prefixIcon: const Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passCtrl,
            enabled: !_busy,
            obscureText: true,
            decoration: InputDecoration(
              labelText: l10n.providerPassword,
              prefixIcon: const Icon(Icons.lock_outline),
            ),
            onSubmitted: (_) => _busy ? null : _submit(),
          ),
        ];
      case ProviderType.ott:
        return <Widget>[
          DropdownButtonFormField<OttService>(
            initialValue: _ottService,
            decoration: InputDecoration(labelText: l10n.providerOttService),
            items: <DropdownMenuItem<OttService>>[
              for (final OttService s in ottServices)
                DropdownMenuItem<OttService>(
                    value: s, child: Text(s.caption)),
            ],
            onChanged: _busy
                ? null
                : (s) {
                    if (s == null) return;
                    setState(() {
                      _ottService = s;
                      _locationCtrl.text = s.defaultBaseUrl;
                    });
                  },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _locationCtrl,
            enabled: !_busy,
            decoration: InputDecoration(
              labelText: l10n.providerServerUrl,
              prefixIcon: const Icon(Icons.dns_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _userCtrl,
            enabled: !_busy,
            decoration: InputDecoration(
              labelText: l10n.providerUsername,
              prefixIcon: const Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passCtrl,
            enabled: !_busy,
            obscureText: true,
            decoration: InputDecoration(
              labelText: l10n.providerPassword,
              prefixIcon: const Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _codeCtrl,
            enabled: !_busy,
            obscureText: true,
            decoration: InputDecoration(
              labelText: l10n.providerParentalCode,
              prefixIcon: const Icon(Icons.pin_outlined),
            ),
            onSubmitted: (_) => _busy ? null : _submit(),
          ),
        ];
      case ProviderType.localFolder:
        return <Widget>[
          Row(
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: _busy ? null : _pickFolder,
                icon: const Icon(Icons.folder_open),
                label: Text(l10n.providerChooseFolder),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _folderPath ?? l10n.providerNoFolder,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ];
      case ProviderType.youtube:
        return <Widget>[
          TextField(
            controller: _locationCtrl,
            enabled: !_busy,
            decoration: InputDecoration(
              labelText: l10n.providerYoutubeUrl,
              hintText: 'https://youtube.com/playlist?list=…',
              prefixIcon: const Icon(Icons.smart_display_outlined),
            ),
            onSubmitted: (_) => _busy ? null : _submit(),
          ),
        ];
    }
  }
}
