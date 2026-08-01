import 'package:nuvclip/core/platform/download_engine.g.dart';

const _tiktokHosts = {'tiktok.com', 'www.tiktok.com', 'm.tiktok.com', 'vm.tiktok.com', 'vt.tiktok.com'};
const _instagramHosts = {'instagram.com', 'www.instagram.com'};

/// Deteccion instantanea en Dart, solo para feedback visual mientras el
/// usuario pega el enlace (seccion 4: "Deteccion automatica de TikTok o
/// Instagram"). No es la puerta de seguridad real: esa vive en
/// `UrlValidator.kt`, del lado nativo, porque este resultado es trivial de
/// evadir y aqui solo decide que icono mostrar.
SourcePlatform detectPlatform(String rawUrl) {
  final trimmed = rawUrl.trim();
  if (trimmed.isEmpty) return SourcePlatform.unknown;
  final uri = Uri.tryParse(trimmed);
  final host = uri?.host.toLowerCase();
  if (host == null || host.isEmpty) return SourcePlatform.unknown;
  if (_tiktokHosts.contains(host)) return SourcePlatform.tiktok;
  if (_instagramHosts.contains(host)) return SourcePlatform.instagram;
  return SourcePlatform.unknown;
}

bool looksLikeUrl(String text) {
  final uri = Uri.tryParse(text.trim());
  return uri != null && (uri.isScheme('HTTP') || uri.isScheme('HTTPS'));
}
