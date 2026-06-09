// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PlaylistsTable extends Playlists
    with TableInfo<$PlaylistsTable, Playlist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('m3u_url'));
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _epgUrlMeta = const VerificationMeta('epgUrl');
  @override
  late final GeneratedColumn<String> epgUrl = GeneratedColumn<String>(
      'epg_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _settingsJsonMeta =
      const VerificationMeta('settingsJson');
  @override
  late final GeneratedColumn<String> settingsJson = GeneratedColumn<String>(
      'settings_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _addedAtMeta =
      const VerificationMeta('addedAt');
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
      'added_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, kind, location, epgUrl, settingsJson, addedAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlists';
  @override
  VerificationContext validateIntegrity(Insertable<Playlist> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('epg_url')) {
      context.handle(_epgUrlMeta,
          epgUrl.isAcceptableOrUnknown(data['epg_url']!, _epgUrlMeta));
    }
    if (data.containsKey('settings_json')) {
      context.handle(
          _settingsJsonMeta,
          settingsJson.isAcceptableOrUnknown(
              data['settings_json']!, _settingsJsonMeta));
    }
    if (data.containsKey('added_at')) {
      context.handle(_addedAtMeta,
          addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Playlist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Playlist(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location'])!,
      epgUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}epg_url']),
      settingsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}settings_json'])!,
      addedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}added_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $PlaylistsTable createAlias(String alias) {
    return $PlaylistsTable(attachedDatabase, alias);
  }
}

class Playlist extends DataClass implements Insertable<Playlist> {
  final int id;
  final String name;

  /// `m3u_url` | `m3u_file`.
  final String kind;
  final String location;

  /// EPG guide URL discovered in the playlist header (`url-tvg`).
  final String? epgUrl;

  /// Provider-type-specific settings + update interval (JSON). See
  /// `ProviderConfig.encodeSettings` (Milestone 5).
  final String settingsJson;
  final DateTime addedAt;
  final DateTime? updatedAt;
  const Playlist(
      {required this.id,
      required this.name,
      required this.kind,
      required this.location,
      this.epgUrl,
      required this.settingsJson,
      required this.addedAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['location'] = Variable<String>(location);
    if (!nullToAbsent || epgUrl != null) {
      map['epg_url'] = Variable<String>(epgUrl);
    }
    map['settings_json'] = Variable<String>(settingsJson);
    map['added_at'] = Variable<DateTime>(addedAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  PlaylistsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistsCompanion(
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      location: Value(location),
      epgUrl:
          epgUrl == null && nullToAbsent ? const Value.absent() : Value(epgUrl),
      settingsJson: Value(settingsJson),
      addedAt: Value(addedAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Playlist.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Playlist(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      location: serializer.fromJson<String>(json['location']),
      epgUrl: serializer.fromJson<String?>(json['epgUrl']),
      settingsJson: serializer.fromJson<String>(json['settingsJson']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'location': serializer.toJson<String>(location),
      'epgUrl': serializer.toJson<String?>(epgUrl),
      'settingsJson': serializer.toJson<String>(settingsJson),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  Playlist copyWith(
          {int? id,
          String? name,
          String? kind,
          String? location,
          Value<String?> epgUrl = const Value.absent(),
          String? settingsJson,
          DateTime? addedAt,
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      Playlist(
        id: id ?? this.id,
        name: name ?? this.name,
        kind: kind ?? this.kind,
        location: location ?? this.location,
        epgUrl: epgUrl.present ? epgUrl.value : this.epgUrl,
        settingsJson: settingsJson ?? this.settingsJson,
        addedAt: addedAt ?? this.addedAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  Playlist copyWithCompanion(PlaylistsCompanion data) {
    return Playlist(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      location: data.location.present ? data.location.value : this.location,
      epgUrl: data.epgUrl.present ? data.epgUrl.value : this.epgUrl,
      settingsJson: data.settingsJson.present
          ? data.settingsJson.value
          : this.settingsJson,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Playlist(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('location: $location, ')
          ..write('epgUrl: $epgUrl, ')
          ..write('settingsJson: $settingsJson, ')
          ..write('addedAt: $addedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, kind, location, epgUrl, settingsJson, addedAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Playlist &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.location == this.location &&
          other.epgUrl == this.epgUrl &&
          other.settingsJson == this.settingsJson &&
          other.addedAt == this.addedAt &&
          other.updatedAt == this.updatedAt);
}

class PlaylistsCompanion extends UpdateCompanion<Playlist> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> kind;
  final Value<String> location;
  final Value<String?> epgUrl;
  final Value<String> settingsJson;
  final Value<DateTime> addedAt;
  final Value<DateTime?> updatedAt;
  const PlaylistsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.location = const Value.absent(),
    this.epgUrl = const Value.absent(),
    this.settingsJson = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PlaylistsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.kind = const Value.absent(),
    required String location,
    this.epgUrl = const Value.absent(),
    this.settingsJson = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : name = Value(name),
        location = Value(location);
  static Insertable<Playlist> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? location,
    Expression<String>? epgUrl,
    Expression<String>? settingsJson,
    Expression<DateTime>? addedAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (location != null) 'location': location,
      if (epgUrl != null) 'epg_url': epgUrl,
      if (settingsJson != null) 'settings_json': settingsJson,
      if (addedAt != null) 'added_at': addedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PlaylistsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? kind,
      Value<String>? location,
      Value<String?>? epgUrl,
      Value<String>? settingsJson,
      Value<DateTime>? addedAt,
      Value<DateTime?>? updatedAt}) {
    return PlaylistsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      location: location ?? this.location,
      epgUrl: epgUrl ?? this.epgUrl,
      settingsJson: settingsJson ?? this.settingsJson,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (epgUrl.present) {
      map['epg_url'] = Variable<String>(epgUrl.value);
    }
    if (settingsJson.present) {
      map['settings_json'] = Variable<String>(settingsJson.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('location: $location, ')
          ..write('epgUrl: $epgUrl, ')
          ..write('settingsJson: $settingsJson, ')
          ..write('addedAt: $addedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ChannelsTable extends Channels with TableInfo<$ChannelsTable, Channel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChannelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  @override
  late final GeneratedColumn<int> rowId = GeneratedColumn<int>(
      'row_id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  @override
  late final GeneratedColumn<int> sourceId = GeneratedColumn<int>(
      'source_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES playlists (id) ON DELETE CASCADE'));
  static const VerificationMeta _channelIdMeta =
      const VerificationMeta('channelId');
  @override
  late final GeneratedColumn<String> channelId = GeneratedColumn<String>(
      'channel_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _groupTitleMeta =
      const VerificationMeta('groupTitle');
  @override
  late final GeneratedColumn<String> groupTitle = GeneratedColumn<String>(
      'group_title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _logoUrlMeta =
      const VerificationMeta('logoUrl');
  @override
  late final GeneratedColumn<String> logoUrl = GeneratedColumn<String>(
      'logo_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _epgIdMeta = const VerificationMeta('epgId');
  @override
  late final GeneratedColumn<String> epgId = GeneratedColumn<String>(
      'epg_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isRadioMeta =
      const VerificationMeta('isRadio');
  @override
  late final GeneratedColumn<bool> isRadio = GeneratedColumn<bool>(
      'is_radio', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_radio" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
      'number', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _catchupTypeMeta =
      const VerificationMeta('catchupType');
  @override
  late final GeneratedColumn<int> catchupType = GeneratedColumn<int>(
      'catchup_type', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _catchupSourceMeta =
      const VerificationMeta('catchupSource');
  @override
  late final GeneratedColumn<String> catchupSource = GeneratedColumn<String>(
      'catchup_source', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _catchupDaysMeta =
      const VerificationMeta('catchupDays');
  @override
  late final GeneratedColumn<int> catchupDays = GeneratedColumn<int>(
      'catchup_days', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _catchupCorrectionMeta =
      const VerificationMeta('catchupCorrection');
  @override
  late final GeneratedColumn<int> catchupCorrection = GeneratedColumn<int>(
      'catchup_correction', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _extraJsonMeta =
      const VerificationMeta('extraJson');
  @override
  late final GeneratedColumn<String> extraJson = GeneratedColumn<String>(
      'extra_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  @override
  List<GeneratedColumn> get $columns => [
        rowId,
        sourceId,
        channelId,
        name,
        url,
        groupTitle,
        logoUrl,
        epgId,
        isRadio,
        number,
        position,
        catchupType,
        catchupSource,
        catchupDays,
        catchupCorrection,
        extraJson
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'channels';
  @override
  VerificationContext validateIntegrity(Insertable<Channel> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('row_id')) {
      context.handle(
          _rowIdMeta, rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta));
    }
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('channel_id')) {
      context.handle(_channelIdMeta,
          channelId.isAcceptableOrUnknown(data['channel_id']!, _channelIdMeta));
    } else if (isInserting) {
      context.missing(_channelIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('group_title')) {
      context.handle(
          _groupTitleMeta,
          groupTitle.isAcceptableOrUnknown(
              data['group_title']!, _groupTitleMeta));
    }
    if (data.containsKey('logo_url')) {
      context.handle(_logoUrlMeta,
          logoUrl.isAcceptableOrUnknown(data['logo_url']!, _logoUrlMeta));
    }
    if (data.containsKey('epg_id')) {
      context.handle(
          _epgIdMeta, epgId.isAcceptableOrUnknown(data['epg_id']!, _epgIdMeta));
    }
    if (data.containsKey('is_radio')) {
      context.handle(_isRadioMeta,
          isRadio.isAcceptableOrUnknown(data['is_radio']!, _isRadioMeta));
    }
    if (data.containsKey('number')) {
      context.handle(_numberMeta,
          number.isAcceptableOrUnknown(data['number']!, _numberMeta));
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    }
    if (data.containsKey('catchup_type')) {
      context.handle(
          _catchupTypeMeta,
          catchupType.isAcceptableOrUnknown(
              data['catchup_type']!, _catchupTypeMeta));
    }
    if (data.containsKey('catchup_source')) {
      context.handle(
          _catchupSourceMeta,
          catchupSource.isAcceptableOrUnknown(
              data['catchup_source']!, _catchupSourceMeta));
    }
    if (data.containsKey('catchup_days')) {
      context.handle(
          _catchupDaysMeta,
          catchupDays.isAcceptableOrUnknown(
              data['catchup_days']!, _catchupDaysMeta));
    }
    if (data.containsKey('catchup_correction')) {
      context.handle(
          _catchupCorrectionMeta,
          catchupCorrection.isAcceptableOrUnknown(
              data['catchup_correction']!, _catchupCorrectionMeta));
    }
    if (data.containsKey('extra_json')) {
      context.handle(_extraJsonMeta,
          extraJson.isAcceptableOrUnknown(data['extra_json']!, _extraJsonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {rowId};
  @override
  Channel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Channel(
      rowId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}row_id'])!,
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}source_id'])!,
      channelId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}channel_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      groupTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_title']),
      logoUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}logo_url']),
      epgId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}epg_id']),
      isRadio: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_radio'])!,
      number: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}number']),
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
      catchupType: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}catchup_type'])!,
      catchupSource: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}catchup_source']),
      catchupDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}catchup_days'])!,
      catchupCorrection: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}catchup_correction'])!,
      extraJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}extra_json'])!,
    );
  }

  @override
  $ChannelsTable createAlias(String alias) {
    return $ChannelsTable(attachedDatabase, alias);
  }
}

class Channel extends DataClass implements Insertable<Channel> {
  final int rowId;
  final int sourceId;
  final String channelId;
  final String name;
  final String url;
  final String? groupTitle;
  final String? logoUrl;
  final String? epgId;
  final bool isRadio;
  final int? number;
  final int position;
  final int catchupType;
  final String? catchupSource;
  final int catchupDays;
  final int catchupCorrection;

  /// JSON blob: { alternateUrls, epgAliases, headers, props }.
  final String extraJson;
  const Channel(
      {required this.rowId,
      required this.sourceId,
      required this.channelId,
      required this.name,
      required this.url,
      this.groupTitle,
      this.logoUrl,
      this.epgId,
      required this.isRadio,
      this.number,
      required this.position,
      required this.catchupType,
      this.catchupSource,
      required this.catchupDays,
      required this.catchupCorrection,
      required this.extraJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['row_id'] = Variable<int>(rowId);
    map['source_id'] = Variable<int>(sourceId);
    map['channel_id'] = Variable<String>(channelId);
    map['name'] = Variable<String>(name);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || groupTitle != null) {
      map['group_title'] = Variable<String>(groupTitle);
    }
    if (!nullToAbsent || logoUrl != null) {
      map['logo_url'] = Variable<String>(logoUrl);
    }
    if (!nullToAbsent || epgId != null) {
      map['epg_id'] = Variable<String>(epgId);
    }
    map['is_radio'] = Variable<bool>(isRadio);
    if (!nullToAbsent || number != null) {
      map['number'] = Variable<int>(number);
    }
    map['position'] = Variable<int>(position);
    map['catchup_type'] = Variable<int>(catchupType);
    if (!nullToAbsent || catchupSource != null) {
      map['catchup_source'] = Variable<String>(catchupSource);
    }
    map['catchup_days'] = Variable<int>(catchupDays);
    map['catchup_correction'] = Variable<int>(catchupCorrection);
    map['extra_json'] = Variable<String>(extraJson);
    return map;
  }

  ChannelsCompanion toCompanion(bool nullToAbsent) {
    return ChannelsCompanion(
      rowId: Value(rowId),
      sourceId: Value(sourceId),
      channelId: Value(channelId),
      name: Value(name),
      url: Value(url),
      groupTitle: groupTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(groupTitle),
      logoUrl: logoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(logoUrl),
      epgId:
          epgId == null && nullToAbsent ? const Value.absent() : Value(epgId),
      isRadio: Value(isRadio),
      number:
          number == null && nullToAbsent ? const Value.absent() : Value(number),
      position: Value(position),
      catchupType: Value(catchupType),
      catchupSource: catchupSource == null && nullToAbsent
          ? const Value.absent()
          : Value(catchupSource),
      catchupDays: Value(catchupDays),
      catchupCorrection: Value(catchupCorrection),
      extraJson: Value(extraJson),
    );
  }

  factory Channel.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Channel(
      rowId: serializer.fromJson<int>(json['rowId']),
      sourceId: serializer.fromJson<int>(json['sourceId']),
      channelId: serializer.fromJson<String>(json['channelId']),
      name: serializer.fromJson<String>(json['name']),
      url: serializer.fromJson<String>(json['url']),
      groupTitle: serializer.fromJson<String?>(json['groupTitle']),
      logoUrl: serializer.fromJson<String?>(json['logoUrl']),
      epgId: serializer.fromJson<String?>(json['epgId']),
      isRadio: serializer.fromJson<bool>(json['isRadio']),
      number: serializer.fromJson<int?>(json['number']),
      position: serializer.fromJson<int>(json['position']),
      catchupType: serializer.fromJson<int>(json['catchupType']),
      catchupSource: serializer.fromJson<String?>(json['catchupSource']),
      catchupDays: serializer.fromJson<int>(json['catchupDays']),
      catchupCorrection: serializer.fromJson<int>(json['catchupCorrection']),
      extraJson: serializer.fromJson<String>(json['extraJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rowId': serializer.toJson<int>(rowId),
      'sourceId': serializer.toJson<int>(sourceId),
      'channelId': serializer.toJson<String>(channelId),
      'name': serializer.toJson<String>(name),
      'url': serializer.toJson<String>(url),
      'groupTitle': serializer.toJson<String?>(groupTitle),
      'logoUrl': serializer.toJson<String?>(logoUrl),
      'epgId': serializer.toJson<String?>(epgId),
      'isRadio': serializer.toJson<bool>(isRadio),
      'number': serializer.toJson<int?>(number),
      'position': serializer.toJson<int>(position),
      'catchupType': serializer.toJson<int>(catchupType),
      'catchupSource': serializer.toJson<String?>(catchupSource),
      'catchupDays': serializer.toJson<int>(catchupDays),
      'catchupCorrection': serializer.toJson<int>(catchupCorrection),
      'extraJson': serializer.toJson<String>(extraJson),
    };
  }

  Channel copyWith(
          {int? rowId,
          int? sourceId,
          String? channelId,
          String? name,
          String? url,
          Value<String?> groupTitle = const Value.absent(),
          Value<String?> logoUrl = const Value.absent(),
          Value<String?> epgId = const Value.absent(),
          bool? isRadio,
          Value<int?> number = const Value.absent(),
          int? position,
          int? catchupType,
          Value<String?> catchupSource = const Value.absent(),
          int? catchupDays,
          int? catchupCorrection,
          String? extraJson}) =>
      Channel(
        rowId: rowId ?? this.rowId,
        sourceId: sourceId ?? this.sourceId,
        channelId: channelId ?? this.channelId,
        name: name ?? this.name,
        url: url ?? this.url,
        groupTitle: groupTitle.present ? groupTitle.value : this.groupTitle,
        logoUrl: logoUrl.present ? logoUrl.value : this.logoUrl,
        epgId: epgId.present ? epgId.value : this.epgId,
        isRadio: isRadio ?? this.isRadio,
        number: number.present ? number.value : this.number,
        position: position ?? this.position,
        catchupType: catchupType ?? this.catchupType,
        catchupSource:
            catchupSource.present ? catchupSource.value : this.catchupSource,
        catchupDays: catchupDays ?? this.catchupDays,
        catchupCorrection: catchupCorrection ?? this.catchupCorrection,
        extraJson: extraJson ?? this.extraJson,
      );
  Channel copyWithCompanion(ChannelsCompanion data) {
    return Channel(
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      channelId: data.channelId.present ? data.channelId.value : this.channelId,
      name: data.name.present ? data.name.value : this.name,
      url: data.url.present ? data.url.value : this.url,
      groupTitle:
          data.groupTitle.present ? data.groupTitle.value : this.groupTitle,
      logoUrl: data.logoUrl.present ? data.logoUrl.value : this.logoUrl,
      epgId: data.epgId.present ? data.epgId.value : this.epgId,
      isRadio: data.isRadio.present ? data.isRadio.value : this.isRadio,
      number: data.number.present ? data.number.value : this.number,
      position: data.position.present ? data.position.value : this.position,
      catchupType:
          data.catchupType.present ? data.catchupType.value : this.catchupType,
      catchupSource: data.catchupSource.present
          ? data.catchupSource.value
          : this.catchupSource,
      catchupDays:
          data.catchupDays.present ? data.catchupDays.value : this.catchupDays,
      catchupCorrection: data.catchupCorrection.present
          ? data.catchupCorrection.value
          : this.catchupCorrection,
      extraJson: data.extraJson.present ? data.extraJson.value : this.extraJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Channel(')
          ..write('rowId: $rowId, ')
          ..write('sourceId: $sourceId, ')
          ..write('channelId: $channelId, ')
          ..write('name: $name, ')
          ..write('url: $url, ')
          ..write('groupTitle: $groupTitle, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('epgId: $epgId, ')
          ..write('isRadio: $isRadio, ')
          ..write('number: $number, ')
          ..write('position: $position, ')
          ..write('catchupType: $catchupType, ')
          ..write('catchupSource: $catchupSource, ')
          ..write('catchupDays: $catchupDays, ')
          ..write('catchupCorrection: $catchupCorrection, ')
          ..write('extraJson: $extraJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      rowId,
      sourceId,
      channelId,
      name,
      url,
      groupTitle,
      logoUrl,
      epgId,
      isRadio,
      number,
      position,
      catchupType,
      catchupSource,
      catchupDays,
      catchupCorrection,
      extraJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Channel &&
          other.rowId == this.rowId &&
          other.sourceId == this.sourceId &&
          other.channelId == this.channelId &&
          other.name == this.name &&
          other.url == this.url &&
          other.groupTitle == this.groupTitle &&
          other.logoUrl == this.logoUrl &&
          other.epgId == this.epgId &&
          other.isRadio == this.isRadio &&
          other.number == this.number &&
          other.position == this.position &&
          other.catchupType == this.catchupType &&
          other.catchupSource == this.catchupSource &&
          other.catchupDays == this.catchupDays &&
          other.catchupCorrection == this.catchupCorrection &&
          other.extraJson == this.extraJson);
}

class ChannelsCompanion extends UpdateCompanion<Channel> {
  final Value<int> rowId;
  final Value<int> sourceId;
  final Value<String> channelId;
  final Value<String> name;
  final Value<String> url;
  final Value<String?> groupTitle;
  final Value<String?> logoUrl;
  final Value<String?> epgId;
  final Value<bool> isRadio;
  final Value<int?> number;
  final Value<int> position;
  final Value<int> catchupType;
  final Value<String?> catchupSource;
  final Value<int> catchupDays;
  final Value<int> catchupCorrection;
  final Value<String> extraJson;
  const ChannelsCompanion({
    this.rowId = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.channelId = const Value.absent(),
    this.name = const Value.absent(),
    this.url = const Value.absent(),
    this.groupTitle = const Value.absent(),
    this.logoUrl = const Value.absent(),
    this.epgId = const Value.absent(),
    this.isRadio = const Value.absent(),
    this.number = const Value.absent(),
    this.position = const Value.absent(),
    this.catchupType = const Value.absent(),
    this.catchupSource = const Value.absent(),
    this.catchupDays = const Value.absent(),
    this.catchupCorrection = const Value.absent(),
    this.extraJson = const Value.absent(),
  });
  ChannelsCompanion.insert({
    this.rowId = const Value.absent(),
    required int sourceId,
    required String channelId,
    required String name,
    required String url,
    this.groupTitle = const Value.absent(),
    this.logoUrl = const Value.absent(),
    this.epgId = const Value.absent(),
    this.isRadio = const Value.absent(),
    this.number = const Value.absent(),
    this.position = const Value.absent(),
    this.catchupType = const Value.absent(),
    this.catchupSource = const Value.absent(),
    this.catchupDays = const Value.absent(),
    this.catchupCorrection = const Value.absent(),
    this.extraJson = const Value.absent(),
  })  : sourceId = Value(sourceId),
        channelId = Value(channelId),
        name = Value(name),
        url = Value(url);
  static Insertable<Channel> custom({
    Expression<int>? rowId,
    Expression<int>? sourceId,
    Expression<String>? channelId,
    Expression<String>? name,
    Expression<String>? url,
    Expression<String>? groupTitle,
    Expression<String>? logoUrl,
    Expression<String>? epgId,
    Expression<bool>? isRadio,
    Expression<int>? number,
    Expression<int>? position,
    Expression<int>? catchupType,
    Expression<String>? catchupSource,
    Expression<int>? catchupDays,
    Expression<int>? catchupCorrection,
    Expression<String>? extraJson,
  }) {
    return RawValuesInsertable({
      if (rowId != null) 'row_id': rowId,
      if (sourceId != null) 'source_id': sourceId,
      if (channelId != null) 'channel_id': channelId,
      if (name != null) 'name': name,
      if (url != null) 'url': url,
      if (groupTitle != null) 'group_title': groupTitle,
      if (logoUrl != null) 'logo_url': logoUrl,
      if (epgId != null) 'epg_id': epgId,
      if (isRadio != null) 'is_radio': isRadio,
      if (number != null) 'number': number,
      if (position != null) 'position': position,
      if (catchupType != null) 'catchup_type': catchupType,
      if (catchupSource != null) 'catchup_source': catchupSource,
      if (catchupDays != null) 'catchup_days': catchupDays,
      if (catchupCorrection != null) 'catchup_correction': catchupCorrection,
      if (extraJson != null) 'extra_json': extraJson,
    });
  }

  ChannelsCompanion copyWith(
      {Value<int>? rowId,
      Value<int>? sourceId,
      Value<String>? channelId,
      Value<String>? name,
      Value<String>? url,
      Value<String?>? groupTitle,
      Value<String?>? logoUrl,
      Value<String?>? epgId,
      Value<bool>? isRadio,
      Value<int?>? number,
      Value<int>? position,
      Value<int>? catchupType,
      Value<String?>? catchupSource,
      Value<int>? catchupDays,
      Value<int>? catchupCorrection,
      Value<String>? extraJson}) {
    return ChannelsCompanion(
      rowId: rowId ?? this.rowId,
      sourceId: sourceId ?? this.sourceId,
      channelId: channelId ?? this.channelId,
      name: name ?? this.name,
      url: url ?? this.url,
      groupTitle: groupTitle ?? this.groupTitle,
      logoUrl: logoUrl ?? this.logoUrl,
      epgId: epgId ?? this.epgId,
      isRadio: isRadio ?? this.isRadio,
      number: number ?? this.number,
      position: position ?? this.position,
      catchupType: catchupType ?? this.catchupType,
      catchupSource: catchupSource ?? this.catchupSource,
      catchupDays: catchupDays ?? this.catchupDays,
      catchupCorrection: catchupCorrection ?? this.catchupCorrection,
      extraJson: extraJson ?? this.extraJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rowId.present) {
      map['row_id'] = Variable<int>(rowId.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<int>(sourceId.value);
    }
    if (channelId.present) {
      map['channel_id'] = Variable<String>(channelId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (groupTitle.present) {
      map['group_title'] = Variable<String>(groupTitle.value);
    }
    if (logoUrl.present) {
      map['logo_url'] = Variable<String>(logoUrl.value);
    }
    if (epgId.present) {
      map['epg_id'] = Variable<String>(epgId.value);
    }
    if (isRadio.present) {
      map['is_radio'] = Variable<bool>(isRadio.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (catchupType.present) {
      map['catchup_type'] = Variable<int>(catchupType.value);
    }
    if (catchupSource.present) {
      map['catchup_source'] = Variable<String>(catchupSource.value);
    }
    if (catchupDays.present) {
      map['catchup_days'] = Variable<int>(catchupDays.value);
    }
    if (catchupCorrection.present) {
      map['catchup_correction'] = Variable<int>(catchupCorrection.value);
    }
    if (extraJson.present) {
      map['extra_json'] = Variable<String>(extraJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChannelsCompanion(')
          ..write('rowId: $rowId, ')
          ..write('sourceId: $sourceId, ')
          ..write('channelId: $channelId, ')
          ..write('name: $name, ')
          ..write('url: $url, ')
          ..write('groupTitle: $groupTitle, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('epgId: $epgId, ')
          ..write('isRadio: $isRadio, ')
          ..write('number: $number, ')
          ..write('position: $position, ')
          ..write('catchupType: $catchupType, ')
          ..write('catchupSource: $catchupSource, ')
          ..write('catchupDays: $catchupDays, ')
          ..write('catchupCorrection: $catchupCorrection, ')
          ..write('extraJson: $extraJson')
          ..write(')'))
        .toString();
  }
}

class $EpgChannelsTable extends EpgChannels
    with TableInfo<$EpgChannelsTable, EpgChannel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EpgChannelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, displayName, icon];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'epg_channels';
  @override
  VerificationContext validateIntegrity(Insertable<EpgChannel> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EpgChannel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EpgChannel(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon']),
    );
  }

  @override
  $EpgChannelsTable createAlias(String alias) {
    return $EpgChannelsTable(attachedDatabase, alias);
  }
}

class EpgChannel extends DataClass implements Insertable<EpgChannel> {
  final String id;
  final String displayName;
  final String? icon;
  const EpgChannel({required this.id, required this.displayName, this.icon});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    return map;
  }

  EpgChannelsCompanion toCompanion(bool nullToAbsent) {
    return EpgChannelsCompanion(
      id: Value(id),
      displayName: Value(displayName),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
    );
  }

  factory EpgChannel.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EpgChannel(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      icon: serializer.fromJson<String?>(json['icon']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String>(displayName),
      'icon': serializer.toJson<String?>(icon),
    };
  }

  EpgChannel copyWith(
          {String? id,
          String? displayName,
          Value<String?> icon = const Value.absent()}) =>
      EpgChannel(
        id: id ?? this.id,
        displayName: displayName ?? this.displayName,
        icon: icon.present ? icon.value : this.icon,
      );
  EpgChannel copyWithCompanion(EpgChannelsCompanion data) {
    return EpgChannel(
      id: data.id.present ? data.id.value : this.id,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      icon: data.icon.present ? data.icon.value : this.icon,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EpgChannel(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('icon: $icon')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, displayName, icon);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EpgChannel &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.icon == this.icon);
}

class EpgChannelsCompanion extends UpdateCompanion<EpgChannel> {
  final Value<String> id;
  final Value<String> displayName;
  final Value<String?> icon;
  final Value<int> rowid;
  const EpgChannelsCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.icon = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EpgChannelsCompanion.insert({
    required String id,
    required String displayName,
    this.icon = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        displayName = Value(displayName);
  static Insertable<EpgChannel> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<String>? icon,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (icon != null) 'icon': icon,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EpgChannelsCompanion copyWith(
      {Value<String>? id,
      Value<String>? displayName,
      Value<String?>? icon,
      Value<int>? rowid}) {
    return EpgChannelsCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      icon: icon ?? this.icon,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EpgChannelsCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('icon: $icon, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EpgProgrammesTable extends EpgProgrammes
    with TableInfo<$EpgProgrammesTable, EpgProgramme> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EpgProgrammesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  @override
  late final GeneratedColumn<int> rowId = GeneratedColumn<int>(
      'row_id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _channelIdMeta =
      const VerificationMeta('channelId');
  @override
  late final GeneratedColumn<String> channelId = GeneratedColumn<String>(
      'channel_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startUtcMeta =
      const VerificationMeta('startUtc');
  @override
  late final GeneratedColumn<int> startUtc = GeneratedColumn<int>(
      'start_utc', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _stopUtcMeta =
      const VerificationMeta('stopUtc');
  @override
  late final GeneratedColumn<int> stopUtc = GeneratedColumn<int>(
      'stop_utc', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [rowId, channelId, startUtc, stopUtc, title, description, category];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'epg_programmes';
  @override
  VerificationContext validateIntegrity(Insertable<EpgProgramme> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('row_id')) {
      context.handle(
          _rowIdMeta, rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta));
    }
    if (data.containsKey('channel_id')) {
      context.handle(_channelIdMeta,
          channelId.isAcceptableOrUnknown(data['channel_id']!, _channelIdMeta));
    } else if (isInserting) {
      context.missing(_channelIdMeta);
    }
    if (data.containsKey('start_utc')) {
      context.handle(_startUtcMeta,
          startUtc.isAcceptableOrUnknown(data['start_utc']!, _startUtcMeta));
    } else if (isInserting) {
      context.missing(_startUtcMeta);
    }
    if (data.containsKey('stop_utc')) {
      context.handle(_stopUtcMeta,
          stopUtc.isAcceptableOrUnknown(data['stop_utc']!, _stopUtcMeta));
    } else if (isInserting) {
      context.missing(_stopUtcMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {rowId};
  @override
  EpgProgramme map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EpgProgramme(
      rowId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}row_id'])!,
      channelId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}channel_id'])!,
      startUtc: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}start_utc'])!,
      stopUtc: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stop_utc'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
    );
  }

  @override
  $EpgProgrammesTable createAlias(String alias) {
    return $EpgProgrammesTable(attachedDatabase, alias);
  }
}

class EpgProgramme extends DataClass implements Insertable<EpgProgramme> {
  final int rowId;
  final String channelId;
  final int startUtc;
  final int stopUtc;
  final String title;
  final String? description;
  final String? category;
  const EpgProgramme(
      {required this.rowId,
      required this.channelId,
      required this.startUtc,
      required this.stopUtc,
      required this.title,
      this.description,
      this.category});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['row_id'] = Variable<int>(rowId);
    map['channel_id'] = Variable<String>(channelId);
    map['start_utc'] = Variable<int>(startUtc);
    map['stop_utc'] = Variable<int>(stopUtc);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    return map;
  }

  EpgProgrammesCompanion toCompanion(bool nullToAbsent) {
    return EpgProgrammesCompanion(
      rowId: Value(rowId),
      channelId: Value(channelId),
      startUtc: Value(startUtc),
      stopUtc: Value(stopUtc),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
    );
  }

  factory EpgProgramme.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EpgProgramme(
      rowId: serializer.fromJson<int>(json['rowId']),
      channelId: serializer.fromJson<String>(json['channelId']),
      startUtc: serializer.fromJson<int>(json['startUtc']),
      stopUtc: serializer.fromJson<int>(json['stopUtc']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      category: serializer.fromJson<String?>(json['category']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rowId': serializer.toJson<int>(rowId),
      'channelId': serializer.toJson<String>(channelId),
      'startUtc': serializer.toJson<int>(startUtc),
      'stopUtc': serializer.toJson<int>(stopUtc),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'category': serializer.toJson<String?>(category),
    };
  }

  EpgProgramme copyWith(
          {int? rowId,
          String? channelId,
          int? startUtc,
          int? stopUtc,
          String? title,
          Value<String?> description = const Value.absent(),
          Value<String?> category = const Value.absent()}) =>
      EpgProgramme(
        rowId: rowId ?? this.rowId,
        channelId: channelId ?? this.channelId,
        startUtc: startUtc ?? this.startUtc,
        stopUtc: stopUtc ?? this.stopUtc,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        category: category.present ? category.value : this.category,
      );
  EpgProgramme copyWithCompanion(EpgProgrammesCompanion data) {
    return EpgProgramme(
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      channelId: data.channelId.present ? data.channelId.value : this.channelId,
      startUtc: data.startUtc.present ? data.startUtc.value : this.startUtc,
      stopUtc: data.stopUtc.present ? data.stopUtc.value : this.stopUtc,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      category: data.category.present ? data.category.value : this.category,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EpgProgramme(')
          ..write('rowId: $rowId, ')
          ..write('channelId: $channelId, ')
          ..write('startUtc: $startUtc, ')
          ..write('stopUtc: $stopUtc, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('category: $category')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      rowId, channelId, startUtc, stopUtc, title, description, category);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EpgProgramme &&
          other.rowId == this.rowId &&
          other.channelId == this.channelId &&
          other.startUtc == this.startUtc &&
          other.stopUtc == this.stopUtc &&
          other.title == this.title &&
          other.description == this.description &&
          other.category == this.category);
}

class EpgProgrammesCompanion extends UpdateCompanion<EpgProgramme> {
  final Value<int> rowId;
  final Value<String> channelId;
  final Value<int> startUtc;
  final Value<int> stopUtc;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> category;
  const EpgProgrammesCompanion({
    this.rowId = const Value.absent(),
    this.channelId = const Value.absent(),
    this.startUtc = const Value.absent(),
    this.stopUtc = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.category = const Value.absent(),
  });
  EpgProgrammesCompanion.insert({
    this.rowId = const Value.absent(),
    required String channelId,
    required int startUtc,
    required int stopUtc,
    required String title,
    this.description = const Value.absent(),
    this.category = const Value.absent(),
  })  : channelId = Value(channelId),
        startUtc = Value(startUtc),
        stopUtc = Value(stopUtc),
        title = Value(title);
  static Insertable<EpgProgramme> custom({
    Expression<int>? rowId,
    Expression<String>? channelId,
    Expression<int>? startUtc,
    Expression<int>? stopUtc,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? category,
  }) {
    return RawValuesInsertable({
      if (rowId != null) 'row_id': rowId,
      if (channelId != null) 'channel_id': channelId,
      if (startUtc != null) 'start_utc': startUtc,
      if (stopUtc != null) 'stop_utc': stopUtc,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
    });
  }

  EpgProgrammesCompanion copyWith(
      {Value<int>? rowId,
      Value<String>? channelId,
      Value<int>? startUtc,
      Value<int>? stopUtc,
      Value<String>? title,
      Value<String?>? description,
      Value<String?>? category}) {
    return EpgProgrammesCompanion(
      rowId: rowId ?? this.rowId,
      channelId: channelId ?? this.channelId,
      startUtc: startUtc ?? this.startUtc,
      stopUtc: stopUtc ?? this.stopUtc,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rowId.present) {
      map['row_id'] = Variable<int>(rowId.value);
    }
    if (channelId.present) {
      map['channel_id'] = Variable<String>(channelId.value);
    }
    if (startUtc.present) {
      map['start_utc'] = Variable<int>(startUtc.value);
    }
    if (stopUtc.present) {
      map['stop_utc'] = Variable<int>(stopUtc.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EpgProgrammesCompanion(')
          ..write('rowId: $rowId, ')
          ..write('channelId: $channelId, ')
          ..write('startUtc: $startUtc, ')
          ..write('stopUtc: $stopUtc, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('category: $category')
          ..write(')'))
        .toString();
  }
}

class $VodEntriesTable extends VodEntries
    with TableInfo<$VodEntriesTable, VodEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VodEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  @override
  late final GeneratedColumn<int> rowId = GeneratedColumn<int>(
      'row_id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  @override
  late final GeneratedColumn<int> sourceId = GeneratedColumn<int>(
      'source_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES playlists (id) ON DELETE CASCADE'));
  static const VerificationMeta _entryIdMeta =
      const VerificationMeta('entryId');
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
      'entry_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _coverMeta = const VerificationMeta('cover');
  @override
  late final GeneratedColumn<String> cover = GeneratedColumn<String>(
      'cover', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryNameMeta =
      const VerificationMeta('categoryName');
  @override
  late final GeneratedColumn<String> categoryName = GeneratedColumn<String>(
      'category_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _plotMeta = const VerificationMeta('plot');
  @override
  late final GeneratedColumn<String> plot = GeneratedColumn<String>(
      'plot', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<String> rating = GeneratedColumn<String>(
      'rating', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<String> year = GeneratedColumn<String>(
      'year', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        rowId,
        sourceId,
        entryId,
        kind,
        title,
        cover,
        categoryId,
        categoryName,
        plot,
        rating,
        year,
        url,
        position
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vod_entries';
  @override
  VerificationContext validateIntegrity(Insertable<VodEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('row_id')) {
      context.handle(
          _rowIdMeta, rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta));
    }
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('entry_id')) {
      context.handle(_entryIdMeta,
          entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta));
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('cover')) {
      context.handle(
          _coverMeta, cover.isAcceptableOrUnknown(data['cover']!, _coverMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('category_name')) {
      context.handle(
          _categoryNameMeta,
          categoryName.isAcceptableOrUnknown(
              data['category_name']!, _categoryNameMeta));
    }
    if (data.containsKey('plot')) {
      context.handle(
          _plotMeta, plot.isAcceptableOrUnknown(data['plot']!, _plotMeta));
    }
    if (data.containsKey('rating')) {
      context.handle(_ratingMeta,
          rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta));
    }
    if (data.containsKey('year')) {
      context.handle(
          _yearMeta, year.isAcceptableOrUnknown(data['year']!, _yearMeta));
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {rowId};
  @override
  VodEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VodEntry(
      rowId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}row_id'])!,
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}source_id'])!,
      entryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entry_id'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      cover: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover']),
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id']),
      categoryName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_name']),
      plot: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}plot']),
      rating: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rating']),
      year: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}year']),
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url']),
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
    );
  }

  @override
  $VodEntriesTable createAlias(String alias) {
    return $VodEntriesTable(attachedDatabase, alias);
  }
}

class VodEntry extends DataClass implements Insertable<VodEntry> {
  final int rowId;
  final int sourceId;
  final String entryId;
  final String kind;
  final String title;
  final String? cover;
  final String? categoryId;
  final String? categoryName;
  final String? plot;
  final String? rating;
  final String? year;
  final String? url;
  final int position;
  const VodEntry(
      {required this.rowId,
      required this.sourceId,
      required this.entryId,
      required this.kind,
      required this.title,
      this.cover,
      this.categoryId,
      this.categoryName,
      this.plot,
      this.rating,
      this.year,
      this.url,
      required this.position});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['row_id'] = Variable<int>(rowId);
    map['source_id'] = Variable<int>(sourceId);
    map['entry_id'] = Variable<String>(entryId);
    map['kind'] = Variable<String>(kind);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || cover != null) {
      map['cover'] = Variable<String>(cover);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || categoryName != null) {
      map['category_name'] = Variable<String>(categoryName);
    }
    if (!nullToAbsent || plot != null) {
      map['plot'] = Variable<String>(plot);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<String>(rating);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<String>(year);
    }
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    map['position'] = Variable<int>(position);
    return map;
  }

  VodEntriesCompanion toCompanion(bool nullToAbsent) {
    return VodEntriesCompanion(
      rowId: Value(rowId),
      sourceId: Value(sourceId),
      entryId: Value(entryId),
      kind: Value(kind),
      title: Value(title),
      cover:
          cover == null && nullToAbsent ? const Value.absent() : Value(cover),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      categoryName: categoryName == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryName),
      plot: plot == null && nullToAbsent ? const Value.absent() : Value(plot),
      rating:
          rating == null && nullToAbsent ? const Value.absent() : Value(rating),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      position: Value(position),
    );
  }

  factory VodEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VodEntry(
      rowId: serializer.fromJson<int>(json['rowId']),
      sourceId: serializer.fromJson<int>(json['sourceId']),
      entryId: serializer.fromJson<String>(json['entryId']),
      kind: serializer.fromJson<String>(json['kind']),
      title: serializer.fromJson<String>(json['title']),
      cover: serializer.fromJson<String?>(json['cover']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      categoryName: serializer.fromJson<String?>(json['categoryName']),
      plot: serializer.fromJson<String?>(json['plot']),
      rating: serializer.fromJson<String?>(json['rating']),
      year: serializer.fromJson<String?>(json['year']),
      url: serializer.fromJson<String?>(json['url']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rowId': serializer.toJson<int>(rowId),
      'sourceId': serializer.toJson<int>(sourceId),
      'entryId': serializer.toJson<String>(entryId),
      'kind': serializer.toJson<String>(kind),
      'title': serializer.toJson<String>(title),
      'cover': serializer.toJson<String?>(cover),
      'categoryId': serializer.toJson<String?>(categoryId),
      'categoryName': serializer.toJson<String?>(categoryName),
      'plot': serializer.toJson<String?>(plot),
      'rating': serializer.toJson<String?>(rating),
      'year': serializer.toJson<String?>(year),
      'url': serializer.toJson<String?>(url),
      'position': serializer.toJson<int>(position),
    };
  }

  VodEntry copyWith(
          {int? rowId,
          int? sourceId,
          String? entryId,
          String? kind,
          String? title,
          Value<String?> cover = const Value.absent(),
          Value<String?> categoryId = const Value.absent(),
          Value<String?> categoryName = const Value.absent(),
          Value<String?> plot = const Value.absent(),
          Value<String?> rating = const Value.absent(),
          Value<String?> year = const Value.absent(),
          Value<String?> url = const Value.absent(),
          int? position}) =>
      VodEntry(
        rowId: rowId ?? this.rowId,
        sourceId: sourceId ?? this.sourceId,
        entryId: entryId ?? this.entryId,
        kind: kind ?? this.kind,
        title: title ?? this.title,
        cover: cover.present ? cover.value : this.cover,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        categoryName:
            categoryName.present ? categoryName.value : this.categoryName,
        plot: plot.present ? plot.value : this.plot,
        rating: rating.present ? rating.value : this.rating,
        year: year.present ? year.value : this.year,
        url: url.present ? url.value : this.url,
        position: position ?? this.position,
      );
  VodEntry copyWithCompanion(VodEntriesCompanion data) {
    return VodEntry(
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      kind: data.kind.present ? data.kind.value : this.kind,
      title: data.title.present ? data.title.value : this.title,
      cover: data.cover.present ? data.cover.value : this.cover,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      categoryName: data.categoryName.present
          ? data.categoryName.value
          : this.categoryName,
      plot: data.plot.present ? data.plot.value : this.plot,
      rating: data.rating.present ? data.rating.value : this.rating,
      year: data.year.present ? data.year.value : this.year,
      url: data.url.present ? data.url.value : this.url,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VodEntry(')
          ..write('rowId: $rowId, ')
          ..write('sourceId: $sourceId, ')
          ..write('entryId: $entryId, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('cover: $cover, ')
          ..write('categoryId: $categoryId, ')
          ..write('categoryName: $categoryName, ')
          ..write('plot: $plot, ')
          ..write('rating: $rating, ')
          ..write('year: $year, ')
          ..write('url: $url, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(rowId, sourceId, entryId, kind, title, cover,
      categoryId, categoryName, plot, rating, year, url, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VodEntry &&
          other.rowId == this.rowId &&
          other.sourceId == this.sourceId &&
          other.entryId == this.entryId &&
          other.kind == this.kind &&
          other.title == this.title &&
          other.cover == this.cover &&
          other.categoryId == this.categoryId &&
          other.categoryName == this.categoryName &&
          other.plot == this.plot &&
          other.rating == this.rating &&
          other.year == this.year &&
          other.url == this.url &&
          other.position == this.position);
}

class VodEntriesCompanion extends UpdateCompanion<VodEntry> {
  final Value<int> rowId;
  final Value<int> sourceId;
  final Value<String> entryId;
  final Value<String> kind;
  final Value<String> title;
  final Value<String?> cover;
  final Value<String?> categoryId;
  final Value<String?> categoryName;
  final Value<String?> plot;
  final Value<String?> rating;
  final Value<String?> year;
  final Value<String?> url;
  final Value<int> position;
  const VodEntriesCompanion({
    this.rowId = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.entryId = const Value.absent(),
    this.kind = const Value.absent(),
    this.title = const Value.absent(),
    this.cover = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.categoryName = const Value.absent(),
    this.plot = const Value.absent(),
    this.rating = const Value.absent(),
    this.year = const Value.absent(),
    this.url = const Value.absent(),
    this.position = const Value.absent(),
  });
  VodEntriesCompanion.insert({
    this.rowId = const Value.absent(),
    required int sourceId,
    required String entryId,
    required String kind,
    required String title,
    this.cover = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.categoryName = const Value.absent(),
    this.plot = const Value.absent(),
    this.rating = const Value.absent(),
    this.year = const Value.absent(),
    this.url = const Value.absent(),
    this.position = const Value.absent(),
  })  : sourceId = Value(sourceId),
        entryId = Value(entryId),
        kind = Value(kind),
        title = Value(title);
  static Insertable<VodEntry> custom({
    Expression<int>? rowId,
    Expression<int>? sourceId,
    Expression<String>? entryId,
    Expression<String>? kind,
    Expression<String>? title,
    Expression<String>? cover,
    Expression<String>? categoryId,
    Expression<String>? categoryName,
    Expression<String>? plot,
    Expression<String>? rating,
    Expression<String>? year,
    Expression<String>? url,
    Expression<int>? position,
  }) {
    return RawValuesInsertable({
      if (rowId != null) 'row_id': rowId,
      if (sourceId != null) 'source_id': sourceId,
      if (entryId != null) 'entry_id': entryId,
      if (kind != null) 'kind': kind,
      if (title != null) 'title': title,
      if (cover != null) 'cover': cover,
      if (categoryId != null) 'category_id': categoryId,
      if (categoryName != null) 'category_name': categoryName,
      if (plot != null) 'plot': plot,
      if (rating != null) 'rating': rating,
      if (year != null) 'year': year,
      if (url != null) 'url': url,
      if (position != null) 'position': position,
    });
  }

  VodEntriesCompanion copyWith(
      {Value<int>? rowId,
      Value<int>? sourceId,
      Value<String>? entryId,
      Value<String>? kind,
      Value<String>? title,
      Value<String?>? cover,
      Value<String?>? categoryId,
      Value<String?>? categoryName,
      Value<String?>? plot,
      Value<String?>? rating,
      Value<String?>? year,
      Value<String?>? url,
      Value<int>? position}) {
    return VodEntriesCompanion(
      rowId: rowId ?? this.rowId,
      sourceId: sourceId ?? this.sourceId,
      entryId: entryId ?? this.entryId,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      cover: cover ?? this.cover,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      plot: plot ?? this.plot,
      rating: rating ?? this.rating,
      year: year ?? this.year,
      url: url ?? this.url,
      position: position ?? this.position,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rowId.present) {
      map['row_id'] = Variable<int>(rowId.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<int>(sourceId.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (cover.present) {
      map['cover'] = Variable<String>(cover.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (categoryName.present) {
      map['category_name'] = Variable<String>(categoryName.value);
    }
    if (plot.present) {
      map['plot'] = Variable<String>(plot.value);
    }
    if (rating.present) {
      map['rating'] = Variable<String>(rating.value);
    }
    if (year.present) {
      map['year'] = Variable<String>(year.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VodEntriesCompanion(')
          ..write('rowId: $rowId, ')
          ..write('sourceId: $sourceId, ')
          ..write('entryId: $entryId, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('cover: $cover, ')
          ..write('categoryId: $categoryId, ')
          ..write('categoryName: $categoryName, ')
          ..write('plot: $plot, ')
          ..write('rating: $rating, ')
          ..write('year: $year, ')
          ..write('url: $url, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }
}

class $ScheduledTasksTable extends ScheduledTasks
    with TableInfo<$ScheduledTasksTable, ScheduledTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduledTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fireAtUtcMeta =
      const VerificationMeta('fireAtUtc');
  @override
  late final GeneratedColumn<int> fireAtUtc = GeneratedColumn<int>(
      'fire_at_utc', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _endAtUtcMeta =
      const VerificationMeta('endAtUtc');
  @override
  late final GeneratedColumn<int> endAtUtc = GeneratedColumn<int>(
      'end_at_utc', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _recurrenceMeta =
      const VerificationMeta('recurrence');
  @override
  late final GeneratedColumn<String> recurrence = GeneratedColumn<String>(
      'recurrence', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('once'));
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  @override
  late final GeneratedColumn<int> sourceId = GeneratedColumn<int>(
      'source_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _channelIdMeta =
      const VerificationMeta('channelId');
  @override
  late final GeneratedColumn<String> channelId = GeneratedColumn<String>(
      'channel_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _channelNameMeta =
      const VerificationMeta('channelName');
  @override
  late final GeneratedColumn<String> channelName = GeneratedColumn<String>(
      'channel_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _channelUrlMeta =
      const VerificationMeta('channelUrl');
  @override
  late final GeneratedColumn<String> channelUrl = GeneratedColumn<String>(
      'channel_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _enabledMeta =
      const VerificationMeta('enabled');
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
      'enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        kind,
        fireAtUtc,
        endAtUtc,
        recurrence,
        sourceId,
        channelId,
        channelName,
        channelUrl,
        title,
        enabled
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scheduled_tasks';
  @override
  VerificationContext validateIntegrity(Insertable<ScheduledTask> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('fire_at_utc')) {
      context.handle(
          _fireAtUtcMeta,
          fireAtUtc.isAcceptableOrUnknown(
              data['fire_at_utc']!, _fireAtUtcMeta));
    } else if (isInserting) {
      context.missing(_fireAtUtcMeta);
    }
    if (data.containsKey('end_at_utc')) {
      context.handle(_endAtUtcMeta,
          endAtUtc.isAcceptableOrUnknown(data['end_at_utc']!, _endAtUtcMeta));
    }
    if (data.containsKey('recurrence')) {
      context.handle(
          _recurrenceMeta,
          recurrence.isAcceptableOrUnknown(
              data['recurrence']!, _recurrenceMeta));
    }
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    }
    if (data.containsKey('channel_id')) {
      context.handle(_channelIdMeta,
          channelId.isAcceptableOrUnknown(data['channel_id']!, _channelIdMeta));
    }
    if (data.containsKey('channel_name')) {
      context.handle(
          _channelNameMeta,
          channelName.isAcceptableOrUnknown(
              data['channel_name']!, _channelNameMeta));
    }
    if (data.containsKey('channel_url')) {
      context.handle(
          _channelUrlMeta,
          channelUrl.isAcceptableOrUnknown(
              data['channel_url']!, _channelUrlMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('enabled')) {
      context.handle(_enabledMeta,
          enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScheduledTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduledTask(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      fireAtUtc: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}fire_at_utc'])!,
      endAtUtc: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}end_at_utc']),
      recurrence: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recurrence'])!,
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}source_id']),
      channelId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}channel_id']),
      channelName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}channel_name']),
      channelUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}channel_url']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      enabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}enabled'])!,
    );
  }

  @override
  $ScheduledTasksTable createAlias(String alias) {
    return $ScheduledTasksTable(attachedDatabase, alias);
  }
}

class ScheduledTask extends DataClass implements Insertable<ScheduledTask> {
  final int id;

  /// `record` | `reminder` | `zap` | `sleepTimer`.
  final String kind;
  final int fireAtUtc;
  final int? endAtUtc;

  /// `once` | `daily` | `weekly`.
  final String recurrence;
  final int? sourceId;
  final String? channelId;
  final String? channelName;
  final String? channelUrl;
  final String? title;
  final bool enabled;
  const ScheduledTask(
      {required this.id,
      required this.kind,
      required this.fireAtUtc,
      this.endAtUtc,
      required this.recurrence,
      this.sourceId,
      this.channelId,
      this.channelName,
      this.channelUrl,
      this.title,
      required this.enabled});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kind'] = Variable<String>(kind);
    map['fire_at_utc'] = Variable<int>(fireAtUtc);
    if (!nullToAbsent || endAtUtc != null) {
      map['end_at_utc'] = Variable<int>(endAtUtc);
    }
    map['recurrence'] = Variable<String>(recurrence);
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<int>(sourceId);
    }
    if (!nullToAbsent || channelId != null) {
      map['channel_id'] = Variable<String>(channelId);
    }
    if (!nullToAbsent || channelName != null) {
      map['channel_name'] = Variable<String>(channelName);
    }
    if (!nullToAbsent || channelUrl != null) {
      map['channel_url'] = Variable<String>(channelUrl);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  ScheduledTasksCompanion toCompanion(bool nullToAbsent) {
    return ScheduledTasksCompanion(
      id: Value(id),
      kind: Value(kind),
      fireAtUtc: Value(fireAtUtc),
      endAtUtc: endAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(endAtUtc),
      recurrence: Value(recurrence),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      channelId: channelId == null && nullToAbsent
          ? const Value.absent()
          : Value(channelId),
      channelName: channelName == null && nullToAbsent
          ? const Value.absent()
          : Value(channelName),
      channelUrl: channelUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(channelUrl),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      enabled: Value(enabled),
    );
  }

  factory ScheduledTask.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduledTask(
      id: serializer.fromJson<int>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      fireAtUtc: serializer.fromJson<int>(json['fireAtUtc']),
      endAtUtc: serializer.fromJson<int?>(json['endAtUtc']),
      recurrence: serializer.fromJson<String>(json['recurrence']),
      sourceId: serializer.fromJson<int?>(json['sourceId']),
      channelId: serializer.fromJson<String?>(json['channelId']),
      channelName: serializer.fromJson<String?>(json['channelName']),
      channelUrl: serializer.fromJson<String?>(json['channelUrl']),
      title: serializer.fromJson<String?>(json['title']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<String>(kind),
      'fireAtUtc': serializer.toJson<int>(fireAtUtc),
      'endAtUtc': serializer.toJson<int?>(endAtUtc),
      'recurrence': serializer.toJson<String>(recurrence),
      'sourceId': serializer.toJson<int?>(sourceId),
      'channelId': serializer.toJson<String?>(channelId),
      'channelName': serializer.toJson<String?>(channelName),
      'channelUrl': serializer.toJson<String?>(channelUrl),
      'title': serializer.toJson<String?>(title),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  ScheduledTask copyWith(
          {int? id,
          String? kind,
          int? fireAtUtc,
          Value<int?> endAtUtc = const Value.absent(),
          String? recurrence,
          Value<int?> sourceId = const Value.absent(),
          Value<String?> channelId = const Value.absent(),
          Value<String?> channelName = const Value.absent(),
          Value<String?> channelUrl = const Value.absent(),
          Value<String?> title = const Value.absent(),
          bool? enabled}) =>
      ScheduledTask(
        id: id ?? this.id,
        kind: kind ?? this.kind,
        fireAtUtc: fireAtUtc ?? this.fireAtUtc,
        endAtUtc: endAtUtc.present ? endAtUtc.value : this.endAtUtc,
        recurrence: recurrence ?? this.recurrence,
        sourceId: sourceId.present ? sourceId.value : this.sourceId,
        channelId: channelId.present ? channelId.value : this.channelId,
        channelName: channelName.present ? channelName.value : this.channelName,
        channelUrl: channelUrl.present ? channelUrl.value : this.channelUrl,
        title: title.present ? title.value : this.title,
        enabled: enabled ?? this.enabled,
      );
  ScheduledTask copyWithCompanion(ScheduledTasksCompanion data) {
    return ScheduledTask(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      fireAtUtc: data.fireAtUtc.present ? data.fireAtUtc.value : this.fireAtUtc,
      endAtUtc: data.endAtUtc.present ? data.endAtUtc.value : this.endAtUtc,
      recurrence:
          data.recurrence.present ? data.recurrence.value : this.recurrence,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      channelId: data.channelId.present ? data.channelId.value : this.channelId,
      channelName:
          data.channelName.present ? data.channelName.value : this.channelName,
      channelUrl:
          data.channelUrl.present ? data.channelUrl.value : this.channelUrl,
      title: data.title.present ? data.title.value : this.title,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduledTask(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('fireAtUtc: $fireAtUtc, ')
          ..write('endAtUtc: $endAtUtc, ')
          ..write('recurrence: $recurrence, ')
          ..write('sourceId: $sourceId, ')
          ..write('channelId: $channelId, ')
          ..write('channelName: $channelName, ')
          ..write('channelUrl: $channelUrl, ')
          ..write('title: $title, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, kind, fireAtUtc, endAtUtc, recurrence,
      sourceId, channelId, channelName, channelUrl, title, enabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduledTask &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.fireAtUtc == this.fireAtUtc &&
          other.endAtUtc == this.endAtUtc &&
          other.recurrence == this.recurrence &&
          other.sourceId == this.sourceId &&
          other.channelId == this.channelId &&
          other.channelName == this.channelName &&
          other.channelUrl == this.channelUrl &&
          other.title == this.title &&
          other.enabled == this.enabled);
}

class ScheduledTasksCompanion extends UpdateCompanion<ScheduledTask> {
  final Value<int> id;
  final Value<String> kind;
  final Value<int> fireAtUtc;
  final Value<int?> endAtUtc;
  final Value<String> recurrence;
  final Value<int?> sourceId;
  final Value<String?> channelId;
  final Value<String?> channelName;
  final Value<String?> channelUrl;
  final Value<String?> title;
  final Value<bool> enabled;
  const ScheduledTasksCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.fireAtUtc = const Value.absent(),
    this.endAtUtc = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.channelId = const Value.absent(),
    this.channelName = const Value.absent(),
    this.channelUrl = const Value.absent(),
    this.title = const Value.absent(),
    this.enabled = const Value.absent(),
  });
  ScheduledTasksCompanion.insert({
    this.id = const Value.absent(),
    required String kind,
    required int fireAtUtc,
    this.endAtUtc = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.channelId = const Value.absent(),
    this.channelName = const Value.absent(),
    this.channelUrl = const Value.absent(),
    this.title = const Value.absent(),
    this.enabled = const Value.absent(),
  })  : kind = Value(kind),
        fireAtUtc = Value(fireAtUtc);
  static Insertable<ScheduledTask> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<int>? fireAtUtc,
    Expression<int>? endAtUtc,
    Expression<String>? recurrence,
    Expression<int>? sourceId,
    Expression<String>? channelId,
    Expression<String>? channelName,
    Expression<String>? channelUrl,
    Expression<String>? title,
    Expression<bool>? enabled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (fireAtUtc != null) 'fire_at_utc': fireAtUtc,
      if (endAtUtc != null) 'end_at_utc': endAtUtc,
      if (recurrence != null) 'recurrence': recurrence,
      if (sourceId != null) 'source_id': sourceId,
      if (channelId != null) 'channel_id': channelId,
      if (channelName != null) 'channel_name': channelName,
      if (channelUrl != null) 'channel_url': channelUrl,
      if (title != null) 'title': title,
      if (enabled != null) 'enabled': enabled,
    });
  }

  ScheduledTasksCompanion copyWith(
      {Value<int>? id,
      Value<String>? kind,
      Value<int>? fireAtUtc,
      Value<int?>? endAtUtc,
      Value<String>? recurrence,
      Value<int?>? sourceId,
      Value<String?>? channelId,
      Value<String?>? channelName,
      Value<String?>? channelUrl,
      Value<String?>? title,
      Value<bool>? enabled}) {
    return ScheduledTasksCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      fireAtUtc: fireAtUtc ?? this.fireAtUtc,
      endAtUtc: endAtUtc ?? this.endAtUtc,
      recurrence: recurrence ?? this.recurrence,
      sourceId: sourceId ?? this.sourceId,
      channelId: channelId ?? this.channelId,
      channelName: channelName ?? this.channelName,
      channelUrl: channelUrl ?? this.channelUrl,
      title: title ?? this.title,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (fireAtUtc.present) {
      map['fire_at_utc'] = Variable<int>(fireAtUtc.value);
    }
    if (endAtUtc.present) {
      map['end_at_utc'] = Variable<int>(endAtUtc.value);
    }
    if (recurrence.present) {
      map['recurrence'] = Variable<String>(recurrence.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<int>(sourceId.value);
    }
    if (channelId.present) {
      map['channel_id'] = Variable<String>(channelId.value);
    }
    if (channelName.present) {
      map['channel_name'] = Variable<String>(channelName.value);
    }
    if (channelUrl.present) {
      map['channel_url'] = Variable<String>(channelUrl.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduledTasksCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('fireAtUtc: $fireAtUtc, ')
          ..write('endAtUtc: $endAtUtc, ')
          ..write('recurrence: $recurrence, ')
          ..write('sourceId: $sourceId, ')
          ..write('channelId: $channelId, ')
          ..write('channelName: $channelName, ')
          ..write('channelUrl: $channelUrl, ')
          ..write('title: $title, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }
}

class $FavoritesTable extends Favorites
    with TableInfo<$FavoritesTable, Favorite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _refIdMeta = const VerificationMeta('refId');
  @override
  late final GeneratedColumn<String> refId = GeneratedColumn<String>(
      'ref_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  @override
  late final GeneratedColumn<int> sourceId = GeneratedColumn<int>(
      'source_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subtitleMeta =
      const VerificationMeta('subtitle');
  @override
  late final GeneratedColumn<String> subtitle = GeneratedColumn<String>(
      'subtitle', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _playUrlMeta =
      const VerificationMeta('playUrl');
  @override
  late final GeneratedColumn<String> playUrl = GeneratedColumn<String>(
      'play_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _addedAtMeta =
      const VerificationMeta('addedAt');
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
      'added_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [refId, kind, sourceId, title, subtitle, imageUrl, playUrl, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorites';
  @override
  VerificationContext validateIntegrity(Insertable<Favorite> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('ref_id')) {
      context.handle(
          _refIdMeta, refId.isAcceptableOrUnknown(data['ref_id']!, _refIdMeta));
    } else if (isInserting) {
      context.missing(_refIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('subtitle')) {
      context.handle(_subtitleMeta,
          subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta));
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    }
    if (data.containsKey('play_url')) {
      context.handle(_playUrlMeta,
          playUrl.isAcceptableOrUnknown(data['play_url']!, _playUrlMeta));
    }
    if (data.containsKey('added_at')) {
      context.handle(_addedAtMeta,
          addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {refId};
  @override
  Favorite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Favorite(
      refId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ref_id'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}source_id']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      subtitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subtitle']),
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url']),
      playUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}play_url']),
      addedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}added_at'])!,
    );
  }

  @override
  $FavoritesTable createAlias(String alias) {
    return $FavoritesTable(attachedDatabase, alias);
  }
}

class Favorite extends DataClass implements Insertable<Favorite> {
  final String refId;

  /// `channel` | `vodMovie` | `vodSeries`.
  final String kind;
  final int? sourceId;
  final String title;
  final String? subtitle;
  final String? imageUrl;

  /// Playable URL for movies; null for series / dynamic channels.
  final String? playUrl;
  final DateTime addedAt;
  const Favorite(
      {required this.refId,
      required this.kind,
      this.sourceId,
      required this.title,
      this.subtitle,
      this.imageUrl,
      this.playUrl,
      required this.addedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['ref_id'] = Variable<String>(refId);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<int>(sourceId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || subtitle != null) {
      map['subtitle'] = Variable<String>(subtitle);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || playUrl != null) {
      map['play_url'] = Variable<String>(playUrl);
    }
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  FavoritesCompanion toCompanion(bool nullToAbsent) {
    return FavoritesCompanion(
      refId: Value(refId),
      kind: Value(kind),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      title: Value(title),
      subtitle: subtitle == null && nullToAbsent
          ? const Value.absent()
          : Value(subtitle),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      playUrl: playUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(playUrl),
      addedAt: Value(addedAt),
    );
  }

  factory Favorite.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Favorite(
      refId: serializer.fromJson<String>(json['refId']),
      kind: serializer.fromJson<String>(json['kind']),
      sourceId: serializer.fromJson<int?>(json['sourceId']),
      title: serializer.fromJson<String>(json['title']),
      subtitle: serializer.fromJson<String?>(json['subtitle']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      playUrl: serializer.fromJson<String?>(json['playUrl']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'refId': serializer.toJson<String>(refId),
      'kind': serializer.toJson<String>(kind),
      'sourceId': serializer.toJson<int?>(sourceId),
      'title': serializer.toJson<String>(title),
      'subtitle': serializer.toJson<String?>(subtitle),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'playUrl': serializer.toJson<String?>(playUrl),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  Favorite copyWith(
          {String? refId,
          String? kind,
          Value<int?> sourceId = const Value.absent(),
          String? title,
          Value<String?> subtitle = const Value.absent(),
          Value<String?> imageUrl = const Value.absent(),
          Value<String?> playUrl = const Value.absent(),
          DateTime? addedAt}) =>
      Favorite(
        refId: refId ?? this.refId,
        kind: kind ?? this.kind,
        sourceId: sourceId.present ? sourceId.value : this.sourceId,
        title: title ?? this.title,
        subtitle: subtitle.present ? subtitle.value : this.subtitle,
        imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
        playUrl: playUrl.present ? playUrl.value : this.playUrl,
        addedAt: addedAt ?? this.addedAt,
      );
  Favorite copyWithCompanion(FavoritesCompanion data) {
    return Favorite(
      refId: data.refId.present ? data.refId.value : this.refId,
      kind: data.kind.present ? data.kind.value : this.kind,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      title: data.title.present ? data.title.value : this.title,
      subtitle: data.subtitle.present ? data.subtitle.value : this.subtitle,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      playUrl: data.playUrl.present ? data.playUrl.value : this.playUrl,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Favorite(')
          ..write('refId: $refId, ')
          ..write('kind: $kind, ')
          ..write('sourceId: $sourceId, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('playUrl: $playUrl, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      refId, kind, sourceId, title, subtitle, imageUrl, playUrl, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Favorite &&
          other.refId == this.refId &&
          other.kind == this.kind &&
          other.sourceId == this.sourceId &&
          other.title == this.title &&
          other.subtitle == this.subtitle &&
          other.imageUrl == this.imageUrl &&
          other.playUrl == this.playUrl &&
          other.addedAt == this.addedAt);
}

class FavoritesCompanion extends UpdateCompanion<Favorite> {
  final Value<String> refId;
  final Value<String> kind;
  final Value<int?> sourceId;
  final Value<String> title;
  final Value<String?> subtitle;
  final Value<String?> imageUrl;
  final Value<String?> playUrl;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const FavoritesCompanion({
    this.refId = const Value.absent(),
    this.kind = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.title = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.playUrl = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoritesCompanion.insert({
    required String refId,
    required String kind,
    this.sourceId = const Value.absent(),
    required String title,
    this.subtitle = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.playUrl = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : refId = Value(refId),
        kind = Value(kind),
        title = Value(title);
  static Insertable<Favorite> custom({
    Expression<String>? refId,
    Expression<String>? kind,
    Expression<int>? sourceId,
    Expression<String>? title,
    Expression<String>? subtitle,
    Expression<String>? imageUrl,
    Expression<String>? playUrl,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (refId != null) 'ref_id': refId,
      if (kind != null) 'kind': kind,
      if (sourceId != null) 'source_id': sourceId,
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (imageUrl != null) 'image_url': imageUrl,
      if (playUrl != null) 'play_url': playUrl,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoritesCompanion copyWith(
      {Value<String>? refId,
      Value<String>? kind,
      Value<int?>? sourceId,
      Value<String>? title,
      Value<String?>? subtitle,
      Value<String?>? imageUrl,
      Value<String?>? playUrl,
      Value<DateTime>? addedAt,
      Value<int>? rowid}) {
    return FavoritesCompanion(
      refId: refId ?? this.refId,
      kind: kind ?? this.kind,
      sourceId: sourceId ?? this.sourceId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      playUrl: playUrl ?? this.playUrl,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (refId.present) {
      map['ref_id'] = Variable<String>(refId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<int>(sourceId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (subtitle.present) {
      map['subtitle'] = Variable<String>(subtitle.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (playUrl.present) {
      map['play_url'] = Variable<String>(playUrl.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoritesCompanion(')
          ..write('refId: $refId, ')
          ..write('kind: $kind, ')
          ..write('sourceId: $sourceId, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('playUrl: $playUrl, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PlaylistsTable playlists = $PlaylistsTable(this);
  late final $ChannelsTable channels = $ChannelsTable(this);
  late final $EpgChannelsTable epgChannels = $EpgChannelsTable(this);
  late final $EpgProgrammesTable epgProgrammes = $EpgProgrammesTable(this);
  late final $VodEntriesTable vodEntries = $VodEntriesTable(this);
  late final $ScheduledTasksTable scheduledTasks = $ScheduledTasksTable(this);
  late final $FavoritesTable favorites = $FavoritesTable(this);
  late final Index idxProgChanStart = Index('idx_prog_chan_start',
      'CREATE INDEX idx_prog_chan_start ON epg_programmes (channel_id, start_utc)');
  late final Index idxVodSourceKind = Index('idx_vod_source_kind',
      'CREATE INDEX idx_vod_source_kind ON vod_entries (source_id, kind)');
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        playlists,
        channels,
        epgChannels,
        epgProgrammes,
        vodEntries,
        scheduledTasks,
        favorites,
        idxProgChanStart,
        idxVodSourceKind
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('playlists',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('channels', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('playlists',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('vod_entries', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$PlaylistsTableCreateCompanionBuilder = PlaylistsCompanion Function({
  Value<int> id,
  required String name,
  Value<String> kind,
  required String location,
  Value<String?> epgUrl,
  Value<String> settingsJson,
  Value<DateTime> addedAt,
  Value<DateTime?> updatedAt,
});
typedef $$PlaylistsTableUpdateCompanionBuilder = PlaylistsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> kind,
  Value<String> location,
  Value<String?> epgUrl,
  Value<String> settingsJson,
  Value<DateTime> addedAt,
  Value<DateTime?> updatedAt,
});

final class $$PlaylistsTableReferences
    extends BaseReferences<_$AppDatabase, $PlaylistsTable, Playlist> {
  $$PlaylistsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ChannelsTable, List<Channel>> _channelsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.channels,
          aliasName:
              $_aliasNameGenerator(db.playlists.id, db.channels.sourceId));

  $$ChannelsTableProcessedTableManager get channelsRefs {
    final manager = $$ChannelsTableTableManager($_db, $_db.channels)
        .filter((f) => f.sourceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_channelsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$VodEntriesTable, List<VodEntry>>
      _vodEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.vodEntries,
          aliasName:
              $_aliasNameGenerator(db.playlists.id, db.vodEntries.sourceId));

  $$VodEntriesTableProcessedTableManager get vodEntriesRefs {
    final manager = $$VodEntriesTableTableManager($_db, $_db.vodEntries)
        .filter((f) => f.sourceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_vodEntriesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PlaylistsTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get epgUrl => $composableBuilder(
      column: $table.epgUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get settingsJson => $composableBuilder(
      column: $table.settingsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> channelsRefs(
      Expression<bool> Function($$ChannelsTableFilterComposer f) f) {
    final $$ChannelsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.channels,
        getReferencedColumn: (t) => t.sourceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChannelsTableFilterComposer(
              $db: $db,
              $table: $db.channels,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> vodEntriesRefs(
      Expression<bool> Function($$VodEntriesTableFilterComposer f) f) {
    final $$VodEntriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.vodEntries,
        getReferencedColumn: (t) => t.sourceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VodEntriesTableFilterComposer(
              $db: $db,
              $table: $db.vodEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PlaylistsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get epgUrl => $composableBuilder(
      column: $table.epgUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get settingsJson => $composableBuilder(
      column: $table.settingsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$PlaylistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get epgUrl =>
      $composableBuilder(column: $table.epgUrl, builder: (column) => column);

  GeneratedColumn<String> get settingsJson => $composableBuilder(
      column: $table.settingsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> channelsRefs<T extends Object>(
      Expression<T> Function($$ChannelsTableAnnotationComposer a) f) {
    final $$ChannelsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.channels,
        getReferencedColumn: (t) => t.sourceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChannelsTableAnnotationComposer(
              $db: $db,
              $table: $db.channels,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> vodEntriesRefs<T extends Object>(
      Expression<T> Function($$VodEntriesTableAnnotationComposer a) f) {
    final $$VodEntriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.vodEntries,
        getReferencedColumn: (t) => t.sourceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VodEntriesTableAnnotationComposer(
              $db: $db,
              $table: $db.vodEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PlaylistsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlaylistsTable,
    Playlist,
    $$PlaylistsTableFilterComposer,
    $$PlaylistsTableOrderingComposer,
    $$PlaylistsTableAnnotationComposer,
    $$PlaylistsTableCreateCompanionBuilder,
    $$PlaylistsTableUpdateCompanionBuilder,
    (Playlist, $$PlaylistsTableReferences),
    Playlist,
    PrefetchHooks Function({bool channelsRefs, bool vodEntriesRefs})> {
  $$PlaylistsTableTableManager(_$AppDatabase db, $PlaylistsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<String> location = const Value.absent(),
            Value<String?> epgUrl = const Value.absent(),
            Value<String> settingsJson = const Value.absent(),
            Value<DateTime> addedAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
          }) =>
              PlaylistsCompanion(
            id: id,
            name: name,
            kind: kind,
            location: location,
            epgUrl: epgUrl,
            settingsJson: settingsJson,
            addedAt: addedAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String> kind = const Value.absent(),
            required String location,
            Value<String?> epgUrl = const Value.absent(),
            Value<String> settingsJson = const Value.absent(),
            Value<DateTime> addedAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
          }) =>
              PlaylistsCompanion.insert(
            id: id,
            name: name,
            kind: kind,
            location: location,
            epgUrl: epgUrl,
            settingsJson: settingsJson,
            addedAt: addedAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PlaylistsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {channelsRefs = false, vodEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (channelsRefs) db.channels,
                if (vodEntriesRefs) db.vodEntries
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (channelsRefs)
                    await $_getPrefetchedData<Playlist, $PlaylistsTable,
                            Channel>(
                        currentTable: table,
                        referencedTable:
                            $$PlaylistsTableReferences._channelsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PlaylistsTableReferences(db, table, p0)
                                .channelsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.sourceId == item.id),
                        typedResults: items),
                  if (vodEntriesRefs)
                    await $_getPrefetchedData<Playlist, $PlaylistsTable,
                            VodEntry>(
                        currentTable: table,
                        referencedTable:
                            $$PlaylistsTableReferences._vodEntriesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PlaylistsTableReferences(db, table, p0)
                                .vodEntriesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.sourceId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PlaylistsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlaylistsTable,
    Playlist,
    $$PlaylistsTableFilterComposer,
    $$PlaylistsTableOrderingComposer,
    $$PlaylistsTableAnnotationComposer,
    $$PlaylistsTableCreateCompanionBuilder,
    $$PlaylistsTableUpdateCompanionBuilder,
    (Playlist, $$PlaylistsTableReferences),
    Playlist,
    PrefetchHooks Function({bool channelsRefs, bool vodEntriesRefs})>;
typedef $$ChannelsTableCreateCompanionBuilder = ChannelsCompanion Function({
  Value<int> rowId,
  required int sourceId,
  required String channelId,
  required String name,
  required String url,
  Value<String?> groupTitle,
  Value<String?> logoUrl,
  Value<String?> epgId,
  Value<bool> isRadio,
  Value<int?> number,
  Value<int> position,
  Value<int> catchupType,
  Value<String?> catchupSource,
  Value<int> catchupDays,
  Value<int> catchupCorrection,
  Value<String> extraJson,
});
typedef $$ChannelsTableUpdateCompanionBuilder = ChannelsCompanion Function({
  Value<int> rowId,
  Value<int> sourceId,
  Value<String> channelId,
  Value<String> name,
  Value<String> url,
  Value<String?> groupTitle,
  Value<String?> logoUrl,
  Value<String?> epgId,
  Value<bool> isRadio,
  Value<int?> number,
  Value<int> position,
  Value<int> catchupType,
  Value<String?> catchupSource,
  Value<int> catchupDays,
  Value<int> catchupCorrection,
  Value<String> extraJson,
});

final class $$ChannelsTableReferences
    extends BaseReferences<_$AppDatabase, $ChannelsTable, Channel> {
  $$ChannelsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlaylistsTable _sourceIdTable(_$AppDatabase db) => db.playlists
      .createAlias($_aliasNameGenerator(db.channels.sourceId, db.playlists.id));

  $$PlaylistsTableProcessedTableManager get sourceId {
    final $_column = $_itemColumn<int>('source_id')!;

    final manager = $$PlaylistsTableTableManager($_db, $_db.playlists)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ChannelsTableFilterComposer
    extends Composer<_$AppDatabase, $ChannelsTable> {
  $$ChannelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get rowId => $composableBuilder(
      column: $table.rowId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get channelId => $composableBuilder(
      column: $table.channelId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupTitle => $composableBuilder(
      column: $table.groupTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get logoUrl => $composableBuilder(
      column: $table.logoUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get epgId => $composableBuilder(
      column: $table.epgId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRadio => $composableBuilder(
      column: $table.isRadio, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get number => $composableBuilder(
      column: $table.number, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get catchupType => $composableBuilder(
      column: $table.catchupType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get catchupSource => $composableBuilder(
      column: $table.catchupSource, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get catchupDays => $composableBuilder(
      column: $table.catchupDays, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get catchupCorrection => $composableBuilder(
      column: $table.catchupCorrection,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get extraJson => $composableBuilder(
      column: $table.extraJson, builder: (column) => ColumnFilters(column));

  $$PlaylistsTableFilterComposer get sourceId {
    final $$PlaylistsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sourceId,
        referencedTable: $db.playlists,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlaylistsTableFilterComposer(
              $db: $db,
              $table: $db.playlists,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ChannelsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChannelsTable> {
  $$ChannelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get rowId => $composableBuilder(
      column: $table.rowId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get channelId => $composableBuilder(
      column: $table.channelId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupTitle => $composableBuilder(
      column: $table.groupTitle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get logoUrl => $composableBuilder(
      column: $table.logoUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get epgId => $composableBuilder(
      column: $table.epgId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRadio => $composableBuilder(
      column: $table.isRadio, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get number => $composableBuilder(
      column: $table.number, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get catchupType => $composableBuilder(
      column: $table.catchupType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get catchupSource => $composableBuilder(
      column: $table.catchupSource,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get catchupDays => $composableBuilder(
      column: $table.catchupDays, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get catchupCorrection => $composableBuilder(
      column: $table.catchupCorrection,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get extraJson => $composableBuilder(
      column: $table.extraJson, builder: (column) => ColumnOrderings(column));

  $$PlaylistsTableOrderingComposer get sourceId {
    final $$PlaylistsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sourceId,
        referencedTable: $db.playlists,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlaylistsTableOrderingComposer(
              $db: $db,
              $table: $db.playlists,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ChannelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChannelsTable> {
  $$ChannelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => column);

  GeneratedColumn<String> get channelId =>
      $composableBuilder(column: $table.channelId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get groupTitle => $composableBuilder(
      column: $table.groupTitle, builder: (column) => column);

  GeneratedColumn<String> get logoUrl =>
      $composableBuilder(column: $table.logoUrl, builder: (column) => column);

  GeneratedColumn<String> get epgId =>
      $composableBuilder(column: $table.epgId, builder: (column) => column);

  GeneratedColumn<bool> get isRadio =>
      $composableBuilder(column: $table.isRadio, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get catchupType => $composableBuilder(
      column: $table.catchupType, builder: (column) => column);

  GeneratedColumn<String> get catchupSource => $composableBuilder(
      column: $table.catchupSource, builder: (column) => column);

  GeneratedColumn<int> get catchupDays => $composableBuilder(
      column: $table.catchupDays, builder: (column) => column);

  GeneratedColumn<int> get catchupCorrection => $composableBuilder(
      column: $table.catchupCorrection, builder: (column) => column);

  GeneratedColumn<String> get extraJson =>
      $composableBuilder(column: $table.extraJson, builder: (column) => column);

  $$PlaylistsTableAnnotationComposer get sourceId {
    final $$PlaylistsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sourceId,
        referencedTable: $db.playlists,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlaylistsTableAnnotationComposer(
              $db: $db,
              $table: $db.playlists,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ChannelsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChannelsTable,
    Channel,
    $$ChannelsTableFilterComposer,
    $$ChannelsTableOrderingComposer,
    $$ChannelsTableAnnotationComposer,
    $$ChannelsTableCreateCompanionBuilder,
    $$ChannelsTableUpdateCompanionBuilder,
    (Channel, $$ChannelsTableReferences),
    Channel,
    PrefetchHooks Function({bool sourceId})> {
  $$ChannelsTableTableManager(_$AppDatabase db, $ChannelsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChannelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChannelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChannelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> rowId = const Value.absent(),
            Value<int> sourceId = const Value.absent(),
            Value<String> channelId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> url = const Value.absent(),
            Value<String?> groupTitle = const Value.absent(),
            Value<String?> logoUrl = const Value.absent(),
            Value<String?> epgId = const Value.absent(),
            Value<bool> isRadio = const Value.absent(),
            Value<int?> number = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<int> catchupType = const Value.absent(),
            Value<String?> catchupSource = const Value.absent(),
            Value<int> catchupDays = const Value.absent(),
            Value<int> catchupCorrection = const Value.absent(),
            Value<String> extraJson = const Value.absent(),
          }) =>
              ChannelsCompanion(
            rowId: rowId,
            sourceId: sourceId,
            channelId: channelId,
            name: name,
            url: url,
            groupTitle: groupTitle,
            logoUrl: logoUrl,
            epgId: epgId,
            isRadio: isRadio,
            number: number,
            position: position,
            catchupType: catchupType,
            catchupSource: catchupSource,
            catchupDays: catchupDays,
            catchupCorrection: catchupCorrection,
            extraJson: extraJson,
          ),
          createCompanionCallback: ({
            Value<int> rowId = const Value.absent(),
            required int sourceId,
            required String channelId,
            required String name,
            required String url,
            Value<String?> groupTitle = const Value.absent(),
            Value<String?> logoUrl = const Value.absent(),
            Value<String?> epgId = const Value.absent(),
            Value<bool> isRadio = const Value.absent(),
            Value<int?> number = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<int> catchupType = const Value.absent(),
            Value<String?> catchupSource = const Value.absent(),
            Value<int> catchupDays = const Value.absent(),
            Value<int> catchupCorrection = const Value.absent(),
            Value<String> extraJson = const Value.absent(),
          }) =>
              ChannelsCompanion.insert(
            rowId: rowId,
            sourceId: sourceId,
            channelId: channelId,
            name: name,
            url: url,
            groupTitle: groupTitle,
            logoUrl: logoUrl,
            epgId: epgId,
            isRadio: isRadio,
            number: number,
            position: position,
            catchupType: catchupType,
            catchupSource: catchupSource,
            catchupDays: catchupDays,
            catchupCorrection: catchupCorrection,
            extraJson: extraJson,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ChannelsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({sourceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (sourceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sourceId,
                    referencedTable:
                        $$ChannelsTableReferences._sourceIdTable(db),
                    referencedColumn:
                        $$ChannelsTableReferences._sourceIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ChannelsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChannelsTable,
    Channel,
    $$ChannelsTableFilterComposer,
    $$ChannelsTableOrderingComposer,
    $$ChannelsTableAnnotationComposer,
    $$ChannelsTableCreateCompanionBuilder,
    $$ChannelsTableUpdateCompanionBuilder,
    (Channel, $$ChannelsTableReferences),
    Channel,
    PrefetchHooks Function({bool sourceId})>;
typedef $$EpgChannelsTableCreateCompanionBuilder = EpgChannelsCompanion
    Function({
  required String id,
  required String displayName,
  Value<String?> icon,
  Value<int> rowid,
});
typedef $$EpgChannelsTableUpdateCompanionBuilder = EpgChannelsCompanion
    Function({
  Value<String> id,
  Value<String> displayName,
  Value<String?> icon,
  Value<int> rowid,
});

class $$EpgChannelsTableFilterComposer
    extends Composer<_$AppDatabase, $EpgChannelsTable> {
  $$EpgChannelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));
}

class $$EpgChannelsTableOrderingComposer
    extends Composer<_$AppDatabase, $EpgChannelsTable> {
  $$EpgChannelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));
}

class $$EpgChannelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EpgChannelsTable> {
  $$EpgChannelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);
}

class $$EpgChannelsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EpgChannelsTable,
    EpgChannel,
    $$EpgChannelsTableFilterComposer,
    $$EpgChannelsTableOrderingComposer,
    $$EpgChannelsTableAnnotationComposer,
    $$EpgChannelsTableCreateCompanionBuilder,
    $$EpgChannelsTableUpdateCompanionBuilder,
    (EpgChannel, BaseReferences<_$AppDatabase, $EpgChannelsTable, EpgChannel>),
    EpgChannel,
    PrefetchHooks Function()> {
  $$EpgChannelsTableTableManager(_$AppDatabase db, $EpgChannelsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EpgChannelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EpgChannelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EpgChannelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<String?> icon = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EpgChannelsCompanion(
            id: id,
            displayName: displayName,
            icon: icon,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String displayName,
            Value<String?> icon = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EpgChannelsCompanion.insert(
            id: id,
            displayName: displayName,
            icon: icon,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$EpgChannelsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EpgChannelsTable,
    EpgChannel,
    $$EpgChannelsTableFilterComposer,
    $$EpgChannelsTableOrderingComposer,
    $$EpgChannelsTableAnnotationComposer,
    $$EpgChannelsTableCreateCompanionBuilder,
    $$EpgChannelsTableUpdateCompanionBuilder,
    (EpgChannel, BaseReferences<_$AppDatabase, $EpgChannelsTable, EpgChannel>),
    EpgChannel,
    PrefetchHooks Function()>;
typedef $$EpgProgrammesTableCreateCompanionBuilder = EpgProgrammesCompanion
    Function({
  Value<int> rowId,
  required String channelId,
  required int startUtc,
  required int stopUtc,
  required String title,
  Value<String?> description,
  Value<String?> category,
});
typedef $$EpgProgrammesTableUpdateCompanionBuilder = EpgProgrammesCompanion
    Function({
  Value<int> rowId,
  Value<String> channelId,
  Value<int> startUtc,
  Value<int> stopUtc,
  Value<String> title,
  Value<String?> description,
  Value<String?> category,
});

class $$EpgProgrammesTableFilterComposer
    extends Composer<_$AppDatabase, $EpgProgrammesTable> {
  $$EpgProgrammesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get rowId => $composableBuilder(
      column: $table.rowId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get channelId => $composableBuilder(
      column: $table.channelId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startUtc => $composableBuilder(
      column: $table.startUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stopUtc => $composableBuilder(
      column: $table.stopUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));
}

class $$EpgProgrammesTableOrderingComposer
    extends Composer<_$AppDatabase, $EpgProgrammesTable> {
  $$EpgProgrammesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get rowId => $composableBuilder(
      column: $table.rowId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get channelId => $composableBuilder(
      column: $table.channelId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startUtc => $composableBuilder(
      column: $table.startUtc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stopUtc => $composableBuilder(
      column: $table.stopUtc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));
}

class $$EpgProgrammesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EpgProgrammesTable> {
  $$EpgProgrammesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => column);

  GeneratedColumn<String> get channelId =>
      $composableBuilder(column: $table.channelId, builder: (column) => column);

  GeneratedColumn<int> get startUtc =>
      $composableBuilder(column: $table.startUtc, builder: (column) => column);

  GeneratedColumn<int> get stopUtc =>
      $composableBuilder(column: $table.stopUtc, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);
}

class $$EpgProgrammesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EpgProgrammesTable,
    EpgProgramme,
    $$EpgProgrammesTableFilterComposer,
    $$EpgProgrammesTableOrderingComposer,
    $$EpgProgrammesTableAnnotationComposer,
    $$EpgProgrammesTableCreateCompanionBuilder,
    $$EpgProgrammesTableUpdateCompanionBuilder,
    (
      EpgProgramme,
      BaseReferences<_$AppDatabase, $EpgProgrammesTable, EpgProgramme>
    ),
    EpgProgramme,
    PrefetchHooks Function()> {
  $$EpgProgrammesTableTableManager(_$AppDatabase db, $EpgProgrammesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EpgProgrammesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EpgProgrammesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EpgProgrammesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> rowId = const Value.absent(),
            Value<String> channelId = const Value.absent(),
            Value<int> startUtc = const Value.absent(),
            Value<int> stopUtc = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> category = const Value.absent(),
          }) =>
              EpgProgrammesCompanion(
            rowId: rowId,
            channelId: channelId,
            startUtc: startUtc,
            stopUtc: stopUtc,
            title: title,
            description: description,
            category: category,
          ),
          createCompanionCallback: ({
            Value<int> rowId = const Value.absent(),
            required String channelId,
            required int startUtc,
            required int stopUtc,
            required String title,
            Value<String?> description = const Value.absent(),
            Value<String?> category = const Value.absent(),
          }) =>
              EpgProgrammesCompanion.insert(
            rowId: rowId,
            channelId: channelId,
            startUtc: startUtc,
            stopUtc: stopUtc,
            title: title,
            description: description,
            category: category,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$EpgProgrammesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EpgProgrammesTable,
    EpgProgramme,
    $$EpgProgrammesTableFilterComposer,
    $$EpgProgrammesTableOrderingComposer,
    $$EpgProgrammesTableAnnotationComposer,
    $$EpgProgrammesTableCreateCompanionBuilder,
    $$EpgProgrammesTableUpdateCompanionBuilder,
    (
      EpgProgramme,
      BaseReferences<_$AppDatabase, $EpgProgrammesTable, EpgProgramme>
    ),
    EpgProgramme,
    PrefetchHooks Function()>;
typedef $$VodEntriesTableCreateCompanionBuilder = VodEntriesCompanion Function({
  Value<int> rowId,
  required int sourceId,
  required String entryId,
  required String kind,
  required String title,
  Value<String?> cover,
  Value<String?> categoryId,
  Value<String?> categoryName,
  Value<String?> plot,
  Value<String?> rating,
  Value<String?> year,
  Value<String?> url,
  Value<int> position,
});
typedef $$VodEntriesTableUpdateCompanionBuilder = VodEntriesCompanion Function({
  Value<int> rowId,
  Value<int> sourceId,
  Value<String> entryId,
  Value<String> kind,
  Value<String> title,
  Value<String?> cover,
  Value<String?> categoryId,
  Value<String?> categoryName,
  Value<String?> plot,
  Value<String?> rating,
  Value<String?> year,
  Value<String?> url,
  Value<int> position,
});

final class $$VodEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $VodEntriesTable, VodEntry> {
  $$VodEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlaylistsTable _sourceIdTable(_$AppDatabase db) =>
      db.playlists.createAlias(
          $_aliasNameGenerator(db.vodEntries.sourceId, db.playlists.id));

  $$PlaylistsTableProcessedTableManager get sourceId {
    final $_column = $_itemColumn<int>('source_id')!;

    final manager = $$PlaylistsTableTableManager($_db, $_db.playlists)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$VodEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $VodEntriesTable> {
  $$VodEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get rowId => $composableBuilder(
      column: $table.rowId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entryId => $composableBuilder(
      column: $table.entryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cover => $composableBuilder(
      column: $table.cover, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryName => $composableBuilder(
      column: $table.categoryName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get plot => $composableBuilder(
      column: $table.plot, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnFilters(column));

  $$PlaylistsTableFilterComposer get sourceId {
    final $$PlaylistsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sourceId,
        referencedTable: $db.playlists,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlaylistsTableFilterComposer(
              $db: $db,
              $table: $db.playlists,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VodEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $VodEntriesTable> {
  $$VodEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get rowId => $composableBuilder(
      column: $table.rowId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entryId => $composableBuilder(
      column: $table.entryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cover => $composableBuilder(
      column: $table.cover, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryName => $composableBuilder(
      column: $table.categoryName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get plot => $composableBuilder(
      column: $table.plot, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnOrderings(column));

  $$PlaylistsTableOrderingComposer get sourceId {
    final $$PlaylistsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sourceId,
        referencedTable: $db.playlists,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlaylistsTableOrderingComposer(
              $db: $db,
              $table: $db.playlists,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VodEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VodEntriesTable> {
  $$VodEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => column);

  GeneratedColumn<String> get entryId =>
      $composableBuilder(column: $table.entryId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get cover =>
      $composableBuilder(column: $table.cover, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<String> get categoryName => $composableBuilder(
      column: $table.categoryName, builder: (column) => column);

  GeneratedColumn<String> get plot =>
      $composableBuilder(column: $table.plot, builder: (column) => column);

  GeneratedColumn<String> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$PlaylistsTableAnnotationComposer get sourceId {
    final $$PlaylistsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sourceId,
        referencedTable: $db.playlists,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlaylistsTableAnnotationComposer(
              $db: $db,
              $table: $db.playlists,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VodEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VodEntriesTable,
    VodEntry,
    $$VodEntriesTableFilterComposer,
    $$VodEntriesTableOrderingComposer,
    $$VodEntriesTableAnnotationComposer,
    $$VodEntriesTableCreateCompanionBuilder,
    $$VodEntriesTableUpdateCompanionBuilder,
    (VodEntry, $$VodEntriesTableReferences),
    VodEntry,
    PrefetchHooks Function({bool sourceId})> {
  $$VodEntriesTableTableManager(_$AppDatabase db, $VodEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VodEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VodEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VodEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> rowId = const Value.absent(),
            Value<int> sourceId = const Value.absent(),
            Value<String> entryId = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> cover = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<String?> categoryName = const Value.absent(),
            Value<String?> plot = const Value.absent(),
            Value<String?> rating = const Value.absent(),
            Value<String?> year = const Value.absent(),
            Value<String?> url = const Value.absent(),
            Value<int> position = const Value.absent(),
          }) =>
              VodEntriesCompanion(
            rowId: rowId,
            sourceId: sourceId,
            entryId: entryId,
            kind: kind,
            title: title,
            cover: cover,
            categoryId: categoryId,
            categoryName: categoryName,
            plot: plot,
            rating: rating,
            year: year,
            url: url,
            position: position,
          ),
          createCompanionCallback: ({
            Value<int> rowId = const Value.absent(),
            required int sourceId,
            required String entryId,
            required String kind,
            required String title,
            Value<String?> cover = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<String?> categoryName = const Value.absent(),
            Value<String?> plot = const Value.absent(),
            Value<String?> rating = const Value.absent(),
            Value<String?> year = const Value.absent(),
            Value<String?> url = const Value.absent(),
            Value<int> position = const Value.absent(),
          }) =>
              VodEntriesCompanion.insert(
            rowId: rowId,
            sourceId: sourceId,
            entryId: entryId,
            kind: kind,
            title: title,
            cover: cover,
            categoryId: categoryId,
            categoryName: categoryName,
            plot: plot,
            rating: rating,
            year: year,
            url: url,
            position: position,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$VodEntriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({sourceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (sourceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sourceId,
                    referencedTable:
                        $$VodEntriesTableReferences._sourceIdTable(db),
                    referencedColumn:
                        $$VodEntriesTableReferences._sourceIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$VodEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VodEntriesTable,
    VodEntry,
    $$VodEntriesTableFilterComposer,
    $$VodEntriesTableOrderingComposer,
    $$VodEntriesTableAnnotationComposer,
    $$VodEntriesTableCreateCompanionBuilder,
    $$VodEntriesTableUpdateCompanionBuilder,
    (VodEntry, $$VodEntriesTableReferences),
    VodEntry,
    PrefetchHooks Function({bool sourceId})>;
typedef $$ScheduledTasksTableCreateCompanionBuilder = ScheduledTasksCompanion
    Function({
  Value<int> id,
  required String kind,
  required int fireAtUtc,
  Value<int?> endAtUtc,
  Value<String> recurrence,
  Value<int?> sourceId,
  Value<String?> channelId,
  Value<String?> channelName,
  Value<String?> channelUrl,
  Value<String?> title,
  Value<bool> enabled,
});
typedef $$ScheduledTasksTableUpdateCompanionBuilder = ScheduledTasksCompanion
    Function({
  Value<int> id,
  Value<String> kind,
  Value<int> fireAtUtc,
  Value<int?> endAtUtc,
  Value<String> recurrence,
  Value<int?> sourceId,
  Value<String?> channelId,
  Value<String?> channelName,
  Value<String?> channelUrl,
  Value<String?> title,
  Value<bool> enabled,
});

class $$ScheduledTasksTableFilterComposer
    extends Composer<_$AppDatabase, $ScheduledTasksTable> {
  $$ScheduledTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fireAtUtc => $composableBuilder(
      column: $table.fireAtUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endAtUtc => $composableBuilder(
      column: $table.endAtUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recurrence => $composableBuilder(
      column: $table.recurrence, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get channelId => $composableBuilder(
      column: $table.channelId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get channelName => $composableBuilder(
      column: $table.channelName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get channelUrl => $composableBuilder(
      column: $table.channelUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnFilters(column));
}

class $$ScheduledTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $ScheduledTasksTable> {
  $$ScheduledTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fireAtUtc => $composableBuilder(
      column: $table.fireAtUtc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endAtUtc => $composableBuilder(
      column: $table.endAtUtc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recurrence => $composableBuilder(
      column: $table.recurrence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get channelId => $composableBuilder(
      column: $table.channelId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get channelName => $composableBuilder(
      column: $table.channelName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get channelUrl => $composableBuilder(
      column: $table.channelUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnOrderings(column));
}

class $$ScheduledTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScheduledTasksTable> {
  $$ScheduledTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get fireAtUtc =>
      $composableBuilder(column: $table.fireAtUtc, builder: (column) => column);

  GeneratedColumn<int> get endAtUtc =>
      $composableBuilder(column: $table.endAtUtc, builder: (column) => column);

  GeneratedColumn<String> get recurrence => $composableBuilder(
      column: $table.recurrence, builder: (column) => column);

  GeneratedColumn<int> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get channelId =>
      $composableBuilder(column: $table.channelId, builder: (column) => column);

  GeneratedColumn<String> get channelName => $composableBuilder(
      column: $table.channelName, builder: (column) => column);

  GeneratedColumn<String> get channelUrl => $composableBuilder(
      column: $table.channelUrl, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);
}

class $$ScheduledTasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ScheduledTasksTable,
    ScheduledTask,
    $$ScheduledTasksTableFilterComposer,
    $$ScheduledTasksTableOrderingComposer,
    $$ScheduledTasksTableAnnotationComposer,
    $$ScheduledTasksTableCreateCompanionBuilder,
    $$ScheduledTasksTableUpdateCompanionBuilder,
    (
      ScheduledTask,
      BaseReferences<_$AppDatabase, $ScheduledTasksTable, ScheduledTask>
    ),
    ScheduledTask,
    PrefetchHooks Function()> {
  $$ScheduledTasksTableTableManager(
      _$AppDatabase db, $ScheduledTasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduledTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScheduledTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScheduledTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<int> fireAtUtc = const Value.absent(),
            Value<int?> endAtUtc = const Value.absent(),
            Value<String> recurrence = const Value.absent(),
            Value<int?> sourceId = const Value.absent(),
            Value<String?> channelId = const Value.absent(),
            Value<String?> channelName = const Value.absent(),
            Value<String?> channelUrl = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<bool> enabled = const Value.absent(),
          }) =>
              ScheduledTasksCompanion(
            id: id,
            kind: kind,
            fireAtUtc: fireAtUtc,
            endAtUtc: endAtUtc,
            recurrence: recurrence,
            sourceId: sourceId,
            channelId: channelId,
            channelName: channelName,
            channelUrl: channelUrl,
            title: title,
            enabled: enabled,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String kind,
            required int fireAtUtc,
            Value<int?> endAtUtc = const Value.absent(),
            Value<String> recurrence = const Value.absent(),
            Value<int?> sourceId = const Value.absent(),
            Value<String?> channelId = const Value.absent(),
            Value<String?> channelName = const Value.absent(),
            Value<String?> channelUrl = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<bool> enabled = const Value.absent(),
          }) =>
              ScheduledTasksCompanion.insert(
            id: id,
            kind: kind,
            fireAtUtc: fireAtUtc,
            endAtUtc: endAtUtc,
            recurrence: recurrence,
            sourceId: sourceId,
            channelId: channelId,
            channelName: channelName,
            channelUrl: channelUrl,
            title: title,
            enabled: enabled,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ScheduledTasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ScheduledTasksTable,
    ScheduledTask,
    $$ScheduledTasksTableFilterComposer,
    $$ScheduledTasksTableOrderingComposer,
    $$ScheduledTasksTableAnnotationComposer,
    $$ScheduledTasksTableCreateCompanionBuilder,
    $$ScheduledTasksTableUpdateCompanionBuilder,
    (
      ScheduledTask,
      BaseReferences<_$AppDatabase, $ScheduledTasksTable, ScheduledTask>
    ),
    ScheduledTask,
    PrefetchHooks Function()>;
typedef $$FavoritesTableCreateCompanionBuilder = FavoritesCompanion Function({
  required String refId,
  required String kind,
  Value<int?> sourceId,
  required String title,
  Value<String?> subtitle,
  Value<String?> imageUrl,
  Value<String?> playUrl,
  Value<DateTime> addedAt,
  Value<int> rowid,
});
typedef $$FavoritesTableUpdateCompanionBuilder = FavoritesCompanion Function({
  Value<String> refId,
  Value<String> kind,
  Value<int?> sourceId,
  Value<String> title,
  Value<String?> subtitle,
  Value<String?> imageUrl,
  Value<String?> playUrl,
  Value<DateTime> addedAt,
  Value<int> rowid,
});

class $$FavoritesTableFilterComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get refId => $composableBuilder(
      column: $table.refId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subtitle => $composableBuilder(
      column: $table.subtitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get playUrl => $composableBuilder(
      column: $table.playUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnFilters(column));
}

class $$FavoritesTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get refId => $composableBuilder(
      column: $table.refId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subtitle => $composableBuilder(
      column: $table.subtitle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get playUrl => $composableBuilder(
      column: $table.playUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnOrderings(column));
}

class $$FavoritesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get refId =>
      $composableBuilder(column: $table.refId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get subtitle =>
      $composableBuilder(column: $table.subtitle, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get playUrl =>
      $composableBuilder(column: $table.playUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$FavoritesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FavoritesTable,
    Favorite,
    $$FavoritesTableFilterComposer,
    $$FavoritesTableOrderingComposer,
    $$FavoritesTableAnnotationComposer,
    $$FavoritesTableCreateCompanionBuilder,
    $$FavoritesTableUpdateCompanionBuilder,
    (Favorite, BaseReferences<_$AppDatabase, $FavoritesTable, Favorite>),
    Favorite,
    PrefetchHooks Function()> {
  $$FavoritesTableTableManager(_$AppDatabase db, $FavoritesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoritesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> refId = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<int?> sourceId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> subtitle = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<String?> playUrl = const Value.absent(),
            Value<DateTime> addedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FavoritesCompanion(
            refId: refId,
            kind: kind,
            sourceId: sourceId,
            title: title,
            subtitle: subtitle,
            imageUrl: imageUrl,
            playUrl: playUrl,
            addedAt: addedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String refId,
            required String kind,
            Value<int?> sourceId = const Value.absent(),
            required String title,
            Value<String?> subtitle = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<String?> playUrl = const Value.absent(),
            Value<DateTime> addedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FavoritesCompanion.insert(
            refId: refId,
            kind: kind,
            sourceId: sourceId,
            title: title,
            subtitle: subtitle,
            imageUrl: imageUrl,
            playUrl: playUrl,
            addedAt: addedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FavoritesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FavoritesTable,
    Favorite,
    $$FavoritesTableFilterComposer,
    $$FavoritesTableOrderingComposer,
    $$FavoritesTableAnnotationComposer,
    $$FavoritesTableCreateCompanionBuilder,
    $$FavoritesTableUpdateCompanionBuilder,
    (Favorite, BaseReferences<_$AppDatabase, $FavoritesTable, Favorite>),
    Favorite,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PlaylistsTableTableManager get playlists =>
      $$PlaylistsTableTableManager(_db, _db.playlists);
  $$ChannelsTableTableManager get channels =>
      $$ChannelsTableTableManager(_db, _db.channels);
  $$EpgChannelsTableTableManager get epgChannels =>
      $$EpgChannelsTableTableManager(_db, _db.epgChannels);
  $$EpgProgrammesTableTableManager get epgProgrammes =>
      $$EpgProgrammesTableTableManager(_db, _db.epgProgrammes);
  $$VodEntriesTableTableManager get vodEntries =>
      $$VodEntriesTableTableManager(_db, _db.vodEntries);
  $$ScheduledTasksTableTableManager get scheduledTasks =>
      $$ScheduledTasksTableTableManager(_db, _db.scheduledTasks);
  $$FavoritesTableTableManager get favorites =>
      $$FavoritesTableTableManager(_db, _db.favorites);
}
