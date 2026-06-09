import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Lifecycle of a single recording.
enum RecordingState { connecting, recording, stopped, error }

/// Immutable snapshot of a recording, emitted on every byte/state change.
@immutable
class RecordingStatus {
  const RecordingStatus({
    required this.id,
    required this.filePath,
    required this.title,
    required this.state,
    this.bytes = 0,
    this.error,
    required this.startedAt,
  });

  final String id;
  final String filePath;
  final String title;
  final RecordingState state;
  final int bytes;
  final String? error;
  final DateTime startedAt;

  bool get isActive =>
      state == RecordingState.connecting || state == RecordingState.recording;

  RecordingStatus copyWith({
    RecordingState? state,
    int? bytes,
    Object? error = _sentinel,
  }) =>
      RecordingStatus(
        id: id,
        filePath: filePath,
        title: title,
        startedAt: startedAt,
        state: state ?? this.state,
        bytes: bytes ?? this.bytes,
        error: error == _sentinel ? this.error : error as String?,
      );

  static const Object _sentinel = Object();
}

/// Records a network stream to a file by dumping the HTTP byte stream
/// (spec §10 "live stream → file"). Works for progressive / MPEG-TS endpoints;
/// segmented HLS would need a remux step (a future ffmpeg-backed `Recorder`).
///
/// One instance records one file. Inject an [http.Client] for tests.
class HttpStreamRecorder {
  HttpStreamRecorder({
    required this.id,
    required this.url,
    required this.filePath,
    required this.title,
    this.headers = const <String, String>{},
    http.Client? client,
  })  : _client = client ?? http.Client(),
        _ownsClient = client == null,
        startedAt = DateTime.now();

  final String id;
  final String url;
  final String filePath;
  final String title;
  final Map<String, String> headers;
  final DateTime startedAt;

  final http.Client _client;
  final bool _ownsClient;

  final StreamController<RecordingStatus> _statusCtrl =
      StreamController<RecordingStatus>.broadcast();
  final Completer<void> _done = Completer<void>();

  StreamSubscription<List<int>>? _sub;
  IOSink? _sink;
  late RecordingStatus _status = RecordingStatus(
    id: id,
    filePath: filePath,
    title: title,
    state: RecordingState.connecting,
    startedAt: startedAt,
  );

  RecordingStatus get status => _status;
  Stream<RecordingStatus> get statusStream => _statusCtrl.stream;

  /// Completes when the recording stops (by EOF, [stop] or error).
  Future<void> get done => _done.future;

  void _emit(RecordingStatus s) {
    _status = s;
    if (!_statusCtrl.isClosed) _statusCtrl.add(s);
  }

  /// Begins streaming bytes to [filePath]. Returns once the connection is
  /// established (or fails); listen to [statusStream] / await [done] for the rest.
  Future<void> start() async {
    try {
      final http.Request req = http.Request('GET', Uri.parse(url))
        ..headers.addAll(headers);
      final http.StreamedResponse resp = await _client.send(req);
      if (resp.statusCode != 200) {
        _fail('HTTP ${resp.statusCode}');
        return;
      }
      _sink = File(filePath).openWrite();
      _emit(_status.copyWith(state: RecordingState.recording));
      _sub = resp.stream.listen(
        (List<int> chunk) {
          _sink!.add(chunk);
          _emit(_status.copyWith(bytes: _status.bytes + chunk.length));
        },
        onError: (Object e) => _fail('$e'),
        onDone: () => _finish(RecordingState.stopped),
        cancelOnError: true,
      );
    } catch (e) {
      _fail('$e');
    }
  }

  /// Stops the recording and flushes the file.
  Future<void> stop() async {
    if (_status.state == RecordingState.recording ||
        _status.state == RecordingState.connecting) {
      await _finish(RecordingState.stopped);
    }
  }

  Future<void> _finish(RecordingState state) async {
    await _sub?.cancel();
    _sub = null;
    await _sink?.flush();
    await _sink?.close();
    _sink = null;
    if (_status.state != RecordingState.error) {
      _emit(_status.copyWith(state: state));
    }
    await _cleanup();
  }

  void _fail(String message) {
    _emit(_status.copyWith(state: RecordingState.error, error: message));
    _sub?.cancel();
    _sub = null;
    _sink?.close();
    _sink = null;
    _cleanup();
  }

  Future<void> _cleanup() async {
    if (_ownsClient) _client.close();
    if (!_done.isCompleted) _done.complete();
    await _statusCtrl.close();
  }
}
