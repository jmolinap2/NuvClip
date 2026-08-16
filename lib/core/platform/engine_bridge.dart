import 'dart:async';

import 'package:nuvclip/core/platform/download_engine.g.dart';

export 'package:nuvclip/core/platform/download_engine.g.dart';

class DownloadProgressEvent {
  const DownloadProgressEvent({
    required this.downloadId,
    required this.percent,
    required this.etaSeconds,
    required this.downloadedBytes,
    required this.totalBytes,
  });

  final String downloadId;
  final double percent;
  final int? etaSeconds;
  final int downloadedBytes;
  final int? totalBytes;
}

class DownloadCompletedEvent {
  const DownloadCompletedEvent({
    required this.downloadId,
    required this.savedUri,
    required this.fileName,
    required this.sizeBytes,
  });

  final String downloadId;
  final String savedUri;
  final String fileName;
  final int sizeBytes;
}

class DownloadFailedEvent {
  const DownloadFailedEvent({
    required this.downloadId,
    required this.errorCode,
    required this.errorDetail,
  });

  final String downloadId;
  final DownloadErrorCode errorCode;
  final String? errorDetail;
}

/// Unico punto de contacto con el motor nativo. Traduce las llamadas
/// generadas por Pigeon a streams que los controladores de Riverpod pueden
/// escuchar sin acoplarse al canal de plataforma.
class EngineBridge extends DownloadEngineFlutterApi {
  EngineBridge() {
    DownloadEngineFlutterApi.setUp(this);
  }

  final _host = DownloadEngineHostApi();

  final _progress = StreamController<DownloadProgressEvent>.broadcast();
  final _completed = StreamController<DownloadCompletedEvent>.broadcast();
  final _failed = StreamController<DownloadFailedEvent>.broadcast();
  final _extractorUpdating = StreamController<void>.broadcast();

  Stream<DownloadProgressEvent> get onProgress => _progress.stream;
  Stream<DownloadCompletedEvent> get onCompleted => _completed.stream;
  Stream<DownloadFailedEvent> get onFailed => _failed.stream;

  /// Push transitorio de `analyzeUrl`: detecto un extractor desactualizado,
  /// va a actualizarlo y reintentar el analisis original automaticamente
  /// (ver [DownloadEnginePlugin.runAnalysis] del lado Kotlin).
  Stream<void> get onExtractorUpdating => _extractorUpdating.stream;

  Future<void> initialize() => _host.initialize();

  Future<void>? _readyFuture;

  /// El bootstrap de la app llama a [initialize] una vez al arrancar, pero
  /// esa llamada es asincrona y la primera extraccion de los binarios de
  /// yt-dlp/ffmpeg puede tardar. Sin esto, un enlace compartido desde otra
  /// app (o un usuario muy rapido) puede tocar "Analizar enlace" antes de
  /// que el motor nativo termine de inicializarse, y `YtDlpEngine` revienta
  /// con "initialize() no se ha llamado todavia". Cualquier operacion que
  /// dependa del motor pasa primero por aqui; el Future se memoiza para que
  /// no importe cual llamador llegue primero.
  Future<void> ensureInitialized() => _readyFuture ??= initialize();

  Future<AnalysisResult> analyzeUrl(String url) => _host.analyzeUrl(url);

  Future<void> startDownload(DownloadRequest request) => _host.startDownload(request);

  Future<void> cancelDownload(String downloadId) => _host.cancelDownload(downloadId);

  Future<ExtractorUpdateResult> updateExtractor() => _host.updateExtractor();

  Future<String?> currentExtractorVersion() => _host.currentExtractorVersion();

  @override
  void onExtractorAutoUpdating() {
    _extractorUpdating.add(null);
  }

  @override
  void onDownloadProgress(
    String downloadId,
    double percent,
    int? etaSeconds,
    int downloadedBytes,
    int? totalBytes,
  ) {
    _progress.add(DownloadProgressEvent(
      downloadId: downloadId,
      percent: percent,
      etaSeconds: etaSeconds,
      downloadedBytes: downloadedBytes,
      totalBytes: totalBytes,
    ));
  }

  @override
  void onDownloadCompleted(String downloadId, String savedUri, String fileName, int sizeBytes) {
    _completed.add(DownloadCompletedEvent(
      downloadId: downloadId,
      savedUri: savedUri,
      fileName: fileName,
      sizeBytes: sizeBytes,
    ));
  }

  @override
  void onDownloadFailed(String downloadId, DownloadErrorCode errorCode, String? errorDetail) {
    _failed.add(DownloadFailedEvent(downloadId: downloadId, errorCode: errorCode, errorDetail: errorDetail));
  }
}
