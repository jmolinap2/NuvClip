// Contrato tipado entre Flutter y el motor Android (requerimiento seccion 6).
// Regenerar con:
//   dart pub global run pigeon --input pigeons/download_engine.dart
//
// Desviacion deliberada del contrato propuesto en el requerimiento: alli
// "analysisCompleted" aparece como evento hacia Flutter. Aqui `analyzeUrl` es
// un metodo @async que devuelve su resultado directamente (Pigeon ya corre el
// callback en background y resuelve el Future en Dart), lo que evita inventar
// un id de correlacion para una operacion que de por si es de una sola
// respuesta. Los eventos reales (progreso, fin, fallo) sí son push porque
// ocurren repetidas veces despues de que `startDownload` ya retorno.
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/core/platform/download_engine.g.dart',
    kotlinOut:
        'android/app/src/main/kotlin/com/nuvclip/app/downloader/DownloadEngineApi.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.nuvclip.app.downloader'),
    dartPackageName: 'nuvclip',
  ),
)
enum SourcePlatform { tiktok, instagram, facebook, youtube, unknown }

/// Clasificacion tecnica del fallo (requerimiento seccion 8). El mensaje
/// exacto que ve el usuario vive en Dart (una tabla codigo -> texto en
/// espanol), no aqui: Kotlin solo diagnostica, no redacta copy de UI.
enum DownloadErrorCode {
  unsupportedLink,
  privateContent,
  contentRemoved,
  regionRestricted,
  fetchFailed,
  extractorOutdated,
  insufficientStorage,
  cancelled,
  networkLost,

  /// El ajuste "Solo con Wi-Fi" esta activo y no hay una red Wi-Fi disponible
  /// al momento de iniciar la descarga.
  wifiRequired,
  unknown,
}

class VideoFormatOption {
  late String formatId;

  /// Ya resuelto por Kotlin a partir de la altura/codec ("1080p", "720p").
  late String qualityLabel;
  late String fileExtension;
  int? height;
  int? approxSizeBytes;
}

class VideoAnalysis {
  late String sourceUrl;
  late SourcePlatform platform;
  late String title;
  String? author;
  String? thumbnailUrl;
  late int durationSeconds;
  late List<VideoFormatOption> formats;

  /// Calidades de solo-audio (extraccion con ffmpeg), separadas de [formats]
  /// porque no tienen altura y se seleccionan desde un modo aparte en la UI
  /// ("Video" / "Solo audio").
  late List<VideoFormatOption> audioFormats;
}

/// Union por nulabilidad: si [errorCode] es nulo, [video] esta presente y la
/// operacion tuvo exito; si no, [video] es nulo. Evita modelar una clase
/// sellada que Pigeon no puede expresar de forma nativa.
class AnalysisResult {
  VideoAnalysis? video;
  DownloadErrorCode? errorCode;

  /// Texto tecnico crudo (stderr de yt-dlp) solo para el registro local de
  /// diagnostico; nunca se muestra al usuario tal cual.
  String? errorDetail;
}

class DownloadRequest {
  /// Generado en Dart antes de llamar a `startDownload`, no por Kotlin: la
  /// fila de historial y la notificacion en primer plano necesitan un id
  /// estable desde antes de que exista ninguna respuesta nativa, para que no
  /// haya una ventana donde un evento de progreso llegue sin id que lo
  /// reciba.
  late String downloadId;
  late String sourceUrl;
  late SourcePlatform platform;
  late String formatId;
  late String suggestedFileName;
  late bool wifiOnly;

  /// true = extraer solo el audio (yt-dlp -x + ffmpeg) en vez del video
  /// completo; [formatId] en ese caso es uno de los ids sinteticos de
  /// [VideoAnalysis.audioFormats] ("audio-192", etc.), no un formato real de
  /// yt-dlp.
  late bool audioOnly;

  /// Tamaño aproximado que ya se conocia desde el analisis (seccion 4, Vista
  /// previa). Se reenvia para que el progreso pueda mostrar MB descargados
  /// sin que Kotlin tenga que volver a inferirlo.
  int? approxTotalBytes;
}

class ExtractorUpdateResult {
  /// true = se actualizo a una version nueva; false = ya estaba al dia.
  late bool updated;
  String? versionName;
}

@HostApi()
abstract class DownloadEngineHostApi {
  /// Inicializa yt-dlp y ffmpeg. Debe llamarse una sola vez por proceso,
  /// antes de cualquier otro metodo; es costosa (extrae binarios la primera
  /// vez) por lo que se ejecuta en el arranque de la app, no por cada enlace.
  @async
  void initialize();

  @async
  AnalysisResult analyzeUrl(String url);

  /// No bloquea: encola la descarga en el servicio en primer plano y
  /// retorna. El resultado llega despues por
  /// onDownloadCompleted/onDownloadFailed.
  void startDownload(DownloadRequest request);

  void cancelDownload(String downloadId);

  @async
  ExtractorUpdateResult updateExtractor();

  String? currentExtractorVersion();
}

@FlutterApi()
abstract class DownloadEngineFlutterApi {
  void onDownloadProgress(
    String downloadId,
    double percent,
    int? etaSeconds,
    int downloadedBytes,
    int? totalBytes,
  );

  void onDownloadCompleted(
    String downloadId,
    String savedUri,
    String fileName,
    int sizeBytes,
  );

  void onDownloadFailed(
    String downloadId,
    DownloadErrorCode errorCode,
    String? errorDetail,
  );
}
