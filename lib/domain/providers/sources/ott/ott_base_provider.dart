import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/http/user_agents.dart';
import '../../../channels/channel.dart';
import '../../provider.dart';
import '../../provider_config.dart';
import '../../provider_type.dart';
import 'ott_models.dart';
import 'ott_service.dart';
import 'ott_session.dart';

/// Serializes async actions FIFO — these session-stateful APIs must not run
/// concurrently (spec C.2: one StackProcessor per provider).
class _SerialLock {
  Future<void> _tail = Future<void>.value();

  Future<T> run<T>(Future<T> Function() action) {
    final Completer<void> gate = Completer<void>();
    final Future<void> previous = _tail;
    _tail = gate.future;
    return previous.then((_) => action()).whenComplete(gate.complete);
  }
}

/// The shared OTT provider (spec §4.4 / Appendix C). Owns the login → channel
/// list → per-zap GetUrl → re-login flow; delegates every service-specific
/// detail to an [OttService]. The handshake session lives here and is reused
/// across zaps by the StreamResolver cache.
class OttBaseProvider extends Provider {
  OttBaseProvider(this.service, this.config, {http.Client? httpClient})
      : _injectedClient = httpClient;

  final OttService service;
  final ProviderConfig config;
  final http.Client? _injectedClient;
  http.Client? _ownedClient;
  final _SerialLock _lock = _SerialLock();

  /// Created lazily so merely building a provider (e.g. capability checks) opens
  /// no socket; injected clients are owned by the caller.
  http.Client get _http =>
      _injectedClient ?? (_ownedClient ??= http.Client());

  OttSession? _session;

  String get _base =>
      config.location.isNotEmpty ? config.location : service.defaultBaseUrl;
  String get _username => config.setting('username') ?? '';
  String get _password => config.setting('password') ?? '';

  @override
  String get caption => config.caption;

  @override
  ProviderType get type => ProviderType.ott;

  @override
  Set<ProviderFunction> get availableFunctions => service.functions;

  @override
  Duration get updateInterval => config.updateInterval;

  @override
  Future<void> fetchChannelList(ChannelSink sink, CancelToken ct) async {
    final dynamic json =
        await _call(() => service.channelListRequest(_base, _session!));
    ct.throwIfCancelled();

    final List<OttGroup> groups = service.parseChannelList(json);
    for (final OttGroup group in groups) {
      for (final OttChannel c in group.channels) {
        sink.add(Channel(
          id: 'ott:${service.id}:${c.id}',
          name: c.name,
          // Resolved per zap via GetUrl; no static URL exists.
          url: '',
          group: group.name,
          logoUrl: (c.logo != null && c.logo!.isNotEmpty) ? c.logo : null,
          epgId: (c.epgId != null && c.epgId!.isNotEmpty) ? c.epgId : null,
          number: c.number,
          props: <String, String>{
            'cid': c.id,
            if (c.protected) 'protected': 'true',
            if (c.hasArchive) 'archive': 'true',
          },
        ));
      }
    }

    final String? guide = service.epgUrl(_base, _session!);
    if (guide != null) sink.epgUrl = guide;
  }

  @override
  Future<String?> resolveStreamUrl(Channel channel) async {
    final String? cid = channel.props['cid'];
    if (cid == null || cid.isEmpty) return null;

    final OttGetUrlParams params = OttGetUrlParams(
      channelId: cid,
      protectCode: channel.props['protected'] == 'true'
          ? config.setting('parentalCode')
          : null,
      bitrate: config.setting('bitrate'),
      sourceServer: config.setting('server'),
    );
    final dynamic json =
        await _call(() => service.getUrlRequest(_base, _session!, params));
    return service.parseGetUrl(json, _base);
  }

  @override
  Future<void> dispose() async {
    _ownedClient?.close();
    _ownedClient = null;
    _session = null;
  }

  // ---- pipeline ---------------------------------------------------------

  /// Runs one command through the serial processor: ensures a session, executes
  /// [build], and on an auth error re-logs-in and retries exactly once
  /// (spec C.2). [build] is a closure so it reads the *current* session.
  Future<dynamic> _call(OttRequest Function() build) {
    return _lock.run(() async {
      if (!(_session?.isValid ?? false)) await _login();

      dynamic json = await _get(build());
      if (service.isAuthError(json)) {
        await _login();
        json = await _get(build());
        if (service.isAuthError(json)) {
          throw OttException('Session expired (re-login failed)');
        }
      }
      return json;
    });
  }

  /// Logs in and stores the session. Lock-free: only called from within [_call].
  Future<void> _login() async {
    final dynamic json =
        await _get(service.loginRequest(_base, _username, _password));
    if (service.isAuthError(json)) {
      throw OttException('Login failed');
    }
    final OttSession session = service.parseLogin(json);
    if (session.sid == null || session.sid!.isEmpty) {
      throw OttException('Login returned no session id');
    }
    session.issuedAt ??= DateTime.now();
    _session = session;
  }

  Future<dynamic> _get(OttRequest req) async {
    final http.Response resp = await _http.get(
      req.uri,
      headers: <String, String>{
        'User-Agent': UserAgents.iptv,
        ...req.headers,
      },
    );
    if (resp.statusCode != 200) {
      throw OttException('HTTP ${resp.statusCode}');
    }
    try {
      return jsonDecode(resp.body);
    } catch (_) {
      throw OttException('Non-JSON response');
    }
  }
}
