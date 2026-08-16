package com.nuvclip.app.downloader

import java.io.IOException
import org.junit.Assert.assertEquals
import org.junit.Test

class YtDlpEngineRecoveryTest {
    @Test
    fun `solo fallos de extractor de alta confianza solicitan actualizar`() {
        val cases = listOf(
            "Unable to extract initial data",
            "Unable to parse response",
            "Failed to parse JSON",
            "Signature extraction failed",
            "nsig extraction failed",
        )

        for (message in cases) {
            val error = IllegalStateException(message)
            assertEquals(
                DownloadErrorCode.EXTRACTOR_OUTDATED,
                YtDlpEngine.classifyError(error),
            )
            assertEquals(
                YtDlpEngine.RecoveryAction.UPDATE_EXTRACTOR,
                YtDlpEngine.recoveryAction(error),
            )
        }
    }

    @Test
    fun `formato desaparecido reanaliza sin actualizar`() {
        val error = IllegalStateException("Requested format is not available")

        assertEquals(DownloadErrorCode.FETCH_FAILED, YtDlpEngine.classifyError(error))
        assertEquals(
            YtDlpEngine.RecoveryAction.REANALYZE,
            YtDlpEngine.recoveryAction(error),
        )
    }

    @Test
    fun `restricciones y dependencias locales nunca actualizan el extractor`() {
        val cases = listOf(
            "HTTP Error 403: Forbidden",
            "HTTP Error 429: Too Many Requests",
            "Sign in to confirm you're not a bot",
            "This video is private",
            "Challenge solving failed",
            "No supported JavaScript runtime could be found",
        )

        for (message in cases) {
            assertEquals(
                YtDlpEngine.RecoveryAction.NONE,
                YtDlpEngine.recoveryAction(IllegalStateException(message)),
            )
        }
    }

    @Test
    fun `una causa dominante evita actualizar aunque el mensaje mencione extraccion`() {
        val cases = listOf(
            "Unable to extract metadata: HTTP Error 403",
            "Unable to extract data because this video is private",
            "Unable to parse response: too many requests",
        )

        for (message in cases) {
            assertEquals(
                YtDlpEngine.RecoveryAction.NONE,
                YtDlpEngine.recoveryAction(IllegalStateException(message)),
            )
        }
    }

    @Test
    fun `la causa anidada de red se conserva`() {
        val error = IllegalStateException("fallo del proceso", IOException("connection reset"))

        assertEquals(DownloadErrorCode.NETWORK_LOST, YtDlpEngine.classifyError(error))
        assertEquals(YtDlpEngine.RecoveryAction.NONE, YtDlpEngine.recoveryAction(error))
    }

    @Test
    fun `falta de espacio gana frente a una causa IOException`() {
        val error = IllegalStateException("No space left on device", IOException("write failed"))

        assertEquals(
            DownloadErrorCode.INSUFFICIENT_STORAGE,
            YtDlpEngine.classifyError(error),
        )
        assertEquals(YtDlpEngine.RecoveryAction.NONE, YtDlpEngine.recoveryAction(error))
    }
}
