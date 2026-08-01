import 'package:nuvclip/core/platform/engine_bridge.dart';

enum DownloadStage { idle, analyzing, analyzed, downloading, completed, failed }

class DownloadJobState {
  const DownloadJobState({
    this.stage = DownloadStage.idle,
    this.url = '',
    this.analysis,
    this.selectedFormat,
    this.downloadId,
    this.progressPercent = 0,
    this.etaSeconds,
    this.downloadedBytes = 0,
    this.completed,
    this.errorCode,
    this.errorDetail,
  });

  final DownloadStage stage;
  final String url;
  final VideoAnalysis? analysis;
  final VideoFormatOption? selectedFormat;
  final String? downloadId;
  final double progressPercent;
  final int? etaSeconds;
  final int downloadedBytes;
  final DownloadCompletedEvent? completed;
  final DownloadErrorCode? errorCode;
  final String? errorDetail;

  bool get isBusy => stage == DownloadStage.analyzing || stage == DownloadStage.downloading;

  DownloadJobState copyWith({
    DownloadStage? stage,
    String? url,
    VideoAnalysis? analysis,
    VideoFormatOption? selectedFormat,
    String? downloadId,
    double? progressPercent,
    int? etaSeconds,
    bool clearEta = false,
    int? downloadedBytes,
    DownloadCompletedEvent? completed,
    DownloadErrorCode? errorCode,
    String? errorDetail,
  }) {
    return DownloadJobState(
      stage: stage ?? this.stage,
      url: url ?? this.url,
      analysis: analysis ?? this.analysis,
      selectedFormat: selectedFormat ?? this.selectedFormat,
      downloadId: downloadId ?? this.downloadId,
      progressPercent: progressPercent ?? this.progressPercent,
      etaSeconds: clearEta ? null : (etaSeconds ?? this.etaSeconds),
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      completed: completed ?? this.completed,
      errorCode: errorCode,
      errorDetail: errorDetail,
    );
  }
}
