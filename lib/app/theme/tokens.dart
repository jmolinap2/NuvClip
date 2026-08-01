import 'package:flutter/widgets.dart';

/// Escala de espaciado y forma compartida por toda la interfaz. Centralizar
/// estos numeros evita que cada pantalla invente su propio "20" o "24" y que
/// terminen sin alinearse entre si, como paso con la primera version de
/// NuvTune antes de que existiera este archivo alli.
abstract final class Tokens {
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space7 = 32;

  /// Margen horizontal estandar de pantalla, tomado de las referencias.
  static const double gutter = 20;

  static const double radiusSmall = 12;
  static const double radiusMedium = 18;
  static const double radiusLarge = 24;
  static const double radiusStadium = 999;

  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationMedium = Duration(milliseconds: 250);

  static const String fontFamily = 'SpaceGrotesk';
}

/// Paleta fija de marca. A diferencia de NuvTune, aqui no hay selector de
/// apariencia: el requerimiento (seccion 7) fija un unico estilo visual
/// oscuro con acentos violeta/azul, sin pedir personalizacion.
abstract final class Palette {
  static const Color background = Color(0xFF05070F);
  static const Color backgroundGlow = Color(0xFF141C3D);

  static const Color surface = Color(0xFF11162A);
  static const Color surfaceBorder = Color(0x14FFFFFF);

  static const Color textPrimary = Color(0xFFF5F6FA);
  static const Color textSecondary = Color(0xFFA6ACC4);
  static const Color textMuted = Color(0xFF6E7495);

  static const Color accentBlue = Color(0xFF3D6BFF);
  static const Color accentViolet = Color(0xFF8B4DFF);

  static const Color danger = Color(0xFFFF5C7A);
  static const Color success = Color(0xFF3DDC97);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [accentBlue, accentViolet],
  );

  static const LinearGradient heroGlow = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFF1D2C6B), Color(0x001D2C6B)],
  );
}
