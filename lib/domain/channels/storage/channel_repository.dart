import 'dart:convert';

import 'package:drift/drift.dart';

import '../../providers/provider_config.dart';
import '../../providers/provider_type.dart';
import '../channel.dart';
import 'database.dart' as db;

/// Bridges the drift store and the domain [Channel] model. Owns source
/// (playlist) persistence as [ProviderConfig]s and bulk channel writes; the
/// actual fetching lives in the provider framework (`ProvidersManager`).
class ChannelRepository {
  ChannelRepository(this._db);

  final db.AppDatabase _db;

  // ---- Sources (playlists / provider configs) ---------------------------

  Stream<List<db.Playlist>> watchPlaylists() => _db.watchPlaylists();
  Future<List<db.Playlist>> playlists() => _db.allPlaylists();

  /// All persisted provider configurations.
  Future<List<ProviderConfig>> listProviderConfigs() async =>
      (await _db.allPlaylists()).map(_configFromRow).toList();

  Future<ProviderConfig?> providerConfig(int id) async {
    final db.Playlist? row = await _db.playlistById(id);
    return row == null ? null : _configFromRow(row);
  }

  /// Inserts (when [ProviderConfig.id] is null) or updates a source row.
  /// Returns the source id.
  Future<int> upsertProviderConfig(ProviderConfig config) async {
    final db.PlaylistsCompanion entry = db.PlaylistsCompanion(
      name: Value(config.caption),
      kind: Value(config.type.id),
      location: Value(config.location),
      settingsJson: Value(config.encodeSettings()),
      epgUrl: config.epgUrl == null
          ? const Value.absent()
          : Value(config.epgUrl),
      updatedAt: Value(DateTime.now()),
    );
    if (config.id == null) return _db.createPlaylist(entry);
    await _db.updatePlaylist(config.id!, entry);
    return config.id!;
  }

  Future<void> updateEpgUrl(int id, String url) => _db.setPlaylistEpgUrl(id, url);

  Future<void> deletePlaylist(int id) => _db.deletePlaylist(id);

  // ---- Channels ---------------------------------------------------------

  Stream<List<Channel>> watchChannels(int sourceId) =>
      _db.watchChannels(sourceId).map((rows) => rows.map(_toDomain).toList());

  Future<List<Channel>> channelsOf(int sourceId) async =>
      (await _db.channelsOf(sourceId)).map(_toDomain).toList();

  /// Replaces all channels for [sourceId] in one transaction (fresh import /
  /// refresh). Positions follow list order.
  Future<void> saveChannels(int sourceId, List<Channel> channels) {
    final List<db.ChannelsCompanion> rows = <db.ChannelsCompanion>[
      for (int i = 0; i < channels.length; i++)
        _toCompanion(sourceId, channels[i], i),
    ];
    return _db.replaceChannels(sourceId, rows);
  }

  // ---- mapping ----------------------------------------------------------

  ProviderConfig _configFromRow(db.Playlist r) {
    final ({Map<String, String> settings, Duration updateInterval}) decoded =
        ProviderConfig.decodeSettings(r.settingsJson);
    return ProviderConfig(
      id: r.id,
      type: ProviderTypeId.fromId(r.kind),
      caption: r.name,
      location: r.location,
      settings: decoded.settings,
      updateInterval: decoded.updateInterval,
      epgUrl: r.epgUrl,
    );
  }

  Channel _toDomain(db.Channel r) {
    final Map<String, dynamic> extra =
        (jsonDecode(r.extraJson) as Map).cast<String, dynamic>();
    return Channel(
      id: r.channelId,
      name: r.name,
      url: r.url,
      alternateUrls: _stringList(extra['alternateUrls']),
      group: r.groupTitle,
      logoUrl: r.logoUrl,
      epgId: r.epgId,
      epgAliases: _stringList(extra['epgAliases']),
      isRadio: r.isRadio,
      number: r.number,
      catchup: CatchupInfo(
        type: CatchupType
            .values[r.catchupType.clamp(0, CatchupType.values.length - 1)],
        source: r.catchupSource,
        days: r.catchupDays,
        correctionHours: r.catchupCorrection,
      ),
      headers: _stringMap(extra['headers']),
      props: _stringMap(extra['props']),
    );
  }

  db.ChannelsCompanion _toCompanion(int sourceId, Channel c, int position) {
    final Map<String, dynamic> extra = <String, dynamic>{
      'alternateUrls': c.alternateUrls,
      'epgAliases': c.epgAliases,
      'headers': c.headers,
      'props': c.props,
    };
    return db.ChannelsCompanion.insert(
      sourceId: sourceId,
      channelId: c.id,
      name: c.name,
      url: c.url,
      groupTitle: Value(c.group),
      logoUrl: Value(c.logoUrl),
      epgId: Value(c.epgId),
      isRadio: Value(c.isRadio),
      number: Value(c.number),
      position: Value(position),
      catchupType: Value(c.catchup.type.index),
      catchupSource: Value(c.catchup.source),
      catchupDays: Value(c.catchup.days),
      catchupCorrection: Value(c.catchup.correctionHours),
      extraJson: Value(jsonEncode(extra)),
    );
  }

  List<String> _stringList(dynamic v) =>
      v is List ? v.map((e) => e.toString()).toList() : const <String>[];

  Map<String, String> _stringMap(dynamic v) => v is Map
      ? v.map((k, val) => MapEntry(k.toString(), val.toString()))
      : const <String, String>{};
}
