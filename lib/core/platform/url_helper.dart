import 'package:nuvclip/core/platform/download_engine.g.dart';

const _tiktokHosts = {'tiktok.com', 'www.tiktok.com', 'm.tiktok.com', 'vm.tiktok.com', 'vt.tiktok.com'};
const _instagramHosts = {'instagram.com', 'www.instagram.com'};
const _facebookHosts = {'facebook.com', 'www.facebook.com', 'm.facebook.com', 'web.facebook.com', 'fb.watch'};
const _youtubeHosts = {'youtube.com', 'www.youtube.com', 'm.youtube.com', 'music.youtube.com', 'youtu.be'};

/// Deteccion instantanea en Dart, solo para feedback visual mientras el
/// usuario pega el enlace (seccion 4: "Deteccion automatica de TikTok,
/// Instagram, Facebook o YouTube"). No es la puerta de seguridad real: esa
/// vive en `UrlValidator.kt`, del lado nativo, porque este resultado es
/// trivial de evadir y aqui solo decide que icono mostrar.
SourcePlatform detectPlatform(String rawUrl) {
  final trimmed = rawUrl.trim();
  if (trimmed.isEmpty) return SourcePlatform.unknown;
  final uri = Uri.tryParse(trimmed);
  final host = uri?.host.toLowerCase();
  if (host == null || host.isEmpty) return SourcePlatform.unknown;
  if (_tiktokHosts.contains(host)) return SourcePlatform.tiktok;
  if (_instagramHosts.contains(host)) return SourcePlatform.instagram;
  if (_facebookHosts.contains(host)) return SourcePlatform.facebook;
  if (_youtubeHosts.contains(host)) return SourcePlatform.youtube;
  return SourcePlatform.unknown;
}

/// Nombre visible de la plataforma, usado en chips y encabezados de vista
/// previa para no repetir el mismo switch en cada widget.
String platformLabel(SourcePlatform platform) => switch (platform) {
      SourcePlatform.tiktok => 'TikTok',
      SourcePlatform.instagram => 'Instagram',
      SourcePlatform.facebook => 'Facebook',
      SourcePlatform.youtube => 'YouTube',
      SourcePlatform.unknown => 'Desconocida',
    };

bool looksLikeUrl(String text) {
  final uri = Uri.tryParse(text.trim());
  return uri != null && (uri.isScheme('HTTP') || uri.isScheme('HTTPS'));
}
