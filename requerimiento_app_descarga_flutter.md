# Aplicación Flutter para descargar videos públicos

## 1. Objetivo

Crear una aplicación móvil para Android que permita descargar videos públicos de TikTok e Instagram directamente en el dispositivo.

La aplicación será:

- Gratuita.
- Sin publicidad.
- Sin suscripciones.
- Sin backend propio.
- Sin consumo de APIs pagadas.
- De uso simple: pegar enlace, analizar y descargar.

> La descarga debe limitarse a contenido público que el usuario tenga permiso para guardar. No se garantiza compatibilidad permanente, porque TikTok e Instagram cambian sus mecanismos internos con frecuencia.

---

## 2. Tecnología seleccionada

### Aplicación

- **Flutter**
- **Dart**
- Diseño moderno con Material 3.
- Arquitectura por funcionalidades.
- Estado administrado con Riverpod.

### Integración Android

El motor de descarga se ejecutará localmente mediante código nativo Android:

- **Kotlin**
- **youtubedl-android**
- **yt-dlp**
- Comunicación Flutter–Android mediante `MethodChannel` o un plugin local.

### Persistencia local

- **Isar** o **Drift** para el historial.
- **SharedPreferences** para configuraciones sencillas.
- **MediaStore** para guardar los videos en la galería o carpeta de descargas.

No se necesita servidor, dominio, almacenamiento en la nube ni base de datos remota.

---

## 3. Flujo principal

```text
El usuario copia o comparte un enlace
                ↓
La aplicación detecta la plataforma
                ↓
Flutter envía la URL al módulo Kotlin
                ↓
yt-dlp analiza el contenido público
                ↓
La aplicación muestra información del video
                ↓
El usuario selecciona calidad
                ↓
El archivo se descarga en el dispositivo
                ↓
Se registra en el historial local
```

La aplicación también podrá recibir enlaces desde el menú **Compartir** de TikTok, Instagram o el navegador.

---

## 4. Funciones del MVP

### Inicio

- Campo para pegar el enlace.
- Botón para pegar desde el portapapeles.
- Detección automática de TikTok o Instagram.
- Botón principal **Analizar enlace**.
- Acceso rápido a descargas recientes.

### Vista previa

- Miniatura.
- Plataforma.
- Nombre del autor cuando esté disponible.
- Descripción corta.
- Duración.
- Opciones de calidad disponibles.
- Tamaño aproximado cuando pueda determinarse.
- Botón **Descargar video**.

### Descarga

- Progreso en porcentaje.
- Velocidad de descarga.
- Tamaño descargado.
- Posibilidad de cancelar.
- Notificación mientras la descarga está activa.
- Mensaje claro al finalizar.

### Historial

- Miniatura.
- Nombre del archivo.
- Plataforma.
- Fecha de descarga.
- Tamaño.
- Abrir.
- Compartir.
- Eliminar del historial.

### Configuración

- Carpeta de destino.
- Calidad preferida.
- Descargar solo con Wi-Fi.
- Conservar o limpiar el historial.
- Tema claro, oscuro o automático.
- Actualización del motor de extracción.

---

## 5. Arquitectura propuesta

La aplicación utilizará una arquitectura simple y modular.

```text
lib/
├── app/
│   ├── app.dart
│   ├── router.dart
│   └── theme/
├── core/
│   ├── errors/
│   ├── platform/
│   ├── storage/
│   └── utils/
├── features/
│   ├── downloader/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── history/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── settings/
│       ├── data/
│       └── presentation/
└── main.dart
```

Código nativo:

```text
android/app/src/main/kotlin/
└── com/example/app/
    └── downloader/
        ├── DownloadPlugin.kt
        ├── YtDlpService.kt
        ├── DownloadWorker.kt
        └── MediaStoreWriter.kt
```

### Responsabilidades

- **Flutter:** interfaz, navegación, estado, historial y configuración.
- **Kotlin:** integración con yt-dlp, descargas, almacenamiento Android y notificaciones.
- **yt-dlp:** análisis del enlace y obtención del contenido multimedia.

El código de Flutter no debe conocer detalles internos del extractor. Toda comunicación pasará por una interfaz definida.

---

## 6. Contrato Flutter–Kotlin

Métodos mínimos:

```text
initialize
analyzeUrl
startDownload
cancelDownload
updateExtractor
```

Eventos enviados hacia Flutter:

```text
analysisCompleted
downloadProgress
downloadCompleted
downloadFailed
```

Ejemplo de respuesta:

```json
{
  "platform": "tiktok",
  "title": "Nombre del video",
  "author": "usuario",
  "thumbnailUrl": "https://...",
  "durationSeconds": 24,
  "formats": [
    {
      "id": "720p",
      "label": "HD 720p",
      "extension": "mp4"
    }
  ]
}
```

---

## 7. Interfaz propuesta

### Estilo visual

- Tema oscuro como presentación principal.
- Fondo negro azulado.
- Tarjetas con transparencias suaves.
- Acentos en violeta y azul eléctrico.
- Bordes redondeados.
- Animaciones rápidas y discretas.
- Tipografía limpia y de alto contraste.
- Botones grandes y fáciles de identificar.

### Navegación

Barra inferior con tres opciones:

1. **Descargar**
2. **Historial**
3. **Ajustes**

### Pantalla principal

La pantalla debe mantener el foco en una sola acción:

```text
┌─────────────────────────────┐
│ Logo                   Ajustes
│
│ Descarga tus videos
│ Guarda contenido público
│ sin anuncios ni suscripciones
│
│ ┌─────────────────────────┐
│ │ Pega un enlace aquí     │
│ │                  Pegar  │
│ └─────────────────────────┘
│
│ [ Analizar enlace ]
│
│ Compatible con
│ TikTok · Instagram
│
│ Descargas recientes
│ [ tarjeta ] [ tarjeta ]
└─────────────────────────────┘
```

No se añadirán noticias, promociones, banners, cuentas obligatorias ni elementos que distraigan de la función principal.

---

## 8. Manejo de errores

La aplicación debe mostrar mensajes concretos:

- Enlace no compatible.
- Video privado.
- Publicación eliminada.
- Contenido restringido por región.
- No fue posible obtener el archivo.
- Se requiere actualizar el extractor.
- No hay espacio suficiente.
- La descarga fue cancelada.
- Se perdió la conexión.

No se mostrarán errores técnicos directamente al usuario. Los detalles podrán guardarse en un registro local para diagnóstico.

---

## 9. Seguridad y límites

- Aceptar únicamente dominios permitidos de TikTok e Instagram.
- No solicitar usuarios ni contraseñas.
- No almacenar cookies personales.
- No descargar contenido privado.
- Validar nombres y extensiones de archivo.
- Evitar ejecución de argumentos arbitrarios.
- Limitar descargas simultáneas.
- Eliminar archivos temporales incompletos.
- Solicitar solo los permisos Android necesarios.

---

## 10. Fases de desarrollo

### Fase 1 — Descarga funcional

- Proyecto Flutter.
- Interfaz principal.
- Integración nativa Android.
- Analizar enlaces.
- Descargar videos.
- Guardar en el dispositivo.

### Fase 2 — Experiencia completa

- Vista previa.
- Selección de calidad.
- Progreso y cancelación.
- Historial local.
- Compartir archivos.
- Configuración.

### Fase 3 — Estabilidad

- Actualización del extractor.
- Manejo completo de errores.
- Pruebas en distintas versiones de Android.
- Optimización del consumo de memoria.
- Preparación del APK de producción.

---

## 11. Consideraciones importantes

- El procesamiento ocurre en el teléfono; no existen costos por solicitud.
- La aplicación puede funcionar sin anuncios ni pagos.
- TikTok e Instagram pueden cambiar y provocar fallos temporales.
- El extractor debe mantenerse actualizado.
- Algunos videos pueden requerir autenticación, estar bloqueados o no ser accesibles.
- Una marca añadida dentro del video por el propio creador no puede eliminarse automáticamente.
- La publicación en Google Play puede tener restricciones adicionales relacionadas con propiedad intelectual y términos de las plataformas.

---

## 12. Resultado esperado

Una aplicación Android moderna y directa:

```text
Flutter
   ↓
Plugin Kotlin local
   ↓
youtubedl-android / yt-dlp
   ↓
Archivo guardado mediante Android MediaStore
```

El usuario podrá compartir o pegar un enlace público, revisar el contenido, seleccionar calidad y descargarlo directamente, sin publicidad, sin suscripciones y sin depender de APIs comerciales.

---

## Referencias técnicas

- Flutter Platform Channels: https://docs.flutter.dev/platform-integration/platform-channels
- yt-dlp: https://github.com/yt-dlp/yt-dlp
- youtubedl-android: https://github.com/yausername/youtubedl-android
