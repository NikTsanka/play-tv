/// Realistic User-Agent strings expected by IPTV panels and STB middleware.
/// Many Xtream panels reject library defaults, and Stalker portals fingerprint
/// the MAG STB UA, so each provider sends the appropriate one (spec App. A.8/B.6).
abstract final class UserAgents {
  const UserAgents._();

  /// Common IPTV-app / VLC-style UA accepted by most Xtream panels.
  static const String iptv = 'VLC/3.0.20 LibVLC/3.0.20';

  /// MAG250 STB UA — Stalker portals validate this shape.
  static const String magStb =
      'Mozilla/5.0 (QtEmbedded; U; Linux; C) AppleWebKit/533.3 '
      '(KHTML, like Gecko) MAG200 stbapp ver: 2 rev: 250 Safari/533.3';

  /// Secondary STB hint header value for Stalker.
  static const String magXUserAgent = 'Model: MAG250; Link: WiFi';
}
