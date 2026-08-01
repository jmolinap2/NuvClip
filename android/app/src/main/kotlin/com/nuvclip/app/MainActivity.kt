package com.nuvclip.app

import android.content.Intent
import android.os.Bundle
import com.nuvclip.app.downloader.DownloadEnginePlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * El unico dato que necesita cruzar aqui fuera del contrato de Pigeon es el
 * enlace recibido por el menu Compartir (seccion 3 del requerimiento): un
 * MethodChannel minimo alcanza, no amerita tocar el esquema de Pigeon para
 * algo que Dart solo consulta una vez, al arrancar o al volver a primer
 * plano.
 */
class MainActivity : FlutterActivity() {
    private var pendingSharedText: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        pendingSharedText = extractSharedText(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        pendingSharedText = extractSharedText(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(DownloadEnginePlugin())

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SHARE_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getSharedText") {
                result.success(pendingSharedText)
                // Se consume una sola vez: si Dart vuelve a preguntar (por un
                // hot restart o una segunda pantalla) no debe reenviar el
                // mismo enlace como si acabara de llegar de nuevo.
                pendingSharedText = null
            } else {
                result.notImplemented()
            }
        }
    }

    private fun extractSharedText(intent: Intent?): String? {
        if (intent?.action != Intent.ACTION_SEND || intent.type != "text/plain") return null
        return intent.getStringExtra(Intent.EXTRA_TEXT)
    }

    companion object {
        private const val SHARE_CHANNEL = "com.nuvclip.app/share_intent"
    }
}
