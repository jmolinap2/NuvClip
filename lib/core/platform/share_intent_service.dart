import 'package:flutter/services.dart';

/// Enlace recibido por el menu Compartir de TikTok/Instagram/el navegador
/// (seccion 3). Deliberadamente un MethodChannel aparte del contrato de
/// Pigeon: es un dato que Dart consulta una vez, no una operacion del motor
/// de descarga.
class ShareIntentService {
  const ShareIntentService();

  static const _channel = MethodChannel('com.nuvclip.app/share_intent');

  Future<String?> takeSharedText() => _channel.invokeMethod<String>('getSharedText');
}
