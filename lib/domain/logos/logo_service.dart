import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import '../../core/logging/app_logger.dart';
import '../../core/storage/app_paths.dart';
import '../channels/channel.dart';
import '../channels/channels_providers.dart';
import '../tasks/download.dart';
import '../tasks/task_manager.dart';
import 'logo_matcher.dart';

/// Downloads and caches channel logos, with fuzzy name matching for channels
/// that don't carry a logo URL (spec §5/§11). Files live under
/// `AppPaths.logos/<normalized-name>.<ext>`.
class LogoService {
  LogoService(this._tasks, {http.Client? client, LogoMatcher? matcher})
      : _client = client,
        _matcher = matcher ?? const LogoMatcher();

  final TaskManager _tasks;
  final http.Client? _client;
  final LogoMatcher _matcher;

  Directory get _dir => AppPaths.instance.logos;

  /// Stable cache key for a channel name (normalized, underscores for spaces).
  static String keyFor(String name) =>
      LogoMatcher.normalize(name).replaceAll(' ', '_');

  static String _extFor(String url) {
    final String ext = p.extension(Uri.parse(url).path).toLowerCase();
    return (ext == '.png' || ext == '.jpg' || ext == '.jpeg' || ext == '.webp')
        ? ext
        : '.png';
  }

  /// Downloads logos for [channels] that have a URL and aren't cached yet.
  /// Runs as a cancellable TaskManager task with progress; returns its handle.
  TaskHandle<int> downloadFor(List<Channel> channels) {
    final List<Channel> withLogos = channels
        .where((Channel c) => c.logoUrl != null && c.logoUrl!.isNotEmpty)
        .toList();
    return _tasks.run<int>(
      label: 'Downloading ${withLogos.length} logos',
      action: (TaskController ctrl) async {
        if (!await _dir.exists()) await _dir.create(recursive: true);
        int done = 0;
        for (int i = 0; i < withLogos.length; i++) {
          ctrl.throwIfCancelled();
          final Channel c = withLogos[i];
          final File target =
              File(p.join(_dir.path, '${keyFor(c.name)}${_extFor(c.logoUrl!)}'));
          ctrl.report(withLogos.isEmpty ? null : i / withLogos.length, c.name);
          if (await target.exists()) continue;
          try {
            await downloadToFile(
              url: c.logoUrl!,
              file: target,
              controller: ctrl,
              headers: c.headers,
              client: _client,
            );
            done++;
          } on TaskCancelled {
            rethrow;
          } catch (e) {
            log.w('Logo download failed for ${c.name}: $e');
          }
        }
        return done;
      },
    );
  }

  /// Maps cached logo keys → themselves, for fuzzy matching.
  Future<Map<String, String>> _cachedKeys() async {
    if (!await _dir.exists()) return <String, String>{};
    final Map<String, String> keys = <String, String>{};
    await for (final FileSystemEntity e in _dir.list()) {
      if (e is File) {
        final String key = p.basenameWithoutExtension(e.path);
        keys[key] = key.replaceAll('_', ' ');
      }
    }
    return keys;
  }

  /// Local logo path for a channel: the exact cache file if present, else the
  /// best fuzzy match among cached logos, else null.
  Future<String?> resolve(Channel channel) async {
    final Map<String, String> keys = await _cachedKeys();
    final String exact = keyFor(channel.name);
    if (keys.containsKey(exact)) {
      return _findFile(exact);
    }
    final String? match = _matcher.bestMatch(channel.name, keys);
    return match == null ? null : _findFile(match);
  }

  Future<String?> _findFile(String key) async {
    await for (final FileSystemEntity e in _dir.list()) {
      if (e is File && p.basenameWithoutExtension(e.path) == key) {
        return e.path;
      }
    }
    return null;
  }
}

final logoServiceProvider = Provider<LogoService>((ref) {
  return LogoService(ref.watch(taskManagerProvider));
});

/// Convenience action: download logos for the currently-loaded channels.
final downloadCurrentLogosProvider = Provider<void Function()>((ref) {
  return () {
    final List<Channel> channels = ref.read(flatChannelsProvider);
    ref.read(logoServiceProvider).downloadFor(channels).result.ignore();
  };
});
