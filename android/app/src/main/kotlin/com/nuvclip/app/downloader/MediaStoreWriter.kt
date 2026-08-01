package com.nuvclip.app.downloader

import android.content.ContentValues
import android.content.Context
import android.net.Uri
import android.os.Environment
import android.provider.MediaStore
import java.io.File
import java.io.IOException

/**
 * Unica via para que un video descargado pase de la carpeta cache privada de
 * la app a un lugar visible para el usuario. Con minSdk 29 esto no requiere
 * ningun permiso de almacenamiento: insertar en MediaStore.Downloads con el
 * propio ContentResolver de la app esta permitido sin declarar nada en el
 * manifest.
 */
object MediaStoreWriter {
    private const val RELATIVE_FOLDER = "NuvClip"

    fun saveToDownloads(context: Context, source: File, displayName: String): Uri {
        val resolver = context.contentResolver
        val mimeType = mimeTypeFor(source.extension)

        val values = ContentValues().apply {
            put(MediaStore.Downloads.DISPLAY_NAME, displayName)
            put(MediaStore.Downloads.MIME_TYPE, mimeType)
            put(MediaStore.Downloads.RELATIVE_PATH, "${Environment.DIRECTORY_DOWNLOADS}/$RELATIVE_FOLDER")
            put(MediaStore.Downloads.IS_PENDING, 1)
        }

        val itemUri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
            ?: throw IOException("MediaStore no acepto el registro del archivo")

        try {
            resolver.openOutputStream(itemUri)?.use { output ->
                source.inputStream().use { input -> input.copyTo(output) }
            } ?: throw IOException("No se pudo abrir el destino en MediaStore")
        } catch (error: Exception) {
            // Un registro a medio escribir no debe quedar visible en la
            // galeria del usuario ni contar como descarga exitosa.
            resolver.delete(itemUri, null, null)
            throw error
        }

        values.clear()
        values.put(MediaStore.Downloads.IS_PENDING, 0)
        resolver.update(itemUri, values, null, null)

        return itemUri
    }

    fun sizeOf(context: Context, uri: Uri): Long =
        context.contentResolver.query(uri, arrayOf(MediaStore.Downloads.SIZE), null, null, null)?.use { cursor ->
            if (cursor.moveToFirst()) cursor.getLong(0) else 0L
        } ?: 0L

    private fun mimeTypeFor(extension: String): String = when (extension.lowercase()) {
        "mp4", "m4v" -> "video/mp4"
        "webm" -> "video/webm"
        "mov" -> "video/quicktime"
        "mkv" -> "video/x-matroska"
        else -> "video/mp4"
    }
}
