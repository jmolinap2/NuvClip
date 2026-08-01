/// Convierte el titulo de un video (texto libre, con emojis, saltos de linea
/// y caracteres que MediaStore no admite en un nombre de archivo) en un
/// nombre seguro para guardar en Descargas.
String sanitizeFileName(String title, {required String extension}) {
  // Saltos de linea y tabs se normalizan a espacio (no se borran, o
  // "con\nvarias" quedaria pegado como "convarias"). Los caracteres que el
  // sistema de archivos no admite (":", "/", etc.) si se borran del todo, lo
  // que puede dejar huecos dobles donde vivia uno rodeado de espacios -- por
  // eso el espaciado se colapsa otra vez despues de quitarlos.
  final normalizedWhitespace = title.replaceAll(RegExp(r'\s+'), ' ');
  final withoutIllegalChars = normalizedWhitespace.replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F]'), '');
  final collapsed = withoutIllegalChars.trim().replaceAll(RegExp(r'\s+'), ' ');
  final safeBase = collapsed.isEmpty
      ? 'video'
      : (collapsed.length > 80 ? collapsed.substring(0, 80).trim() : collapsed);
  return '$safeBase.$extension';
}
