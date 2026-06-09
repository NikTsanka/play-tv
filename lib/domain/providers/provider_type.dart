import 'provider.dart';
import 'provider_config.dart';
import 'sources/generic_url_provider.dart';
import 'sources/iptv_org_provider.dart';
import 'sources/m3u_provider.dart';
import 'sources/ott/ott_base_provider.dart';
import 'sources/ott/ott_service.dart';
import 'sources/stalker/stalker_provider.dart';
import 'sources/xtream/xtream_provider.dart';

/// The channel-source kinds wired in this build. Each maps to a concrete
/// [Provider] via the [ProviderRegistry]; later milestones add local files,
/// YouTube, … (spec §4). `ott` is a family — the branded service is chosen in
/// `ProviderConfig.settings['service']` (spec §4.4 / Appendix C).
enum ProviderType { m3uUrl, m3uFile, genericUrl, iptvOrg, xtream, stalker, ott }

extension ProviderTypeId on ProviderType {
  /// Stable id persisted in `Playlists.kind`.
  String get id => name;

  /// Whether the location input is a local file path rather than a URL.
  bool get isFile => this == ProviderType.m3uFile;

  static ProviderType fromId(String id) => ProviderType.values.firstWhere(
        (t) => t.name == id,
        // Legacy Milestone-3 rows stored 'm3u_url' / 'm3u_file'.
        orElse: () => id == 'm3u_file' ? ProviderType.m3uFile : ProviderType.m3uUrl,
      );
}

/// Static description of a provider type: its capabilities and how to build a
/// runtime [Provider] from a persisted [ProviderConfig].
class ProviderTypeDescriptor {
  const ProviderTypeDescriptor({
    required this.type,
    required this.functions,
    required this.create,
  });

  final ProviderType type;
  final Set<ProviderFunction> functions;
  final Provider Function(ProviderConfig config) create;
}

/// The provider-type registry (spec §4). The single source of truth for which
/// sources exist; the setup UI iterates [all] and the manager calls [build].
class ProviderRegistry {
  ProviderRegistry() : _byType = _build();

  final Map<ProviderType, ProviderTypeDescriptor> _byType;

  Iterable<ProviderTypeDescriptor> get all => _byType.values;

  ProviderTypeDescriptor descriptor(ProviderType type) => _byType[type]!;

  Provider build(ProviderConfig config) => _byType[config.type]!.create(config);

  static Map<ProviderType, ProviderTypeDescriptor> _build() {
    const Set<ProviderFunction> m3uFunctions = <ProviderFunction>{
      ProviderFunction.live,
      ProviderFunction.radio,
      ProviderFunction.epg,
      ProviderFunction.catchup,
      ProviderFunction.logos,
    };
    final List<ProviderTypeDescriptor> descriptors = <ProviderTypeDescriptor>[
      const ProviderTypeDescriptor(
        type: ProviderType.m3uUrl,
        functions: m3uFunctions,
        create: M3uProvider.new,
      ),
      const ProviderTypeDescriptor(
        type: ProviderType.m3uFile,
        functions: m3uFunctions,
        create: M3uProvider.new,
      ),
      const ProviderTypeDescriptor(
        type: ProviderType.genericUrl,
        functions: <ProviderFunction>{ProviderFunction.live},
        create: GenericUrlProvider.new,
      ),
      const ProviderTypeDescriptor(
        type: ProviderType.iptvOrg,
        functions: <ProviderFunction>{
          ProviderFunction.live,
          ProviderFunction.logos,
        },
        create: IptvOrgProvider.new,
      ),
      const ProviderTypeDescriptor(
        type: ProviderType.xtream,
        functions: <ProviderFunction>{
          ProviderFunction.live,
          ProviderFunction.vod,
          ProviderFunction.epg,
          ProviderFunction.catchup,
          ProviderFunction.logos,
        },
        create: XtreamProvider.new,
      ),
      const ProviderTypeDescriptor(
        type: ProviderType.stalker,
        functions: <ProviderFunction>{
          ProviderFunction.live,
          ProviderFunction.vod,
          ProviderFunction.epg,
          ProviderFunction.logos,
        },
        create: StalkerProvider.new,
      ),
      // Non-const: resolves the branded service from the config at build time.
      ProviderTypeDescriptor(
        type: ProviderType.ott,
        functions: const <ProviderFunction>{
          ProviderFunction.live,
          ProviderFunction.epg,
          ProviderFunction.catchup,
          ProviderFunction.logos,
        },
        create: (ProviderConfig c) =>
            OttBaseProvider(ottServiceById(c.setting('service')), c),
      ),
    ];
    return <ProviderType, ProviderTypeDescriptor>{
      for (final ProviderTypeDescriptor d in descriptors) d.type: d,
    };
  }
}
