import 'package:nuvclip/core/platform/download_engine.g.dart';

/// Tabla codigo -> texto en espanol (requerimiento seccion 8: "no se
/// mostraran errores tecnicos directamente al usuario"). Kotlin solo
/// clasifica la falla; el copy final vive aqui, en un unico lugar.
String userMessageFor(DownloadErrorCode code) => switch (code) {
      DownloadErrorCode.unsupportedLink => 'Ese enlace no es compatible. NuvClip solo descarga desde TikTok e Instagram.',
      DownloadErrorCode.privateContent => 'Este contenido es privado y no se puede descargar.',
      DownloadErrorCode.contentRemoved => 'La publicacion ya no esta disponible; puede haber sido eliminada.',
      DownloadErrorCode.regionRestricted => 'Este contenido esta restringido en tu region.',
      DownloadErrorCode.fetchFailed => 'No fue posible obtener el archivo. Intenta de nuevo en unos minutos.',
      DownloadErrorCode.extractorOutdated => 'La plataforma cambio algo y el extractor necesita actualizarse.',
      DownloadErrorCode.insufficientStorage => 'No hay espacio suficiente en el dispositivo.',
      DownloadErrorCode.cancelled => 'La descarga fue cancelada.',
      DownloadErrorCode.networkLost => 'Se perdio la conexion. Revisa tu red e intenta de nuevo.',
      DownloadErrorCode.wifiRequired => 'Activaste "Solo con Wi-Fi" y no hay una red Wi-Fi disponible.',
      DownloadErrorCode.unknown => 'Algo salio mal y no se pudo completar la operacion.',
    };
