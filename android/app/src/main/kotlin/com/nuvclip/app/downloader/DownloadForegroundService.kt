package com.nuvclip.app.downloader

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.IBinder
import android.os.StatFs
import android.util.Log
import androidx.core.app.NotificationCompat
import com.nuvclip.app.MainActivity
import com.yausername.youtubedl_android.YoutubeDL
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.launch
import java.io.File
import java.util.Collections
import java.util.concurrent.atomic.AtomicInteger

/**
 * Sostiene las descargas activas fuera del ciclo de vida de la Activity
 * (requerimiento seccion 4: "Notificacion mientras la descarga esta
 * activa"). Procesa una a la vez -- seccion 9 pide limitar descargas
 * simultaneas -- y encola el resto; cuando no queda nada pendiente se
 * detiene, en vez de quedar viva de fondo sin trabajo.
 */
class DownloadForegroundService : Service() {

    private val job = Job()
    private val scope = CoroutineScope(Dispatchers.IO + job)
    private lateinit var queue: Channel<QueuedDownload>
    private val pendingCount = AtomicInteger(0)

    private data class QueuedDownload(
        val downloadId: String,
        val sourceUrl: String,
        val formatId: String,
        val suggestedFileName: String,
        val wifiOnly: Boolean,
        val approxTotalBytes: Long?,
        val audioOnly: Boolean,
    )

    override fun onCreate() {
        super.onCreate()
        YtDlpEngine.initialize(applicationContext)
        createNotificationChannel()
        queue = Channel(Channel.UNLIMITED)
        scope.launch {
            for (item in queue) {
                runDownload(item)
                if (pendingCount.decrementAndGet() == 0) {
                    stopForeground(STOP_FOREGROUND_REMOVE)
                    stopSelf()
                }
            }
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val extras = intent?.extras ?: return START_NOT_STICKY
        val downloadId = extras.getString(EXTRA_DOWNLOAD_ID) ?: return START_NOT_STICKY

        pendingCount.incrementAndGet()
        startForeground(
            NOTIFICATION_ID,
            buildNotification(extras.getString(EXTRA_FILE_NAME) ?: downloadId, 0, true, extras.getBoolean(EXTRA_AUDIO_ONLY, false)),
        )

        queue.trySend(
            QueuedDownload(
                downloadId = downloadId,
                sourceUrl = extras.getString(EXTRA_SOURCE_URL)!!,
                formatId = extras.getString(EXTRA_FORMAT_ID)!!,
                suggestedFileName = extras.getString(EXTRA_FILE_NAME)!!,
                wifiOnly = extras.getBoolean(EXTRA_WIFI_ONLY, false),
                approxTotalBytes = extras.getLong(EXTRA_TOTAL_BYTES, -1L).takeIf { it > 0 },
                audioOnly = extras.getBoolean(EXTRA_AUDIO_ONLY, false),
            )
        )
        return START_NOT_STICKY
    }

    private fun runDownload(item: QueuedDownload) {
        if (cancelledIds.remove(item.downloadId)) {
            DownloadEventBus.emitFailed(item.downloadId, DownloadErrorCode.CANCELLED, null)
            return
        }

        if (item.wifiOnly && !isOnWifi()) {
            DownloadEventBus.emitFailed(item.downloadId, DownloadErrorCode.WIFI_REQUIRED, null)
            return
        }

        val outputDir = File(cacheDir, "downloads").apply { mkdirs() }
        if (item.approxTotalBytes != null && item.approxTotalBytes > StatFs(outputDir.path).availableBytes) {
            DownloadEventBus.emitFailed(item.downloadId, DownloadErrorCode.INSUFFICIENT_STORAGE, null)
            return
        }

        val outputTemplate = File(outputDir, "${item.downloadId}.%(ext)s").absolutePath
        updateNotification(item.suggestedFileName, 0, indeterminate = true, audioOnly = item.audioOnly)

        var lastEmitAt = 0L
        try {
            val request = YtDlpEngine.buildDownloadRequest(item.sourceUrl, item.formatId, outputTemplate, item.audioOnly)
            YoutubeDL.getInstance().execute(request, item.downloadId) { percent, etaSeconds, _ ->
                val now = System.currentTimeMillis()
                // yt-dlp reporta progreso muchas veces por segundo en redes
                // rapidas; sin este filtro el canal de Pigeon se satura sin
                // que el usuario perciba diferencia visual.
                if (now - lastEmitAt < PROGRESS_THROTTLE_MS && percent < 100f) return@execute
                lastEmitAt = now
                val downloaded = item.approxTotalBytes?.let { (it * (percent / 100.0)).toLong() } ?: 0L
                DownloadEventBus.emitProgress(
                    item.downloadId, percent.toDouble(), etaSeconds.takeIf { it > 0 },
                    downloaded, item.approxTotalBytes,
                )
                updateNotification(item.suggestedFileName, percent.toInt(), indeterminate = false, audioOnly = item.audioOnly)
            }

            val producedFile = outputDir.listFiles { file -> file.name.startsWith("${item.downloadId}.") }?.firstOrNull()
                ?: error("yt-dlp no genero un archivo de salida")

            val savedUri = MediaStoreWriter.saveToDownloads(applicationContext, producedFile, item.suggestedFileName)
            val sizeBytes = MediaStoreWriter.sizeOf(applicationContext, savedUri)
            producedFile.delete()

            DownloadEventBus.emitCompleted(item.downloadId, savedUri.toString(), item.suggestedFileName, sizeBytes)
        } catch (cancelled: YoutubeDL.CanceledException) {
            DownloadEventBus.emitFailed(item.downloadId, DownloadErrorCode.CANCELLED, null)
        } catch (error: Exception) {
            Log.w(TAG, "descarga fallida para ${item.downloadId} (${item.sourceUrl})", error)
            DownloadEventBus.emitFailed(item.downloadId, YtDlpEngine.classifyError(error), error.message)
        } finally {
            outputDir.listFiles { file -> file.name.startsWith("${item.downloadId}.") }
                ?.forEach { it.delete() }
        }
    }

    private fun isOnWifi(): Boolean {
        val manager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val network = manager.activeNetwork ?: return false
        val capabilities = manager.getNetworkCapabilities(network) ?: return false
        return capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)
    }

    private fun createNotificationChannel() {
        val manager = getSystemService(NotificationManager::class.java)
        val channel = NotificationChannel(
            CHANNEL_ID, "Descargas", NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = "Progreso de las descargas de NuvClip"
            setSound(null, null)
        }
        manager.createNotificationChannel(channel)
    }

    private fun updateNotification(fileName: String, progress: Int, indeterminate: Boolean, audioOnly: Boolean) {
        val manager = getSystemService(NotificationManager::class.java)
        manager.notify(NOTIFICATION_ID, buildNotification(fileName, progress, indeterminate, audioOnly))
    }

    private fun buildNotification(fileName: String, progress: Int, indeterminate: Boolean, audioOnly: Boolean): Notification {
        val openApp = PendingIntent.getActivity(
            this, 0, Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(if (audioOnly) "Descargando audio" else "Descargando video")
            .setContentText(fileName)
            .setSmallIcon(android.R.drawable.stat_sys_download)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setContentIntent(openApp)
            .setProgress(100, progress, indeterminate)
            .build()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        job.cancel()
        super.onDestroy()
    }

    companion object {
        private const val TAG = "NuvClip"
        private const val CHANNEL_ID = "nuvclip_downloads"
        private const val NOTIFICATION_ID = 42
        private const val PROGRESS_THROTTLE_MS = 400L

        const val EXTRA_DOWNLOAD_ID = "downloadId"
        const val EXTRA_SOURCE_URL = "sourceUrl"
        const val EXTRA_FORMAT_ID = "formatId"
        const val EXTRA_FILE_NAME = "fileName"
        const val EXTRA_WIFI_ONLY = "wifiOnly"
        const val EXTRA_TOTAL_BYTES = "totalBytes"
        const val EXTRA_AUDIO_ONLY = "audioOnly"

        private val cancelledIds = Collections.newSetFromMap(java.util.concurrent.ConcurrentHashMap<String, Boolean>())

        fun enqueue(context: Context, request: DownloadRequest) {
            val intent = Intent(context, DownloadForegroundService::class.java).apply {
                putExtra(EXTRA_DOWNLOAD_ID, request.downloadId)
                putExtra(EXTRA_SOURCE_URL, request.sourceUrl)
                putExtra(EXTRA_FORMAT_ID, request.formatId)
                putExtra(EXTRA_FILE_NAME, request.suggestedFileName)
                putExtra(EXTRA_WIFI_ONLY, request.wifiOnly)
                putExtra(EXTRA_AUDIO_ONLY, request.audioOnly)
                request.approxTotalBytes?.let { putExtra(EXTRA_TOTAL_BYTES, it) }
            }
            context.startForegroundService(intent)
        }

        fun cancel(downloadId: String) {
            cancelledIds.add(downloadId)
            YoutubeDL.getInstance().destroyProcessById(downloadId)
        }
    }
}
