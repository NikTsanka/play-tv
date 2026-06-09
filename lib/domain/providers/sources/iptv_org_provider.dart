import 'dart:typed_data';

import '../provider.dart';
import '../provider_config.dart';
import '../provider_type.dart';
import 'm3u_provider.dart';

/// The scope of an iptv-org catalog import (drives which public M3U is fetched).
enum IptvOrgScope { all, country, category, language }

extension IptvOrgScopeId on IptvOrgScope {
  String get id => name;

  static IptvOrgScope fromId(String? id) => IptvOrgScope.values.firstWhere(
        (s) => s.name == id,
        orElse: () => IptvOrgScope.all,
      );
}

/// The free iptv-org public catalog (<https://github.com/iptv-org/iptv>),
/// exposed as M3U index files. The whole index or a country/category/language
/// slice is selectable via [ProviderConfig.settings] (spec §4.1). The payload
/// is a plain M3U, so it reuses the shared M3U fetch/parse path.
class IptvOrgProvider extends Provider {
  IptvOrgProvider(this.config);

  static const String base = 'https://iptv-org.github.io/iptv';

  final ProviderConfig config;

  IptvOrgScope get scope => IptvOrgScopeId.fromId(config.setting('scope'));
  String get code => (config.setting('code') ?? '').trim().toLowerCase();

  /// The public M3U url for the configured scope.
  String get playlistUrl {
    switch (scope) {
      case IptvOrgScope.country:
        return '$base/countries/$code.m3u';
      case IptvOrgScope.category:
        return '$base/categories/$code.m3u';
      case IptvOrgScope.language:
        return '$base/languages/$code.m3u';
      case IptvOrgScope.all:
        return '$base/index.m3u';
    }
  }

  @override
  String get caption => config.caption;

  @override
  ProviderType get type => ProviderType.iptvOrg;

  @override
  Set<ProviderFunction> get availableFunctions => const <ProviderFunction>{
        ProviderFunction.live,
        ProviderFunction.logos,
      };

  @override
  Duration get updateInterval => config.updateInterval;

  @override
  Future<void> fetchChannelList(ChannelSink sink, CancelToken ct) async {
    if (scope != IptvOrgScope.all && code.isEmpty) {
      throw Exception('Enter an iptv-org ${scope.name} code');
    }
    final Uint8List bytes = await downloadBytes(playlistUrl);
    ct.throwIfCancelled();
    await parseM3uInto(bytes, sink, ct);
  }
}
