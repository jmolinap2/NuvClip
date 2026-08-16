package com.nuvclip.app.downloader

import android.content.Context
import android.util.Log
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
    enum class RecoveryAction {
        NONE,
        REANALYZE,
        UPDATE_EXTRACTOR,
    }

    @Volatile
    private var initialized = false

    private val qualityBuckets = intArrayOf(2160, 1440, 1080, 720, 480, 360, 240)

    // Bitrates fijos ofrecidos para "Solo audio" (seccion 4, Vista previa:
    // "Opciones de calidad disponibles"). No se derivan de los formatos que
    // entrega el extractor porque TikTok/Instagram/Facebook normalmente no
    // exponen streams de audio separados; la extraccion real ocurre con -x
    // + ffmpeg en buildDownloadRequest, sea cual sea el origen.
    private val audioQualityKbps = intArrayOf(192, 128, 64)

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

    /**
     * A diferencia de [toFormatOptions], estas opciones no salen de
     * `info.formats`: son tres bitrates fijos, siempre disponibles sin
     * importar que exponga el extractor. El tamaño es una estimacion CBR a
     * partir de la duracion (bitrate * duracion / 8), suficiente para el
     * "Tamaño estimado" de la vista previa.
     */
    fun toAudioFormatOptions(info: VideoInfo): List<VideoFormatOption> {
        val durationSeconds = info.duration.toLong()
        return audioQualityKbps.map { kbps ->
            VideoFormatOption(
                formatId = "audio-$kbps",
                qualityLabel = "$kbps kbps",
                fileExtension = "mp3",
                height = null,
                approxSizeBytes = if (durationSeconds > 0) durationSeconds * kbps * 1000L / 8 else null,
            )
        }
    }

    fun buildDownloadRequest(sourceUrl: String, formatId: String, outputPath: String, audioOnly: Boolean): YoutubeDLRequest {
        val request = YoutubeDLRequest(sourceUrl)
        request.addOption("--no-playlist")
        if (audioOnly) {
            val kbps = formatId.removePrefix("audio-").toIntOrNull() ?: audioQualityKbps.last()
            // "-f bestaudio/best" deja que yt-dlp elija la mejor fuente de
            // audio disponible; -x + ffmpeg (ya inicializado en initialize())
            // hace la extraccion real a mp3, sin importar si el origen traia
            // audio y video mezclados (caso comun en TikTok/Instagram).
            request.addOption("-f", "bestaudio/best")
            request.addOption("-x")
            request.addOption("--audio-format", "mp3")
            request.addOption("--audio-quality", "${kbps}K")
        } else {
            request.addOption("-f", formatId)
            request.addOption("--merge-output-format", "mp4")
        }
        request.addOption("-o", outputPath)
        return request
    }

    /**
     * Reanaliza el enlace tras una recuperación y devuelve un formato vigente.
     * En video conserva la altura solicitada cuando el id original desaparece;
     * en audio conserva el bitrate sintético, que no depende del extractor.
     */
    fun refreshedFormatId(
        sourceUrl: String,
        originalFormatId: String,
        audioOnly: Boolean,
        requestedHeight: Long?,
    ): String {
        if (audioOnly) {
            analyze(sourceUrl)
            return originalFormatId
        }
        val formats = toFormatOptions(analyze(sourceUrl))
        check(formats.isNotEmpty()) { "el reanalisis no devolvio formatos de video" }
        return formats.firstOrNull { it.formatId == originalFormatId }?.formatId
            ?: requestedHeight?.let { height ->
                formats.filter { it.height != null }
                    .minByOrNull { kotlin.math.abs(checkNotNull(it.height) - height) }
                    ?.formatId
            }
            ?: formats.first().formatId
    }

    @Synchronized
    fun updateExtractor(context: Context): Pair<Boolean, String?> {
        assertInitialized()
        val status = YoutubeDL.getInstance().updateYoutubeDL(context.applicationContext)
        val updated = status == YoutubeDL.UpdateStatus.DONE
        return updated to currentVersion(context)
    }

    /**
     * Actualización reactiva single-flight. El botón manual de Ajustes sigue
     * usando [updateExtractor] sin enfriamiento; esta ruta sí evita consultar
     * GitHub una y otra vez ante un fallo que la última versión no resuelve.
     */
    @Synchronized
    fun refreshExtractorForRecovery(
        context: Context,
        observedVersion: String?,
        onUpdateStarted: () -> Unit = {},
    ): Boolean {
        assertInitialized()
        val appContext = context.applicationContext
        val current = currentVersion(appContext)
        if (observedVersion != null && current != null && current != observedVersion) {
            return true
        }

        val preferences = appContext.getSharedPreferences(PREFERENCES_NAME, Context.MODE_PRIVATE)
        val now = System.currentTimeMillis()
        val lastAttempt = preferences.getLong(KEY_LAST_RECOVERY_UPDATE_ATTEMPT, 0L)
        if (now - lastAttempt < RECOVERY_UPDATE_COOLDOWN_MS) return false

        preferences.edit().putLong(KEY_LAST_RECOVERY_UPDATE_ATTEMPT, now).apply()
        onUpdateStarted()
        val before = currentVersion(appContext)
        val (reportedUpdated, after) = updateExtractor(appContext)
        val versionChanged = before == null || after == null || before != after
        val usable = reportedUpdated && versionChanged
        Log.i(
            TAG,
            "actualizacion reactiva de yt-dlp: " +
                "reportedUpdated=$reportedUpdated, versionChanged=$versionChanged",
        )
        return usable
    }

    /**
     * Traduce el texto crudo de yt-dlp (stderr, o el mensaje de la
     * excepcion) a uno de los codigos de la seccion 8 del requerimiento.
     * yt-dlp no expone codigos de error estructurados, asi que esto es un
     * mejor esfuerzo por coincidencia de texto conocido, no una
     * clasificacion garantizada.
     */
    fun classifyError(throwable: Throwable): DownloadErrorCode {
        val text = diagnosticText(throwable)
        return when {
            text.contains("no space left") -> DownloadErrorCode.INSUFFICIENT_STORAGE
            text.contains("unsupported url") -> DownloadErrorCode.UNSUPPORTED_LINK
            text.contains("private") -> DownloadErrorCode.PRIVATE_CONTENT
            text.contains("login") && text.contains("required") -> DownloadErrorCode.PRIVATE_CONTENT
            text.contains("not available") && (text.contains("removed") || text.contains("longer")) ->
                DownloadErrorCode.CONTENT_REMOVED
            text.contains("this content isn't available") || text.contains("no longer available") ||
                text.contains("has been removed") -> DownloadErrorCode.CONTENT_REMOVED
            text.contains("not available in your country") || text.contains("geo-restricted") ||
                text.contains("blocked it in your country") -> DownloadErrorCode.REGION_RESTRICTED
            text.contains("not a bot") || text.contains("too many requests") ||
                text.contains("http error 429") -> DownloadErrorCode.FETCH_FAILED
            text.contains("unable to download webpage") || text.contains("http error 404") ||
                text.contains("http error 403") ||
                text.contains("requested format is not available") ||
                text.contains("only images are available") ||
                text.contains("challenge solving failed") -> DownloadErrorCode.FETCH_FAILED
            text.contains("no supported javascript runtime") -> DownloadErrorCode.UNKNOWN
            throwable.causes().any { it is UnknownHostException || it is IOException } ||
                NETWORK_ERROR_MARKERS.any(text::contains) -> DownloadErrorCode.NETWORK_LOST
            text.contains("unable to extract") || text.contains("unable to parse") ||
                text.contains("failed to parse json") ||
                text.contains("signature extraction failed") ||
                text.contains("nsig extraction failed") -> DownloadErrorCode.EXTRACTOR_OUTDATED
            else -> DownloadErrorCode.UNKNOWN
        }
    }

    fun recoveryAction(throwable: Throwable): RecoveryAction {
        val text = diagnosticText(throwable)
        val errorCode = classifyError(throwable)
        if (
            errorCode == DownloadErrorCode.FETCH_FAILED &&
            text.contains("requested format is not available")
        ) {
            return RecoveryAction.REANALYZE
        }
        return if (errorCode == DownloadErrorCode.EXTRACTOR_OUTDATED) {
            RecoveryAction.UPDATE_EXTRACTOR
        } else {
            RecoveryAction.NONE
        }
    }

    private fun diagnosticText(throwable: Throwable): String =
        throwable.causes()
            .mapNotNull { it.message }
            .joinToString("\n")
            .lowercase()

    private fun Throwable.causes(): Sequence<Throwable> =
        generateSequence(this) { current -> current.cause?.takeUnless { it === current } }
            .take(MAX_CAUSE_DEPTH)

    private const val TAG = "NuvClip"
    private const val PREFERENCES_NAME = "nuvclip_download_engine"
    private const val KEY_LAST_RECOVERY_UPDATE_ATTEMPT = "last_recovery_update_attempt"
    private const val RECOVERY_UPDATE_COOLDOWN_MS = 15L * 60 * 1000
    private const val MAX_CAUSE_DEPTH = 8

    private val NETWORK_ERROR_MARKERS = listOf(
        "temporary failure in name resolution",
        "name or service not known",
        "network is unreachable",
        "connection timed out",
        "read timed out",
        "connection reset",
        "no route to host",
    )
}
