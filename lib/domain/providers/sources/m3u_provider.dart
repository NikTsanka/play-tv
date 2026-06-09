import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../channels/import/m3u_parser.dart';
import '../provider.dart';
import '../provider_config.dart';
import '../provider_type.dart';

/// Downloads raw bytes from [url], throwing on a non-200 response. Shared by
/// every M3U-backed provider (M3U-URL, iptv-org).
Future<Uint8List> downloadBytes(String url) async {
  final http.Response resp = await http.get(Uri.parse(url));
  if (resp.statusCode != 200) {
    throw Exception('Download failed (${resp.statusCode})');
  }
  return resp.bodyBytes;
}

/// Decodes [bytes] (auto codepage), parses the M3U off the UI isolate, and
/// pushes the channels + discovered EPG url into [sink]. Reused by any provider
/// whose payload is an M3U playlist.
Future<void> parseM3uInto(
    Uint8List bytes, ChannelSink sink, CancelToken ct) async {
  final String content = decodeM3uBytes(bytes);
  ct.throwIfCancelled();
  final M3uParseResult result = await compute(parseM3u, content);
  ct.throwIfCancelled();
  sink.addAll(result.channels);
  sink.epgUrl = result.epgUrl;
}

/// Generic M3U/M3U8 source — from a URL ([ProviderType.m3uUrl]) or a local file
/// path ([ProviderType.m3uFile]). Parsing runs on an isolate (spec §4.1, §12).
class M3uProvider extends Provider {
  M3uProvider(this.config);

  final ProviderConfig config;

  @override
  String get caption => config.caption;

  @override
  ProviderType get type => config.type;

  @override
  Set<ProviderFunction> get availableFunctions => const <ProviderFunction>{
        ProviderFunction.live,
        ProviderFunction.radio,
        ProviderFunction.epg,
        ProviderFunction.catchup,
        ProviderFunction.logos,
      };

  @override
  Duration get updateInterval => config.updateInterval;

  @override
  Future<void> fetchChannelList(ChannelSink sink, CancelToken ct) async {
    final Uint8List bytes = await _load();
    ct.throwIfCancelled();
    await parseM3uInto(bytes, sink, ct);
  }

  Future<Uint8List> _load() async {
    if (config.type == ProviderType.m3uFile) {
      final File file = File(config.location);
      if (!file.existsSync()) {
        throw Exception('File not found: ${config.location}');
      }
      return file.readAsBytes();
    }
    return downloadBytes(config.location);
  }
}
