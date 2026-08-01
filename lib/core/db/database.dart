import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:nuvclip/core/platform/download_engine.g.dart';

part 'database.g.dart';

/// Un video ya guardado en el dispositivo (pantalla Historial, seccion 4).
/// Solo se persiste metadata: el archivo real vive en MediaStore, referido
/// por [savedUri].
class HistoryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// El mismo id que uso el motor nativo para esta descarga; sirve para
  /// enlazar un `onDownloadCompleted` que llega tarde con la fila creada de
  /// forma optimista al iniciar la descarga.
  TextColumn get downloadId => text().unique()();
  TextColumn get sourceUrl => text()();
  IntColumn get platform => intEnum<SourcePlatform>()();
  TextColumn get title => text()();
  TextColumn get fileName => text()();

  /// content:// de MediaStore; se usa para abrir, compartir y borrar.
  TextColumn get savedUri => text()();
  TextColumn get thumbnailUrl => text().nullable()();
  IntColumn get sizeBytes => integer().withDefault(const Constant(0))();
  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();
  DateTimeColumn get downloadedAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [HistoryEntries])
class NuvClipDatabase extends _$NuvClipDatabase {
  NuvClipDatabase() : super(_openConnection());

  NuvClipDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() => driftDatabase(name: 'nuvclip');
}
