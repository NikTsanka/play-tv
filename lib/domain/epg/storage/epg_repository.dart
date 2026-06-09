import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/logging/app_logger.dart';
import '../../channels/storage/database.dart' as db;
import '../epg_models.dart';
import '../import/xmltv_parser.dart';

/// Imports XMLTV guides and answers now/next + grid-window queries.
class EpgRepository {
  EpgRepository(this._db);

  final db.AppDatabase _db;

  Future<int> programmeCount() => _db.epgProgrammeCount();
  Stream<int> watchProgrammeCount() => _db.watchEpgProgrammeCount();

  Future<List<EpgChannel>> epgChannels() async {
    final rows = await _db.allEpgChannels();
    return rows
        .map((r) => EpgChannel(
              id: r.id,
              displayNames: <String>[r.displayName],
              icon: r.icon,
            ))
        .toList();
  }

  /// Imports an XMLTV guide from a URL (handles gzip).
  Future<int> importFromUrl(String url) async {
    log.i('Importing EPG from URL: $url');
    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode != 200) {
      throw Exception('EPG download failed (${resp.statusCode})');
    }
    return importFromBytes(resp.bodyBytes);
  }

  /// Imports an XMLTV guide from raw bytes. Returns the programme count.
  Future<int> importFromBytes(Uint8List bytes) async {
    final Uint8List raw = _maybeGunzip(bytes);
    final String content = utf8.decode(raw, allowMalformed: true);
    final EpgImportResult result = await compute(parseXmltv, content);

    final chans = result.channels
        .map((e) => db.EpgChannelsCompanion.insert(
              id: e.id,
              displayName: e.primaryName,
              icon: Value(e.icon),
            ))
        .toList();
    final progs = result.programmes
        .map((p) => db.EpgProgrammesCompanion.insert(
              channelId: p.channelId,
              startUtc: _unix(p.start),
              stopUtc: _unix(p.stop),
              title: p.title,
              description: Value(p.description),
              category: Value(p.category),
            ))
        .toList();

    await _db.replaceEpg(chans, progs);
    log.i('Imported ${chans.length} EPG channels, ${progs.length} programmes');
    return progs.length;
  }

  Future<NowNext> nowNext(String epgChannelId, {DateTime? at}) async {
    final int now = _unix(at ?? DateTime.now());
    final results = await Future.wait(<Future<db.EpgProgramme?>>[
      _db.programmeAt(epgChannelId, now),
      _db.programmeAfter(epgChannelId, now),
    ]);
    return NowNext(now: _toDomain(results[0]), next: _toDomain(results[1]));
  }

  Future<List<EpgProgramme>> programmesInWindow(
      List<String> channelIds, DateTime start, DateTime end) async {
    final rows =
        await _db.programmesInWindow(channelIds, _unix(start), _unix(end));
    return rows.map(_toDomain).whereType<EpgProgramme>().toList();
  }

  // ---- helpers ----------------------------------------------------------

  EpgProgramme? _toDomain(db.EpgProgramme? r) {
    if (r == null) return null;
    return EpgProgramme(
      channelId: r.channelId,
      start: DateTime.fromMillisecondsSinceEpoch(r.startUtc * 1000, isUtc: true),
      stop: DateTime.fromMillisecondsSinceEpoch(r.stopUtc * 1000, isUtc: true),
      title: r.title,
      description: r.description,
      category: r.category,
    );
  }

  Uint8List _maybeGunzip(Uint8List bytes) {
    if (bytes.length >= 2 && bytes[0] == 0x1f && bytes[1] == 0x8b) {
      return Uint8List.fromList(gzip.decode(bytes));
    }
    return bytes;
  }

  int _unix(DateTime dt) => dt.toUtc().millisecondsSinceEpoch ~/ 1000;
}
