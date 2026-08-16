# Recuperación del motor de descargas

Estado: implementado en `1.0.1+7`.

NuvClip actualiza `yt-dlp` automáticamente solo ante fallos de alta confianza
del extractor. Red, 403/404/429, anti-bot, contenido privado, restricciones,
almacenamiento, runtime JavaScript y challenges nunca disparan esa acción.

## Flujo

1. Se clasifica el error.
2. Un fallo de extracción/parseo permite una única actualización automática.
3. Solo se repite si se instaló una versión distinta o si otro trabajo ya la
   había instalado.
4. Se vuelve a analizar el enlace antes de descargar.
5. En video se conserva la altura solicitada aunque el nuevo extractor haya
   cambiado los identificadores internos de formato.
6. Un formato desaparecido se reanaliza sin actualizar el binario.

La actualización es *single-flight* y un intento sin versión nueva activa un
enfriamiento de 15 minutos. La actualización manual de Ajustes conserva su
comportamiento y no usa ese enfriamiento. Cada trabajo puede recuperarse una
sola vez y la cancelación siempre tiene prioridad.

Las reglas puras de clasificación se verifican en
`android/app/src/test/kotlin/com/nuvclip/app/downloader/YtDlpEngineRecoveryTest.kt`.
