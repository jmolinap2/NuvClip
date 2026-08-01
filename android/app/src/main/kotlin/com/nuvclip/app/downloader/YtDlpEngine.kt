package com.nuvclip.app.downloader

import android.content.Context
import com.yausername.ffmpeg.FFmpeg
import com.yausername.youtubedl_android.YoutubeDL
import com.yausername.youtubedl_android.YoutubeDLRequest
import com.yausername.youtubedl_android.mapper.VideoFormat
import com.yausername.youtubedl_android.mapper.VideoInfo
import java.io.IOException
import java.net.UnknownHostException

/**
 * Envoltorio fino sobre youtubedl-android. No conoce Flutter ni el ciclo de
 * vida de Android: solo sabe inicializar el binario, analizar un enlace y
 * construir el comando de descarga. `DownloadEnginePlugin` y
 * `DownloadForegroundService` son quienes lo conectan con Pigeon y con la
 * notificacion en primer plano respectivamente.
 */
object YtDlpEngine {
    @Volatile
    private var initialized = false

    private val qualityBuckets = intArrayOf(2160, 1440, 1080, 720, 480, 360, 240)

    @Synchronized
    fun initialize(context: Context) {
        if (initialized) return
        val appContext = context.applicationContext
        YoutubeDL.getInstance().init(appContext)
        FFmpeg.getInstance().init(appContext)
        initialized = true
    }

    fun assertInitialized() {
        check(initialized) { "YtDlpEngine.initialize() no se ha llamado todavia" }
    }

    fun currentVersion(context: Context): String? =
        YoutubeDL.version(context.applicationContext)

    /**
     * Lanza YoutubeDLException con el texto crudo de yt-dlp si algo falla; el
     * llamador (DownloadEnginePlugin) es quien lo clasifica con
     * [classifyError] y arma el [AnalysisResult].
     */
    fun analyze(url: String): VideoInfo {
        assertInitialized()
        val request = YoutubeDLRequest(url)
        // Un enlace a un perfil o a un "reel" dentro de una coleccion no debe
        // arrastrar toda la lista: el usuario pego un video, no una cuenta.
        request.addOption("--no-playlist")
        request.addOption("--no-warnings")
        return YoutubeDL.getInstance().getInfo(request)
    }

    fun toFormatOptions(info: VideoInfo): List<VideoFormatOption> {
        val candidates = info.formats.orEmpty().filter {
            it.vcodec != null && it.vcodec != "none" && it.height > 0
        }
        if (candidates.isEmpty()) {
            // Algunos extractores devuelven un unico formato "best" sin
            // desglosar por resolucion; se ofrece igual una opcion utilizable
            // en vez de dejar la lista vacia.
            return listOf(
                VideoFormatOption(
                    formatId = "best",
                    qualityLabel = "Original",
                    fileExtension = info.ext ?: "mp4",
                    height = info.height.takeIf { it > 0 }?.toLong(),
                    approxSizeBytes = bestSize(info.fileSize, info.fileSizeApproximate),
                )
            )
        }

        // Se agrupa por el balde de resolucion mas cercano y, dentro de cada
        // balde, se queda el de mayor peso (normalmente el de mejor bitrate),
        // para no mostrar cinco variantes de "720p" que al usuario le
        // resultan indistinguibles.
        val byBucket = LinkedHashMap<Int, VideoFormat>()
        for (format in candidates.sortedByDescending { it.height }) {
            val bucket = qualityBuckets.minByOrNull { kotlin.math.abs(it - format.height) } ?: format.height
            val current = byBucket[bucket]
            val currentSize = current?.let { bestSize(it.fileSize, it.fileSizeApproximate) } ?: -1L
            val candidateSize = bestSize(format.fileSize, format.fileSizeApproximate) ?: -1L
            if (current == null || candidateSize > currentSize) {
                byBucket[bucket] = format
            }
        }

        return byBucket.entries
            .sortedByDescending { it.key }
            .map { (bucket, format) ->
                VideoFormatOption(
                    formatId = format.formatId ?: "best",
                    qualityLabel = "${bucket}p",
                    fileExtension = format.ext ?: "mp4",
                    height = format.height.toLong(),
                    approxSizeBytes = bestSize(format.fileSize, format.fileSizeApproximate),
                )
            }
    }

    private fun bestSize(exact: Long, approx: Long): Long? =
        exact.takeIf { it > 0 } ?: approx.takeIf { it > 0 }

    fun buildDownloadRequest(sourceUrl: String, formatId: String, outputPath: String): YoutubeDLRequest {
        val request = YoutubeDLRequest(sourceUrl)
        request.addOption("--no-playlist")
        request.addOption("-f", formatId)
        request.addOption("--merge-output-format", "mp4")
        request.addOption("-o", outputPath)
        return request
    }

    @Synchronized
    fun updateExtractor(context: Context): Pair<Boolean, String?> {
        assertInitialized()
        val status = YoutubeDL.getInstance().updateYoutubeDL(context.applicationContext)
        val updated = status == YoutubeDL.UpdateStatus.DONE
        return updated to currentVersion(context)
    }

    /**
     * Traduce el texto crudo de yt-dlp (stderr, o el mensaje de la
     * excepcion) a uno de los codigos de la seccion 8 del requerimiento.
     * yt-dlp no expone codigos de error estructurados, asi que esto es un
     * mejor esfuerzo por coincidencia de texto conocido, no una
     * clasificacion garantizada.
     */
    fun classifyError(throwable: Throwable): DownloadErrorCode {
        if (throwable is UnknownHostException || throwable is IOException) {
            return DownloadErrorCode.NETWORK_LOST
        }
        val text = (throwable.message ?: "").lowercase()
        return when {
            text.contains("unsupported url") -> DownloadErrorCode.UNSUPPORTED_LINK
            text.contains("private") -> DownloadErrorCode.PRIVATE_CONTENT
            text.contains("login") && text.contains("required") -> DownloadErrorCode.PRIVATE_CONTENT
            text.contains("not available") && (text.contains("removed") || text.contains("longer")) ->
                DownloadErrorCode.CONTENT_REMOVED
            text.contains("this content isn't available") || text.contains("no longer available") ||
                text.contains("has been removed") -> DownloadErrorCode.CONTENT_REMOVED
            text.contains("not available in your country") || text.contains("geo-restricted") ||
                text.contains("blocked it in your country") -> DownloadErrorCode.REGION_RESTRICTED
            text.contains("unable to extract") || text.contains("unable to parse") ||
                text.contains("failed to parse json") -> DownloadErrorCode.EXTRACTOR_OUTDATED
            text.contains("unable to download webpage") || text.contains("http error 404") ||
                text.contains("http error 403") -> DownloadErrorCode.FETCH_FAILED
            text.contains("no space left") -> DownloadErrorCode.INSUFFICIENT_STORAGE
            else -> DownloadErrorCode.UNKNOWN
        }
    }
}
