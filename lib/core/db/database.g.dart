// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $HistoryEntriesTable extends HistoryEntries
    with TableInfo<$HistoryEntriesTable, HistoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _downloadIdMeta = const VerificationMeta(
    'downloadId',
  );
  @override
  late final GeneratedColumn<String> downloadId = GeneratedColumn<String>(
    'download_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SourcePlatform, int> platform =
      GeneratedColumn<int>(
        'platform',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<SourcePlatform>($HistoryEntriesTable.$converterplatform);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savedUriMeta = const VerificationMeta(
    'savedUri',
  );
  @override
  late final GeneratedColumn<String> savedUri = GeneratedColumn<String>(
    'saved_uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thumbnailUrlMeta = const VerificationMeta(
    'thumbnailUrl',
  );
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
    'thumbnail_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
    'downloaded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    downloadId,
    sourceUrl,
    platform,
    title,
    fileName,
    savedUri,
    thumbnailUrl,
    sizeBytes,
    durationSeconds,
    downloadedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'history_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<HistoryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('download_id')) {
      context.handle(
        _downloadIdMeta,
        downloadId.isAcceptableOrUnknown(data['download_id']!, _downloadIdMeta),
      );
    } else if (isInserting) {
      context.missing(_downloadIdMeta);
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceUrlMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('saved_uri')) {
      context.handle(
        _savedUriMeta,
        savedUri.isAcceptableOrUnknown(data['saved_uri']!, _savedUriMeta),
      );
    } else if (isInserting) {
      context.missing(_savedUriMeta);
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(
        _thumbnailUrlMeta,
        thumbnailUrl.isAcceptableOrUnknown(
          data['thumbnail_url']!,
          _thumbnailUrlMeta,
        ),
      );
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HistoryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistoryEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      downloadId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}download_id'],
      )!,
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      )!,
      platform: $HistoryEntriesTable.$converterplatform.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}platform'],
        )!,
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      savedUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}saved_uri'],
      )!,
      thumbnailUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_url'],
      ),
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      downloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}downloaded_at'],
      )!,
    );
  }

  @override
  $HistoryEntriesTable createAlias(String alias) {
    return $HistoryEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SourcePlatform, int, int> $converterplatform =
      const EnumIndexConverter<SourcePlatform>(SourcePlatform.values);
}

class HistoryEntry extends DataClass implements Insertable<HistoryEntry> {
  final int id;

  /// El mismo id que uso el motor nativo para esta descarga; sirve para
  /// enlazar un `onDownloadCompleted` que llega tarde con la fila creada de
  /// forma optimista al iniciar la descarga.
  final String downloadId;
  final String sourceUrl;
  final SourcePlatform platform;
  final String title;
  final String fileName;

  /// content:// de MediaStore; se usa para abrir, compartir y borrar.
  final String savedUri;
  final String? thumbnailUrl;
  final int sizeBytes;
  final int durationSeconds;
  final DateTime downloadedAt;
  const HistoryEntry({
    required this.id,
    required this.downloadId,
    required this.sourceUrl,
    required this.platform,
    required this.title,
    required this.fileName,
    required this.savedUri,
    this.thumbnailUrl,
    required this.sizeBytes,
    required this.durationSeconds,
    required this.downloadedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['download_id'] = Variable<String>(downloadId);
    map['source_url'] = Variable<String>(sourceUrl);
    {
      map['platform'] = Variable<int>(
        $HistoryEntriesTable.$converterplatform.toSql(platform),
      );
    }
    map['title'] = Variable<String>(title);
    map['file_name'] = Variable<String>(fileName);
    map['saved_uri'] = Variable<String>(savedUri);
    if (!nullToAbsent || thumbnailUrl != null) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    }
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    return map;
  }

  HistoryEntriesCompanion toCompanion(bool nullToAbsent) {
    return HistoryEntriesCompanion(
      id: Value(id),
      downloadId: Value(downloadId),
      sourceUrl: Value(sourceUrl),
      platform: Value(platform),
      title: Value(title),
      fileName: Value(fileName),
      savedUri: Value(savedUri),
      thumbnailUrl: thumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUrl),
      sizeBytes: Value(sizeBytes),
      durationSeconds: Value(durationSeconds),
      downloadedAt: Value(downloadedAt),
    );
  }

  factory HistoryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HistoryEntry(
      id: serializer.fromJson<int>(json['id']),
      downloadId: serializer.fromJson<String>(json['downloadId']),
      sourceUrl: serializer.fromJson<String>(json['sourceUrl']),
      platform: $HistoryEntriesTable.$converterplatform.fromJson(
        serializer.fromJson<int>(json['platform']),
      ),
      title: serializer.fromJson<String>(json['title']),
      fileName: serializer.fromJson<String>(json['fileName']),
      savedUri: serializer.fromJson<String>(json['savedUri']),
      thumbnailUrl: serializer.fromJson<String?>(json['thumbnailUrl']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      downloadedAt: serializer.fromJson<DateTime>(json['downloadedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'downloadId': serializer.toJson<String>(downloadId),
      'sourceUrl': serializer.toJson<String>(sourceUrl),
      'platform': serializer.toJson<int>(
        $HistoryEntriesTable.$converterplatform.toJson(platform),
      ),
      'title': serializer.toJson<String>(title),
      'fileName': serializer.toJson<String>(fileName),
      'savedUri': serializer.toJson<String>(savedUri),
      'thumbnailUrl': serializer.toJson<String?>(thumbnailUrl),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'downloadedAt': serializer.toJson<DateTime>(downloadedAt),
    };
  }

  HistoryEntry copyWith({
    int? id,
    String? downloadId,
    String? sourceUrl,
    SourcePlatform? platform,
    String? title,
    String? fileName,
    String? savedUri,
    Value<String?> thumbnailUrl = const Value.absent(),
    int? sizeBytes,
    int? durationSeconds,
    DateTime? downloadedAt,
  }) => HistoryEntry(
    id: id ?? this.id,
    downloadId: downloadId ?? this.downloadId,
    sourceUrl: sourceUrl ?? this.sourceUrl,
    platform: platform ?? this.platform,
    title: title ?? this.title,
    fileName: fileName ?? this.fileName,
    savedUri: savedUri ?? this.savedUri,
    thumbnailUrl: thumbnailUrl.present ? thumbnailUrl.value : this.thumbnailUrl,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    downloadedAt: downloadedAt ?? this.downloadedAt,
  );
  HistoryEntry copyWithCompanion(HistoryEntriesCompanion data) {
    return HistoryEntry(
      id: data.id.present ? data.id.value : this.id,
      downloadId: data.downloadId.present
          ? data.downloadId.value
          : this.downloadId,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      platform: data.platform.present ? data.platform.value : this.platform,
      title: data.title.present ? data.title.value : this.title,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      savedUri: data.savedUri.present ? data.savedUri.value : this.savedUri,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistoryEntry(')
          ..write('id: $id, ')
          ..write('downloadId: $downloadId, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('platform: $platform, ')
          ..write('title: $title, ')
          ..write('fileName: $fileName, ')
          ..write('savedUri: $savedUri, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('downloadedAt: $downloadedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    downloadId,
    sourceUrl,
    platform,
    title,
    fileName,
    savedUri,
    thumbnailUrl,
    sizeBytes,
    durationSeconds,
    downloadedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistoryEntry &&
          other.id == this.id &&
          other.downloadId == this.downloadId &&
          other.sourceUrl == this.sourceUrl &&
          other.platform == this.platform &&
          other.title == this.title &&
          other.fileName == this.fileName &&
          other.savedUri == this.savedUri &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.sizeBytes == this.sizeBytes &&
          other.durationSeconds == this.durationSeconds &&
          other.downloadedAt == this.downloadedAt);
}

class HistoryEntriesCompanion extends UpdateCompanion<HistoryEntry> {
  final Value<int> id;
  final Value<String> downloadId;
  final Value<String> sourceUrl;
  final Value<SourcePlatform> platform;
  final Value<String> title;
  final Value<String> fileName;
  final Value<String> savedUri;
  final Value<String?> thumbnailUrl;
  final Value<int> sizeBytes;
  final Value<int> durationSeconds;
  final Value<DateTime> downloadedAt;
  const HistoryEntriesCompanion({
    this.id = const Value.absent(),
    this.downloadId = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.platform = const Value.absent(),
    this.title = const Value.absent(),
    this.fileName = const Value.absent(),
    this.savedUri = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.downloadedAt = const Value.absent(),
  });
  HistoryEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String downloadId,
    required String sourceUrl,
    required SourcePlatform platform,
    required String title,
    required String fileName,
    required String savedUri,
    this.thumbnailUrl = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.downloadedAt = const Value.absent(),
  }) : downloadId = Value(downloadId),
       sourceUrl = Value(sourceUrl),
       platform = Value(platform),
       title = Value(title),
       fileName = Value(fileName),
       savedUri = Value(savedUri);
  static Insertable<HistoryEntry> custom({
    Expression<int>? id,
    Expression<String>? downloadId,
    Expression<String>? sourceUrl,
    Expression<int>? platform,
    Expression<String>? title,
    Expression<String>? fileName,
    Expression<String>? savedUri,
    Expression<String>? thumbnailUrl,
    Expression<int>? sizeBytes,
    Expression<int>? durationSeconds,
    Expression<DateTime>? downloadedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (downloadId != null) 'download_id': downloadId,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (platform != null) 'platform': platform,
      if (title != null) 'title': title,
      if (fileName != null) 'file_name': fileName,
      if (savedUri != null) 'saved_uri': savedUri,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
    });
  }

  HistoryEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? downloadId,
    Value<String>? sourceUrl,
    Value<SourcePlatform>? platform,
    Value<String>? title,
    Value<String>? fileName,
    Value<String>? savedUri,
    Value<String?>? thumbnailUrl,
    Value<int>? sizeBytes,
    Value<int>? durationSeconds,
    Value<DateTime>? downloadedAt,
  }) {
    return HistoryEntriesCompanion(
      id: id ?? this.id,
      downloadId: downloadId ?? this.downloadId,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      platform: platform ?? this.platform,
      title: title ?? this.title,
      fileName: fileName ?? this.fileName,
      savedUri: savedUri ?? this.savedUri,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      downloadedAt: downloadedAt ?? this.downloadedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (downloadId.present) {
      map['download_id'] = Variable<String>(downloadId.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (platform.present) {
      map['platform'] = Variable<int>(
        $HistoryEntriesTable.$converterplatform.toSql(platform.value),
      );
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (savedUri.present) {
      map['saved_uri'] = Variable<String>(savedUri.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('downloadId: $downloadId, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('platform: $platform, ')
          ..write('title: $title, ')
          ..write('fileName: $fileName, ')
          ..write('savedUri: $savedUri, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('downloadedAt: $downloadedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$NuvClipDatabase extends GeneratedDatabase {
  _$NuvClipDatabase(QueryExecutor e) : super(e);
  $NuvClipDatabaseManager get managers => $NuvClipDatabaseManager(this);
  late final $HistoryEntriesTable historyEntries = $HistoryEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [historyEntries];
}

typedef $$HistoryEntriesTableCreateCompanionBuilder =
    HistoryEntriesCompanion Function({
      Value<int> id,
      required String downloadId,
      required String sourceUrl,
      required SourcePlatform platform,
      required String title,
      required String fileName,
      required String savedUri,
      Value<String?> thumbnailUrl,
      Value<int> sizeBytes,
      Value<int> durationSeconds,
      Value<DateTime> downloadedAt,
    });
typedef $$HistoryEntriesTableUpdateCompanionBuilder =
    HistoryEntriesCompanion Function({
      Value<int> id,
      Value<String> downloadId,
      Value<String> sourceUrl,
      Value<SourcePlatform> platform,
      Value<String> title,
      Value<String> fileName,
      Value<String> savedUri,
      Value<String?> thumbnailUrl,
      Value<int> sizeBytes,
      Value<int> durationSeconds,
      Value<DateTime> downloadedAt,
    });

class $$HistoryEntriesTableFilterComposer
    extends Composer<_$NuvClipDatabase, $HistoryEntriesTable> {
  $$HistoryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get downloadId => $composableBuilder(
    column: $table.downloadId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SourcePlatform, SourcePlatform, int>
  get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get savedUri => $composableBuilder(
    column: $table.savedUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HistoryEntriesTableOrderingComposer
    extends Composer<_$NuvClipDatabase, $HistoryEntriesTable> {
  $$HistoryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get downloadId => $composableBuilder(
    column: $table.downloadId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get savedUri => $composableBuilder(
    column: $table.savedUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HistoryEntriesTableAnnotationComposer
    extends Composer<_$NuvClipDatabase, $HistoryEntriesTable> {
  $$HistoryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get downloadId => $composableBuilder(
    column: $table.downloadId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SourcePlatform, int> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get savedUri =>
      $composableBuilder(column: $table.savedUri, builder: (column) => column);

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );
}

class $$HistoryEntriesTableTableManager
    extends
        RootTableManager<
          _$NuvClipDatabase,
          $HistoryEntriesTable,
          HistoryEntry,
          $$HistoryEntriesTableFilterComposer,
          $$HistoryEntriesTableOrderingComposer,
          $$HistoryEntriesTableAnnotationComposer,
          $$HistoryEntriesTableCreateCompanionBuilder,
          $$HistoryEntriesTableUpdateCompanionBuilder,
          (
            HistoryEntry,
            BaseReferences<
              _$NuvClipDatabase,
              $HistoryEntriesTable,
              HistoryEntry
            >,
          ),
          HistoryEntry,
          PrefetchHooks Function()
        > {
  $$HistoryEntriesTableTableManager(
    _$NuvClipDatabase db,
    $HistoryEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HistoryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HistoryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HistoryEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> downloadId = const Value.absent(),
                Value<String> sourceUrl = const Value.absent(),
                Value<SourcePlatform> platform = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> savedUri = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<DateTime> downloadedAt = const Value.absent(),
              }) => HistoryEntriesCompanion(
                id: id,
                downloadId: downloadId,
                sourceUrl: sourceUrl,
                platform: platform,
                title: title,
                fileName: fileName,
                savedUri: savedUri,
                thumbnailUrl: thumbnailUrl,
                sizeBytes: sizeBytes,
                durationSeconds: durationSeconds,
                downloadedAt: downloadedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String downloadId,
                required String sourceUrl,
                required SourcePlatform platform,
                required String title,
                required String fileName,
                required String savedUri,
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<DateTime> downloadedAt = const Value.absent(),
              }) => HistoryEntriesCompanion.insert(
                id: id,
                downloadId: downloadId,
                sourceUrl: sourceUrl,
                platform: platform,
                title: title,
                fileName: fileName,
                savedUri: savedUri,
                thumbnailUrl: thumbnailUrl,
                sizeBytes: sizeBytes,
                durationSeconds: durationSeconds,
                downloadedAt: downloadedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HistoryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$NuvClipDatabase,
      $HistoryEntriesTable,
      HistoryEntry,
      $$HistoryEntriesTableFilterComposer,
      $$HistoryEntriesTableOrderingComposer,
      $$HistoryEntriesTableAnnotationComposer,
      $$HistoryEntriesTableCreateCompanionBuilder,
      $$HistoryEntriesTableUpdateCompanionBuilder,
      (
        HistoryEntry,
        BaseReferences<_$NuvClipDatabase, $HistoryEntriesTable, HistoryEntry>,
      ),
      HistoryEntry,
      PrefetchHooks Function()
    >;

class $NuvClipDatabaseManager {
  final _$NuvClipDatabase _db;
  $NuvClipDatabaseManager(this._db);
  $$HistoryEntriesTableTableManager get historyEntries =>
      $$HistoryEntriesTableTableManager(_db, _db.historyEntries);
}
