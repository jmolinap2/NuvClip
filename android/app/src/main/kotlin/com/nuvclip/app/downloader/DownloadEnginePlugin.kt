package com.nuvclip.app.downloader

import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

/**
 * Punto de entrada del plugin: implementa el HostApi generado por Pigeon,
 * inicia el servicio de descarga y reenvia sus eventos a Dart. No contiene
 * logica de yt-dlp propia; eso vive en [YtDlpEngine] y
 * [DownloadForegroundService].
 */
class DownloadEnginePlugin :
    FlutterPlugin,
    DownloadEngineHostApi,
    DownloadEventBus.Listener {

    private var binding: FlutterPlugin.FlutterPluginBinding? = null
    private var flutterApi: DownloadEngineFlutterApi? = null
    private val job = Job()
    private val scope = CoroutineScope(Dispatchers.IO + job)
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        this.binding = binding
        flutterApi = DownloadEngineFlutterApi(binding.binaryMessenger)
        DownloadEngineHostApi.setUp(binding.binaryMessenger, this)
        DownloadEventBus.register(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        DownloadEventBus.unregister(this)
        DownloadEngineHostApi.setUp(binding.binaryMessenger, null)
        flutterApi = null
        this.binding = null
        job.cancel()
    }

    // ---------------------------------------------------------------------
    // DownloadEngineHostApi (Dart -> Kotlin)
    // ---------------------------------------------------------------------

    override fun initialize(callback: (Result<Unit>) -> Unit) {
        scope.launch {
            runCatching { YtDlpEngine.initialize(requireContext()) }
                .let(callback)
        }
    }

    override fun analyzeUrl(url: String, callback: (Result<AnalysisResult>) -> Unit) {
        scope.launch {
            val platform = UrlValidator.platformFor(url)
            if (platform == SourcePlatform.UNKNOWN) {
                callback(Result.success(AnalysisResult(errorCode = DownloadErrorCode.UNSUPPORTED_LINK)))
                return@launch
            }
            val result = try {
                val info = YtDlpEngine.analyze(url)
                val analysis = VideoAnalysis(
                    sourceUrl = url,
                    platform = platform,
                    title = info.title?.takeIf { it.isNotBlank() } ?: info.fulltitle ?: "Video sin titulo",
                    author = info.uploader,
                    thumbnailUrl = info.thumbnail,
                    durationSeconds = info.duration.toLong(),
                    formats = YtDlpEngine.toFormatOptions(info),
                )
                AnalysisResult(video = analysis)
            } catch (error: Exception) {
                // Seccion 8 del requerimiento: el detalle tecnico no se le
                // muestra al usuario, pero debe quedar en algun registro
                // para poder diagnosticar. logcat es ese registro.
                Log.w(TAG, "analyzeUrl fallo para $url", error)
                AnalysisResult(errorCode = YtDlpEngine.classifyError(error), errorDetail = error.message)
            }
            callback(Result.success(result))
        }
    }

    override fun startDownload(request: DownloadRequest) {
        DownloadForegroundService.enqueue(requireContext(), request)
    }

    override fun cancelDownload(downloadId: String) {
        DownloadForegroundService.cancel(downloadId)
    }

    override fun updateExtractor(callback: (Result<ExtractorUpdateResult>) -> Unit) {
        scope.launch {
            val result = runCatching {
                val (updated, version) = YtDlpEngine.updateExtractor(requireContext())
                ExtractorUpdateResult(updated = updated, versionName = version)
            }
            callback(result)
        }
    }

    override fun currentExtractorVersion(): String? =
        YtDlpEngine.currentVersion(requireContext())

    // ---------------------------------------------------------------------
    // DownloadEventBus.Listener (Kotlin -> Dart). BasicMessageChannel.send
    // solo es seguro desde el hilo de plataforma, a diferencia de las
    // respuestas de HostApi -- por eso todo aqui pasa por mainHandler.
    // ---------------------------------------------------------------------

    override fun onProgress(downloadId: String, percent: Double, etaSeconds: Long?, downloadedBytes: Long, totalBytes: Long?) {
        mainHandler.post {
            flutterApi?.onDownloadProgress(downloadId, percent, etaSeconds, downloadedBytes, totalBytes) {}
        }
    }

    override fun onCompleted(downloadId: String, savedUri: String, fileName: String, sizeBytes: Long) {
        mainHandler.post {
            flutterApi?.onDownloadCompleted(downloadId, savedUri, fileName, sizeBytes) {}
        }
    }

    override fun onFailed(downloadId: String, errorCode: DownloadErrorCode, errorDetail: String?) {
        mainHandler.post {
            flutterApi?.onDownloadFailed(downloadId, errorCode, errorDetail) {}
        }
    }

    private fun requireContext() =
        binding?.applicationContext ?: error("DownloadEnginePlugin no esta adjunto a un FlutterEngine")

    companion object {
        private const val TAG = "NuvClip"
    }
}
