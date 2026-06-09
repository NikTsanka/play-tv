import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../channels/channel.dart';
import '../../local/local_scan.dart';
import '../../local/media_types.dart';
import '../provider.dart';
import '../provider_config.dart';
import '../provider_type.dart';

/// Local & on-device media source (spec §4.5): recursively indexes a folder for
/// video / music / audiobook files and exposes them as channels. The scanned
/// paths are classified on an isolate so large libraries don't jank.
class LocalFolderProvider extends Provider {
  LocalFolderProvider(this.config);

  final ProviderConfig config;

  String get _root => config.location;

  @override
  String get caption => config.caption;

  @override
  ProviderType get type => ProviderType.localFolder;

  @override
  Set<ProviderFunction> get availableFunctions => const <ProviderFunction>{
        ProviderFunction.live,
        ProviderFunction.radio,
        ProviderFunction.vod,
      };

  @override
  Duration get updateInterval => config.updateInterval;

  @override
  Future<void> fetchChannelList(ChannelSink sink, CancelToken ct) async {
    final Directory dir = Directory(_root);
    if (!dir.existsSync()) {
      throw Exception('Folder not found: $_root');
    }

    final List<String> paths = <String>[];
    await for (final FileSystemEntity e in dir.list(recursive: true, followLinks: false)) {
      ct.throwIfCancelled();
      if (e is File && isMediaFile(e.path)) paths.add(e.path);
    }
    ct.throwIfCancelled();

    final List<Channel> channels =
        await compute(buildLocalChannels, (root: _root, paths: paths));
    sink.addAll(channels);
  }
}
