import '../../channels/channel.dart';
import '../provider.dart';
import '../provider_config.dart';
import '../provider_type.dart';

/// A single stream URL exposed as one channel (spec §4.1 "Generic URL"). Handy
/// for ad-hoc HLS/RTSP/UDP links without a playlist.
class GenericUrlProvider extends Provider {
  GenericUrlProvider(this.config);

  final ProviderConfig config;

  /// Whether the single stream is audio-only (radio).
  bool get _isRadio => config.setting('isRadio') == 'true';

  @override
  String get caption => config.caption;

  @override
  ProviderType get type => ProviderType.genericUrl;

  @override
  Set<ProviderFunction> get availableFunctions => <ProviderFunction>{
        _isRadio ? ProviderFunction.radio : ProviderFunction.live,
      };

  @override
  Duration get updateInterval => config.updateInterval;

  @override
  LogoSource get logoSource => LogoSource.none;

  @override
  Future<void> fetchChannelList(ChannelSink sink, CancelToken ct) async {
    final String url = config.location.trim();
    if (url.isEmpty) throw Exception('No stream URL');
    ct.throwIfCancelled();
    sink.add(Channel(
      id: 'generic:${url.hashCode}',
      name: config.caption.isEmpty ? url : config.caption,
      url: url,
      isRadio: _isRadio,
      number: 1,
    ));
  }
}
