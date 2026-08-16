import 'package:nuvclip/core/platform/engine_bridge.dart';

enum DownloadStage { idle, analyzing, analyzed, downloading, completed, failed }

class DownloadJobState {
  const DownloadJobState({
    this.stage = DownloadStage.idle,
    this.url = '',
    this.analysis,
    this.audioOnly = false,
    this.selectedFormat,
    this.downloadId,
    this.progressPercent = 0,
    this.etaSeconds,
    this.downloadedBytes = 0,
    this.completed,
    this.errorCode,
    this.errorDetail,
    this.updatingExtractor = false,
  });

  final DownloadStage stage;
  final String url;
  final VideoAnalysis? analysis;

  /// true = el usuario eligio el modo "Solo audio" en la vista previa;
  /// [selectedFormat] sale entonces de `analysis.audioFormats` en vez de
  /// `analysis.formats`.
  final bool audioOnly;
  final VideoFormatOption? selectedFormat;
  final String? downloadId;
  final double progressPercent;
  final int? etaSeconds;
  final int downloadedBytes;
  final DownloadCompletedEvent? completed;
  final DownloadErrorCode? errorCode;
  final String? errorDetail;

  /// true entre el momento en que `analyzeUrl` detecta un extractor
  /// desactualizado y reintenta, y el resultado de ese reintento. Distingue
  /// esa espera extra de un analisis normal en la UI (ver
  /// [EngineBridge.onExtractorAutoUpdating]).
  final bool updatingExtractor;

  bool get isBusy => stage == DownloadStage.analyzing || stage == DownloadStage.downloading;

  DownloadJobState copyWith({
    DownloadStage? stage,
    String? url,
    VideoAnalysis? analysis,
    bool? audioOnly,
    VideoFormatOption? selectedFormat,
    String? downloadId,
    double? progressPercent,
    int? etaSeconds,
    bool clearEta = false,
    int? downloadedBytes,
    DownloadCompletedEvent? completed,
    DownloadErrorCode? errorCode,
    String? errorDetail,
    bool? updatingExtractor,
  }) {
    return DownloadJobState(
      stage: stage ?? this.stage,
      url: url ?? this.url,
      analysis: analysis ?? this.analysis,
      audioOnly: audioOnly ?? this.audioOnly,
      selectedFormat: selectedFormat ?? this.selectedFormat,
      downloadId: downloadId ?? this.downloadId,
      progressPercent: progressPercent ?? this.progressPercent,
      etaSeconds: clearEta ? null : (etaSeconds ?? this.etaSeconds),
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      completed: completed ?? this.completed,
      errorCode: errorCode,
      errorDetail: errorDetail,
      updatingExtractor: updatingExtractor ?? this.updatingExtractor,
    );
  }
}
