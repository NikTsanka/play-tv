import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../logging/app_logger.dart';

/// Resolves and creates the per-user app-data folders StreamHub writes to.
///
/// Layout under the platform application-support directory:
///   StreamHub/
///     config/      JSON config (providers, settings)   [later milestones]
///     db/          SQLite stores (channels, EPG, VOD)   [later milestones]
///     logos/       downloaded channel/VOD logos         [later milestones]
///     recordings/  recorded streams                     [later milestones]
///     cache/       transient data, EPG temp             [later milestones]
///     logs/        rolling log files
class AppPaths {
  AppPaths._(this.root);

  final Directory root;

  Directory get config => _sub('config');
  Directory get db => _sub('db');
  Directory get logos => _sub('logos');
  Directory get recordings => _sub('recordings');
  Directory get cache => _sub('cache');
  Directory get logs => _sub('logs');

  static AppPaths? _instance;
  static AppPaths get instance {
    final AppPaths? i = _instance;
    if (i == null) {
      throw StateError('AppPaths.init() must be awaited before use.');
    }
    return i;
  }

  /// Must be called once during bootstrap (before [instance] is read).
  static Future<AppPaths> init() async {
    final Directory support = await getApplicationSupportDirectory();
    final Directory root =
        Directory('${support.path}${Platform.pathSeparator}StreamHub');
    final AppPaths paths = AppPaths._(root);
    for (final Directory d in <Directory>[
      root,
      paths.config,
      paths.db,
      paths.logos,
      paths.recordings,
      paths.cache,
      paths.logs,
    ]) {
      if (!await d.exists()) {
        await d.create(recursive: true);
      }
    }
    log.i('App-data root: ${root.path}');
    _instance = paths;
    return paths;
  }

  Directory _sub(String name) =>
      Directory('${root.path}${Platform.pathSeparator}$name');
}
