package com.nuvclip.app.downloader

import java.util.concurrent.CopyOnWriteArrayList

/**
 * Puente en memoria entre `DownloadForegroundService` (que no tiene por que
 * conocer Flutter) y `DownloadEnginePlugin` (que es quien reenvia estos
 * eventos a Dart via [DownloadEngineFlutterApi]). Ambos viven en el mismo
 * proceso, asi que no hace falta IPC: un listener registrado es suficiente.
 */
object DownloadEventBus {
    interface Listener {
        fun onProgress(downloadId: String, percent: Double, etaSeconds: Long?, downloadedBytes: Long, totalBytes: Long?)
        fun onCompleted(downloadId: String, savedUri: String, fileName: String, sizeBytes: Long)
        fun onFailed(downloadId: String, errorCode: DownloadErrorCode, errorDetail: String?)
    }

    private val listeners = CopyOnWriteArrayList<Listener>()

    fun register(listener: Listener) {
        listeners.add(listener)
    }

    fun unregister(listener: Listener) {
        listeners.remove(listener)
    }

    fun emitProgress(downloadId: String, percent: Double, etaSeconds: Long?, downloadedBytes: Long, totalBytes: Long?) {
        listeners.forEach { it.onProgress(downloadId, percent, etaSeconds, downloadedBytes, totalBytes) }
    }

    fun emitCompleted(downloadId: String, savedUri: String, fileName: String, sizeBytes: Long) {
        listeners.forEach { it.onCompleted(downloadId, savedUri, fileName, sizeBytes) }
    }

    fun emitFailed(downloadId: String, errorCode: DownloadErrorCode, errorDetail: String?) {
        listeners.forEach { it.onFailed(downloadId, errorCode, errorDetail) }
    }
}
