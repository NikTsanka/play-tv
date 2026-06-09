import 'dart:io';

import 'package:http/http.dart' as http;

import 'task_manager.dart';

/// Streams [url] to [file], reporting progress (when Content-Length is known)
/// and honouring cancellation via [controller]. Used by the logo / playlist /
/// EPG / VOD downloaders (spec §11). Inject an [http.Client] for tests.
Future<void> downloadToFile({
  required String url,
  required File file,
  required TaskController controller,
  Map<String, String> headers = const <String, String>{},
  http.Client? client,
}) async {
  final http.Client c = client ?? http.Client();
  try {
    final http.Request req = http.Request('GET', Uri.parse(url))
      ..headers.addAll(headers);
    final http.StreamedResponse resp = await c.send(req);
    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}');
    }

    final int? total = resp.contentLength;
    int received = 0;
    final IOSink sink = file.openWrite();
    try {
      await for (final List<int> chunk in resp.stream) {
        controller.throwIfCancelled();
        sink.add(chunk);
        received += chunk.length;
        controller.report(
            (total != null && total > 0) ? received / total : null);
      }
      await sink.flush();
    } finally {
      await sink.close();
    }
  } finally {
    if (client == null) c.close();
  }
}
