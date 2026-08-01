package com.nuvclip.app.downloader

import java.net.URI

/**
 * Puerta de entrada real del requerimiento seccion 9 ("Aceptar unicamente
 * dominios permitidos"). yt-dlp por si mismo sabe extraer de mas de mil
 * sitios, asi que el limite a TikTok/Instagram no existe salvo que se
 * imponga aqui, antes de invocarlo. La deteccion que hace Dart en la
 * pantalla principal es solo para feedback instantaneo mientras el usuario
 * pega el enlace; esta es la que decide si de verdad se ejecuta yt-dlp.
 */
object UrlValidator {
    private val tiktokHosts = setOf(
        "tiktok.com", "www.tiktok.com", "m.tiktok.com", "vm.tiktok.com", "vt.tiktok.com",
    )
    private val instagramHosts = setOf(
        "instagram.com", "www.instagram.com",
    )

    fun platformFor(url: String): SourcePlatform {
        val host = hostOf(url) ?: return SourcePlatform.UNKNOWN
        return when {
            tiktokHosts.contains(host) -> SourcePlatform.TIKTOK
            instagramHosts.contains(host) -> SourcePlatform.INSTAGRAM
            else -> SourcePlatform.UNKNOWN
        }
    }

    private fun hostOf(url: String): String? =
        try {
            URI(url.trim()).host?.lowercase()
        } catch (_: Exception) {
            null
        }
}
