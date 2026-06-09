import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

import '../../../core/storage/app_paths.dart';

part 'database.g.dart';

/// A playlist / channel source (Milestone 3 = M3U URL or file). The full
/// provider framework (spec §4) extends this concept in Milestone 5.
class Playlists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

  /// `m3u_url` | `m3u_file`.
  TextColumn get kind => text().withDefault(const Constant('m3u_url'))();
  TextColumn get location => text()();

  /// EPG guide URL discovered in the playlist header (`url-tvg`).
  TextColumn get epgUrl => text().nullable()();

  /// Provider-type-specific settings + update interval (JSON). See
  /// `ProviderConfig.encodeSettings` (Milestone 5).
  TextColumn get settingsJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

class Channels extends Table {
  IntColumn get rowId => integer().autoIncrement()();
  IntColumn get sourceId =>
      integer().references(Playlists, #id, onDelete: KeyAction.cascade)();

  TextColumn get channelId => text()();
  TextColumn get name => text()();
  TextColumn get url => text()();
  TextColumn get groupTitle => text().nullable()();
  TextColumn get logoUrl => text().nullable()();
  TextColumn get epgId => text().nullable()();
  BoolColumn get isRadio => boolean().withDefault(const Constant(false))();
  IntColumn get number => integer().nullable()();
  IntColumn get position => integer().withDefault(const Constant(0))();

  IntColumn get catchupType => integer().withDefault(const Constant(0))();
  TextColumn get catchupSource => text().nullable()();
  IntColumn get catchupDays => integer().withDefault(const Constant(0))();
  IntColumn get catchupCorrection => integer().withDefault(const Constant(0))();

  /// JSON blob: { alternateUrls, epgAliases, headers, props }.
  TextColumn get extraJson => text().withDefault(const Constant('{}'))();
}

/// EPG channel declarations (`<channel>` from XMLTV). Stored globally and
/// matched to [Channels] by id / normalized name (spec §5).
class EpgChannels extends Table {
  TextColumn get id => text()();
  TextColumn get displayName => text()();
  TextColumn get icon => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// EPG events (`<programme>`), times stored as unix seconds (UTC).
@TableIndex(name: 'idx_prog_chan_start', columns: <Symbol>{#channelId, #startUtc})
class EpgProgrammes extends Table {
  IntColumn get rowId => integer().autoIncrement()();
  TextColumn get channelId => text()();
  IntColumn get startUtc => integer()();
  IntColumn get stopUtc => integer()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get category => text().nullable()();
}

/// Cached VOD catalog (the offline cache of spec §7). Movies + series entries
/// per source; episodes are fetched live on demand. `kind` = `movie`|`series`.
@TableIndex(name: 'idx_vod_source_kind', columns: <Symbol>{#sourceId, #kind})
class VodEntries extends Table {
  IntColumn get rowId => integer().autoIncrement()();
  IntColumn get sourceId =>
      integer().references(Playlists, #id, onDelete: KeyAction.cascade)();
  TextColumn get entryId => text()();
  TextColumn get kind => text()();
  TextColumn get title => text()();
  TextColumn get cover => text().nullable()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get categoryName => text().nullable()();
  TextColumn get plot => text().nullable()();
  TextColumn get rating => text().nullable()();
  TextColumn get year => text().nullable()();
  TextColumn get url => text().nullable()();
  IntColumn get position => integer().withDefault(const Constant(0))();
}

/// Scheduled tasks (spec §10): record / reminder / channel-switch / sleep,
/// one-shot or recurring. Times stored as unix millis (UTC).
class ScheduledTasks extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// `record` | `reminder` | `zap` | `sleepTimer`.
  TextColumn get kind => text()();
  IntColumn get fireAtUtc => integer()();
  IntColumn get endAtUtc => integer().nullable()();

  /// `once` | `daily` | `weekly`.
  TextColumn get recurrence => text().withDefault(const Constant('once'))();
  IntColumn get sourceId => integer().nullable()();
  TextColumn get channelId => text().nullable()();
  TextColumn get channelName => text().nullable()();
  TextColumn get channelUrl => text().nullable()();
  TextColumn get title => text().nullable()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
}

/// Favorites (spec §5/§7). Generic over channels and VOD; [refId] is a
/// composite (`source:kind:id`) so it's unique across sources.
class Favorites extends Table {
  TextColumn get refId => text()();

  /// `channel` | `vodMovie` | `vodSeries`.
  TextColumn get kind => text()();
  IntColumn get sourceId => integer().nullable()();
  TextColumn get title => text()();
  TextColumn get subtitle => text().nullable()();
  TextColumn get imageUrl => text().nullable()();

  /// Playable URL for movies; null for series / dynamic channels.
  TextColumn get playUrl => text().nullable()();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{refId};
}

@DriftDatabase(tables: <Type>[
  Playlists,
  Channels,
  EpgChannels,
  EpgProgrammes,
  VodEntries,
  ScheduledTasks,
  Favorites,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());

  /// For unit tests: pass `NativeDatabase.memory()`.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(epgChannels);
            await m.createTable(epgProgrammes);
          }
          if (from < 3) {
            await m.addColumn(playlists, playlists.settingsJson);
          }
          if (from < 4) {
            await m.createTable(vodEntries);
            await m.createTable(favorites);
          }
          if (from < 5) {
            await m.createTable(scheduledTasks);
          }
        },
      );

  // ---- Playlists --------------------------------------------------------

  Future<List<Playlist>> allPlaylists() => select(playlists).get();
  Stream<List<Playlist>> watchPlaylists() => select(playlists).watch();

  Future<Playlist?> playlistById(int id) =>
      (select(playlists)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Inserts a new source row, returning its id.
  Future<int> createPlaylist(PlaylistsCompanion entry) =>
      into(playlists).insert(entry);

  /// Updates an existing source row in place (does NOT touch its channels —
  /// unlike insert-or-replace, which would cascade-delete them).
  Future<void> updatePlaylist(int id, PlaylistsCompanion entry) =>
      (update(playlists)..where((t) => t.id.equals(id))).write(entry);

  Future<void> setPlaylistEpgUrl(int id, String url) =>
      (update(playlists)..where((t) => t.id.equals(id)))
          .write(PlaylistsCompanion(epgUrl: Value(url)));

  Future<void> deletePlaylist(int id) =>
      (delete(playlists)..where((t) => t.id.equals(id))).go();

  // ---- Channels ---------------------------------------------------------

  Stream<List<Channel>> watchChannels(int sourceId) =>
      (select(channels)
            ..where((t) => t.sourceId.equals(sourceId))
            ..orderBy([(t) => OrderingTerm(expression: t.position)]))
          .watch();

  Future<List<Channel>> channelsOf(int sourceId) =>
      (select(channels)
            ..where((t) => t.sourceId.equals(sourceId))
            ..orderBy([(t) => OrderingTerm(expression: t.position)]))
          .get();

  /// Replaces all channels for a source in one transaction (re-import).
  Future<void> replaceChannels(
      int sourceId, List<ChannelsCompanion> rows) async {
    await transaction(() async {
      await (delete(channels)..where((t) => t.sourceId.equals(sourceId))).go();
      await batch((b) => b.insertAll(channels, rows));
    });
  }

  // ---- EPG --------------------------------------------------------------

  Future<int> epgProgrammeCount() async {
    final c = countAll();
    final q = selectOnly(epgProgrammes)..addColumns(<Expression>[c]);
    return (await q.getSingle()).read(c) ?? 0;
  }

  Stream<int> watchEpgProgrammeCount() {
    final c = countAll();
    final q = selectOnly(epgProgrammes)..addColumns(<Expression>[c]);
    return q.watchSingle().map((row) => row.read(c) ?? 0);
  }

  Future<List<EpgChannel>> allEpgChannels() => select(epgChannels).get();

  /// Replaces the whole EPG store (single global guide) in one transaction.
  Future<void> replaceEpg(
    List<EpgChannelsCompanion> chans,
    List<EpgProgrammesCompanion> progs,
  ) async {
    await transaction(() async {
      await delete(epgProgrammes).go();
      await delete(epgChannels).go();
      await batch((b) {
        b.insertAll(epgChannels, chans, mode: InsertMode.insertOrReplace);
        b.insertAll(epgProgrammes, progs);
      });
    });
  }

  /// Programme live at [nowUnix] for [channelId], if any.
  Future<EpgProgramme?> programmeAt(String channelId, int nowUnix) {
    return (select(epgProgrammes)
          ..where((t) =>
              t.channelId.equals(channelId) &
              t.startUtc.isSmallerOrEqualValue(nowUnix) &
              t.stopUtc.isBiggerThanValue(nowUnix))
          ..limit(1))
        .getSingleOrNull();
  }

  /// First programme starting after [afterUnix] for [channelId].
  Future<EpgProgramme?> programmeAfter(String channelId, int afterUnix) {
    return (select(epgProgrammes)
          ..where((t) =>
              t.channelId.equals(channelId) &
              t.startUtc.isBiggerThanValue(afterUnix))
          ..orderBy([(t) => OrderingTerm(expression: t.startUtc)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// All programmes for [channelIds] overlapping the window [startUnix, endUnix).
  Future<List<EpgProgramme>> programmesInWindow(
      List<String> channelIds, int startUnix, int endUnix) {
    if (channelIds.isEmpty) return Future.value(const <EpgProgramme>[]);
    return (select(epgProgrammes)
          ..where((t) =>
              t.channelId.isIn(channelIds) &
              t.stopUtc.isBiggerThanValue(startUnix) &
              t.startUtc.isSmallerThanValue(endUnix))
          ..orderBy([(t) => OrderingTerm(expression: t.startUtc)]))
        .get();
  }

  // ---- VOD cache --------------------------------------------------------

  /// Replaces the cached entries for a source + kind in one transaction.
  Future<void> replaceVodEntries(
      int sourceId, String kind, List<VodEntriesCompanion> rows) async {
    await transaction(() async {
      await (delete(vodEntries)
            ..where((t) => t.sourceId.equals(sourceId) & t.kind.equals(kind)))
          .go();
      await batch((b) => b.insertAll(vodEntries, rows));
    });
  }

  /// Watches cached VOD entries, filtered by category and a title search.
  Stream<List<VodEntry>> watchVodEntries(
    int sourceId,
    String kind, {
    String? categoryId,
    String? search,
  }) {
    final SimpleSelectStatement<$VodEntriesTable, VodEntry> q =
        select(vodEntries)
          ..where((t) => t.sourceId.equals(sourceId) & t.kind.equals(kind));
    if (categoryId != null) {
      q.where((t) => t.categoryId.equals(categoryId));
    }
    if (search != null && search.isNotEmpty) {
      q.where((t) => t.title.like('%$search%'));
    }
    q.orderBy([(t) => OrderingTerm(expression: t.position)]);
    return q.watch();
  }

  Future<int> vodEntryCount(int sourceId, String kind) async {
    final Expression<int> c = countAll();
    final q = selectOnly(vodEntries)
      ..addColumns(<Expression>[c])
      ..where(vodEntries.sourceId.equals(sourceId) & vodEntries.kind.equals(kind));
    return (await q.getSingle()).read(c) ?? 0;
  }

  /// Distinct (id, name) categories present in the cache for a source + kind.
  Future<List<({String id, String name})>> vodCategoriesOf(
      int sourceId, String kind) async {
    final q = selectOnly(vodEntries, distinct: true)
      ..addColumns(<Expression>[vodEntries.categoryId, vodEntries.categoryName])
      ..where(
          vodEntries.sourceId.equals(sourceId) & vodEntries.kind.equals(kind));
    final List<TypedResult> rows = await q.get();
    return <({String id, String name})>[
      for (final TypedResult r in rows)
        if ((r.read(vodEntries.categoryId) ?? '').isNotEmpty)
          (
            id: r.read(vodEntries.categoryId)!,
            name: r.read(vodEntries.categoryName) ??
                r.read(vodEntries.categoryId)!,
          ),
    ];
  }

  // ---- Favorites --------------------------------------------------------

  Stream<List<Favorite>> watchFavorites([String? kind]) {
    final SimpleSelectStatement<$FavoritesTable, Favorite> q = select(favorites)
      ..orderBy([(t) => OrderingTerm.desc(t.addedAt)]);
    if (kind != null) q.where((t) => t.kind.equals(kind));
    return q.watch();
  }

  Future<bool> isFavorite(String refId) async {
    final Favorite? row = await (select(favorites)
          ..where((t) => t.refId.equals(refId)))
        .getSingleOrNull();
    return row != null;
  }

  Future<void> addFavorite(FavoritesCompanion entry) =>
      into(favorites).insert(entry, mode: InsertMode.insertOrReplace);

  Future<void> removeFavorite(String refId) =>
      (delete(favorites)..where((t) => t.refId.equals(refId))).go();

  // ---- Scheduled tasks --------------------------------------------------

  Stream<List<ScheduledTask>> watchScheduledTasks() =>
      (select(scheduledTasks)
            ..orderBy([(t) => OrderingTerm(expression: t.fireAtUtc)]))
          .watch();

  Future<List<ScheduledTask>> allScheduledTasks() =>
      (select(scheduledTasks)
            ..orderBy([(t) => OrderingTerm(expression: t.fireAtUtc)]))
          .get();

  /// Enabled tasks whose fire time has passed [nowUtcMillis].
  Future<List<ScheduledTask>> dueScheduledTasks(int nowUtcMillis) =>
      (select(scheduledTasks)
            ..where((t) =>
                t.enabled.equals(true) &
                t.fireAtUtc.isSmallerOrEqualValue(nowUtcMillis))
            ..orderBy([(t) => OrderingTerm(expression: t.fireAtUtc)]))
          .get();

  Future<int> insertScheduledTask(ScheduledTasksCompanion entry) =>
      into(scheduledTasks).insert(entry);

  Future<void> updateScheduledTask(int id, ScheduledTasksCompanion entry) =>
      (update(scheduledTasks)..where((t) => t.id.equals(id))).write(entry);

  Future<void> deleteScheduledTask(int id) =>
      (delete(scheduledTasks)..where((t) => t.id.equals(id))).go();
}

LazyDatabase _open() {
  return LazyDatabase(() async {
    final file = File(p.join(AppPaths.instance.db.path, 'streamhub.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
