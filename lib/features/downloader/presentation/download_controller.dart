import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuvclip/core/platform/engine_bridge.dart';
import 'package:nuvclip/core/providers.dart';
import 'package:nuvclip/core/utils/filename_sanitizer.dart';
import 'package:nuvclip/features/downloader/domain/download_job.dart';
import 'package:nuvclip/features/settings/presentation/settings_controller.dart';

final downloadControllerProvider =
    NotifierProvider<DownloadController, DownloadJobState>(
      DownloadController.new,
    );

/// Motor de estado de la pantalla Descargar + Vista previa (fases 1 y 2).
/// Vive mas alla de la pantalla (NotifierProvider normal, no autoDispose)
/// para que una descarga en curso sobreviva si el usuario se pasa un
/// momento al Historial.
class DownloadController extends Notifier<DownloadJobState> {
  StreamSubscription<DownloadProgressEvent>? _progressSub;
  StreamSubscription<DownloadCompletedEvent>? _completedSub;
  StreamSubscription<DownloadFailedEvent>? _failedSub;
  StreamSubscription<void>? _extractorUpdatingSub;

  @override
  DownloadJobState build() {
    final bridge = ref.watch(engineBridgeProvider);
    _progressSub?.cancel();
    _completedSub?.cancel();
    _failedSub?.cancel();
    _extractorUpdatingSub?.cancel();

    _extractorUpdatingSub = bridge.onExtractorUpdating.listen((_) {
      if (state.stage == DownloadStage.analyzing) {
        state = state.copyWith(updatingExtractor: true);
      }
    });

    _progressSub = bridge.onProgress.listen((event) {
      if (event.downloadId != state.downloadId) return;
      state = state.copyWith(
        progressPercent: event.percent,
        etaSeconds: event.etaSeconds,
        clearEta: event.etaSeconds == null,
        downloadedBytes: event.downloadedBytes,
      );
    });

    _completedSub = bridge.onCompleted.listen((event) async {
      if (event.downloadId != state.downloadId) return;
      await ref
          .read(historyRepositoryProvider)
          .recordCompleted(
            downloadId: event.downloadId,
            savedUri: event.savedUri,
            fileName: event.fileName,
            sizeBytes: event.sizeBytes,
          );
      state = state.copyWith(
        stage: DownloadStage.completed,
        completed: event,
        progressPercent: 100,
      );
    });

    _failedSub = bridge.onFailed.listen((event) async {
      if (event.downloadId != state.downloadId) return;
      await ref
          .read(historyRepositoryProvider)
          .discardStarted(event.downloadId);
      state = state.copyWith(
        stage: DownloadStage.failed,
        errorCode: event.errorCode,
        errorDetail: event.errorDetail,
      );
    });

    ref.onDispose(() {
      _progressSub?.cancel();
      _completedSub?.cancel();
      _failedSub?.cancel();
      _extractorUpdatingSub?.cancel();
    });

    return const DownloadJobState();
  }

  void setUrl(String url) {
    if (state.isBusy) return;
    state = DownloadJobState(url: url);
  }

  Future<void> analyze() async {
    if (state.url.trim().isEmpty || state.isBusy) return;
    state = state.copyWith(
      stage: DownloadStage.analyzing,
      updatingExtractor: false,
    );
    final bridge = ref.read(engineBridgeProvider);
    await bridge.ensureInitialized();
    final result = await bridge.analyzeUrl(state.url.trim());
    if (result.video != null) {
      state = state.copyWith(
        stage: DownloadStage.analyzed,
        analysis: result.video,
        selectedFormat: _defaultFormatFor(result.video!, state.audioOnly),
        updatingExtractor: false,
      );
    } else {
      state = state.copyWith(
        stage: DownloadStage.failed,
        errorCode: result.errorCode,
        errorDetail: result.errorDetail,
        updatingExtractor: false,
      );
    }
  }

  void selectFormat(VideoFormatOption format) {
    if (state.stage != DownloadStage.analyzed) return;
    state = state.copyWith(selectedFormat: format);
  }

  /// Alterna entre descargar el video o extraer solo el audio (seccion 4:
  /// "Opciones de calidad disponibles" reaparece para el modo elegido, ya
  /// que `formats` y `audioFormats` tienen calidades independientes).
  void setAudioOnly(bool audioOnly) {
    if (state.stage != DownloadStage.analyzed) return;
    final analysis = state.analysis;
    if (analysis == null || audioOnly == state.audioOnly) return;
    state = state.copyWith(
      audioOnly: audioOnly,
      selectedFormat: _defaultFormatFor(analysis, audioOnly),
    );
  }

  /// Para audio no hay un ajuste de calidad preferida como con el video, asi
  /// que se ofrece el bitrate intermedio (indice 1 de 3) como punto medio
  /// razonable entre tamaño y fidelidad.
  VideoFormatOption? _defaultFormatFor(VideoAnalysis analysis, bool audioOnly) {
    final formats = audioOnly ? analysis.audioFormats : analysis.formats;
    if (formats.isEmpty) return null;
    if (audioOnly) return formats.length > 1 ? formats[1] : formats.first;
    final preferredHeight = ref
        .read(settingsControllerProvider)
        .preferredQualityHeight;
    return formats.reduce((a, b) {
      final aDiff = ((a.height ?? 0) - preferredHeight).abs();
      final bDiff = ((b.height ?? 0) - preferredHeight).abs();
      return aDiff <= bDiff ? a : b;
    });
  }

  Future<void> startDownload() async {
    final analysis = state.analysis;
    final format = state.selectedFormat;
    if (analysis == null || format == null) return;

    final downloadId = _newDownloadId();
    final fileName = sanitizeFileName(
      analysis.title,
      extension: format.fileExtension,
    );
    final wifiOnly = ref.read(settingsControllerProvider).wifiOnly;

    await ref
        .read(historyRepositoryProvider)
        .recordStarted(
          downloadId: downloadId,
          sourceUrl: analysis.sourceUrl,
          platform: analysis.platform,
          title: analysis.title,
          fileName: fileName,
          thumbnailUrl: analysis.thumbnailUrl,
          durationSeconds: analysis.durationSeconds,
        );

    state = state.copyWith(
      stage: DownloadStage.downloading,
      downloadId: downloadId,
      progressPercent: 0,
      downloadedBytes: 0,
    );

    await ref
        .read(engineBridgeProvider)
        .startDownload(
          DownloadRequest(
            downloadId: downloadId,
            sourceUrl: analysis.sourceUrl,
            platform: analysis.platform,
            formatId: format.formatId,
            suggestedFileName: fileName,
            wifiOnly: wifiOnly,
            audioOnly: state.audioOnly,
            requestedHeight: state.audioOnly ? null : format.height,
            approxTotalBytes: format.approxSizeBytes,
          ),
        );
  }

  Future<void> cancel() async {
    final id = state.downloadId;
    if (id == null) return;
    await ref.read(engineBridgeProvider).cancelDownload(id);
  }

  /// Vuelve a la pantalla principal en blanco para pegar otro enlace, sin
  /// perder el ultimo resultado mientras la transicion ocurre.
  void reset() {
    state = const DownloadJobState();
  }

  String _newDownloadId() {
    final random = Random().nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0');
    return '${DateTime.now().microsecondsSinceEpoch.toRadixString(16)}$random';
  }
}
