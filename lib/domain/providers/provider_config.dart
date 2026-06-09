import 'dart:convert';

import 'provider_type.dart';

/// Persisted configuration of one provider instance. Maps 1:1 to a `Playlists`
/// drift row: [caption] → name, [type] → kind, [location] → location, and the
/// type-specific [settings] + [updateInterval] are serialized into the row's
/// `settingsJson`. New provider types (Xtream/Stalker) store their credentials
/// and options in [settings] without further schema changes.
class ProviderConfig {
  ProviderConfig({
    this.id,
    required this.type,
    required this.caption,
    this.location = '',
    Map<String, String>? settings,
    this.updateInterval = const Duration(hours: 6),
    this.epgUrl,
  }) : settings = settings ?? <String, String>{};

  /// `Playlists.id` once persisted; `null` before the first save.
  final int? id;
  final ProviderType type;
  final String caption;

  /// Primary location — playlist URL, file path or stream URL depending on type.
  final String location;

  /// Type-specific options (e.g. iptv-org scope/code, generic `isRadio`).
  final Map<String, String> settings;
  final Duration updateInterval;
  final String? epgUrl;

  String? setting(String key) => settings[key];

  ProviderConfig copyWith({
    int? id,
    ProviderType? type,
    String? caption,
    String? location,
    Map<String, String>? settings,
    Duration? updateInterval,
    String? epgUrl,
  }) =>
      ProviderConfig(
        id: id ?? this.id,
        type: type ?? this.type,
        caption: caption ?? this.caption,
        location: location ?? this.location,
        settings: settings ?? this.settings,
        updateInterval: updateInterval ?? this.updateInterval,
        epgUrl: epgUrl ?? this.epgUrl,
      );

  /// Serializes [settings] + [updateInterval] for the `settingsJson` column.
  String encodeSettings() => jsonEncode(<String, dynamic>{
        'settings': settings,
        'updateMinutes': updateInterval.inMinutes,
      });

  /// Inverse of [encodeSettings]; tolerant of empty / legacy `{}` blobs.
  static ({Map<String, String> settings, Duration updateInterval})
      decodeSettings(String json) {
    Map<String, String> settings = <String, String>{};
    Duration interval = const Duration(hours: 6);
    try {
      final decoded = jsonDecode(json);
      if (decoded is Map) {
        final raw = decoded['settings'];
        if (raw is Map) {
          settings = raw.map((k, v) => MapEntry(k.toString(), v.toString()));
        }
        final mins = decoded['updateMinutes'];
        if (mins is num && mins > 0) interval = Duration(minutes: mins.toInt());
      }
    } catch (_) {
      // Leave defaults on malformed JSON.
    }
    return (settings: settings, updateInterval: interval);
  }
}
