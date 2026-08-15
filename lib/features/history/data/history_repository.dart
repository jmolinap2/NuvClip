import 'package:drift/drift.dart';
import 'package:nuvclip/core/db/database.dart';
import 'package:nuvclip/core/platform/download_engine.g.dart';

class HistoryStats {
  const HistoryStats({required this.count, required this.totalBytes});

  final int count;
  final int totalBytes;
}

/// Filtro de plataforma del historial (chips "Todos / TikTok / Instagram / Facebook / YouTube").
enum HistoryFilter { all, tiktok, instagram, facebook, youtube }

class HistoryRepository {
  const HistoryRepository(this._db);

  final NuvClipDatabase _db;

  /// Fila optimista creada al iniciar la descarga, para que el historial ya
  /// la muestre "en curso" en vez de aparecer recien al terminar.
  Future<void> recordStarted({
    required String downloadId,
    required String sourceUrl,
    required SourcePlatform platform,
    required String title,
    required String fileName,
    String? thumbnailUrl,
    required int durationSeconds,
  }) async {
    await _db.into(_db.historyEntries).insertOnConflictUpdate(
          HistoryEntriesCompanion.insert(
            downloadId: downloadId,
            sourceUrl: sourceUrl,
            platform: platform,
            title: title,
            fileName: fileName,
            savedUri: '',
            thumbnailUrl: Value(thumbnailUrl),
            durationSeconds: Value(durationSeconds),
          ),
        );
  }

  Future<void> recordCompleted({
    required String downloadId,
    required String savedUri,
    required String fileName,
    required int sizeBytes,
  }) async {
    await (_db.update(_db.historyEntries)..where((t) => t.downloadId.equals(downloadId))).write(
      HistoryEntriesCompanion(
        savedUri: Value(savedUri),
        fileName: Value(fileName),
        sizeBytes: Value(sizeBytes),
      ),
    );
  }

  /// Una descarga que fallo o se cancelo no debe dejar un registro
  /// "fantasma" a medio llenar en el historial.
  Future<void> discardStarted(String downloadId) async {
    await (_db.delete(_db.historyEntries)..where((t) => t.downloadId.equals(downloadId))).go();
  }

  Future<void> removeFromHistory(int id) async {
    await (_db.delete(_db.historyEntries)..where((t) => t.id.equals(id))).go();
  }

  Future<void> clearAll() => _db.delete(_db.historyEntries).go();

  Stream<List<HistoryEntry>> watchEntries({HistoryFilter filter = HistoryFilter.all, String query = ''}) {
    final select = _db.select(_db.historyEntries)
      ..where((t) => t.savedUri.equals('').not())
      ..orderBy([(t) => OrderingTerm.desc(t.downloadedAt)]);

    if (filter == HistoryFilter.tiktok) {
      select.where((t) => t.platform.equalsValue(SourcePlatform.tiktok));
    } else if (filter == HistoryFilter.instagram) {
      select.where((t) => t.platform.equalsValue(SourcePlatform.instagram));
    } else if (filter == HistoryFilter.facebook) {
      select.where((t) => t.platform.equalsValue(SourcePlatform.facebook));
    } else if (filter == HistoryFilter.youtube) {
      select.where((t) => t.platform.equalsValue(SourcePlatform.youtube));
    }
    if (query.trim().isNotEmpty) {
      select.where((t) => t.fileName.like('%${query.trim()}%'));
    }
    return select.watch();
  }

  Stream<HistoryStats> watchStats() {
    final countExp = _db.historyEntries.id.count();
    final sizeExp = _db.historyEntries.sizeBytes.sum();
    final query = _db.selectOnly(_db.historyEntries)
      ..addColumns([countExp, sizeExp])
      ..where(_db.historyEntries.savedUri.equals('').not());
    return query.map((row) {
      return HistoryStats(
        count: row.read(countExp) ?? 0,
        totalBytes: row.read(sizeExp) ?? 0,
      );
    }).watchSingle();
  }
}
