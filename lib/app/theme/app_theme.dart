import 'package:flutter/material.dart';
import 'package:nuvclip/app/theme/tokens.dart';

abstract final class AppTheme {
  /// Las cuatro referencias visuales del requerimiento son todas oscuras
  /// (seccion 7: "Tema oscuro como presentacion principal"); este es el
  /// tema real de la app. El claro existe solo porque el bloque Ajustes
  /// promete "Tema: claro, oscuro o automatico" y no tiene sentido ofrecer
  /// la opcion sin implementarla, pero es un espejo mecanico de la paleta,
  /// no un segundo sistema visual disenado por separado.
  static ThemeData get light {
    const bg = Color(0xFFF6F7FB);
    const surface = Colors.white;
    const border = Color(0x14000000);
    const textPrimary = Color(0xFF14172B);
    const textSecondary = Color(0xFF585F7A);

    final colorScheme = ColorScheme.light(
      primary: Palette.accentBlue,
      onPrimary: Colors.white,
      secondary: Palette.accentViolet,
      onSecondary: Colors.white,
      surface: surface,
      onSurface: textPrimary,
      error: Palette.danger,
      onError: Colors.white,
      outline: border,
    );

    return dark.copyWith(
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      appBarTheme: dark.appBarTheme.copyWith(foregroundColor: textPrimary),
      iconTheme: const IconThemeData(color: textPrimary),
      dividerTheme: const DividerThemeData(color: border, thickness: 1, space: 1),
      textTheme: dark.textTheme.apply(bodyColor: textPrimary, displayColor: textPrimary),
      cardTheme: dark.cardTheme.copyWith(
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Tokens.radiusLarge),
          side: const BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: dark.inputDecorationTheme.copyWith(
        fillColor: surface,
        hintStyle: dark.inputDecorationTheme.hintStyle?.copyWith(color: textSecondary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Tokens.radiusMedium),
          borderSide: const BorderSide(color: border),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Tokens.radiusMedium),
          borderSide: const BorderSide(color: border),
        ),
      ),
      chipTheme: dark.chipTheme.copyWith(backgroundColor: surface, side: const BorderSide(color: border)),
      dialogTheme: dark.dialogTheme.copyWith(backgroundColor: surface),
      bottomSheetTheme: dark.bottomSheetTheme.copyWith(backgroundColor: surface),
    );
  }

  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      brightness: Brightness.dark,
      primary: Palette.accentBlue,
      onPrimary: Colors.white,
      secondary: Palette.accentViolet,
      onSecondary: Colors.white,
      surface: Palette.surface,
      onSurface: Palette.textPrimary,
      error: Palette.danger,
      onError: Colors.white,
      outline: Palette.surfaceBorder,
    );

    final textTheme = _textTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Palette.background,
      fontFamily: Tokens.fontFamily,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Palette.textPrimary,
      ),
      iconTheme: const IconThemeData(color: Palette.textPrimary),
      dividerTheme: const DividerThemeData(color: Palette.surfaceBorder, thickness: 1, space: 1),
      cardTheme: CardThemeData(
        color: Palette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Tokens.radiusLarge),
          side: const BorderSide(color: Palette.surfaceBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Palette.surface,
        hintStyle: textTheme.bodyMedium?.copyWith(color: Palette.textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: Tokens.space5, vertical: Tokens.space4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Tokens.radiusMedium),
          borderSide: const BorderSide(color: Palette.surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Tokens.radiusMedium),
          borderSide: const BorderSide(color: Palette.surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Tokens.radiusMedium),
          borderSide: const BorderSide(color: Palette.accentBlue, width: 1.5),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? Palette.accentBlue : Palette.surfaceBorder,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Palette.surface,
        contentTextStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Tokens.radiusMedium),
          side: const BorderSide(color: Palette.surfaceBorder),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: Palette.accentBlue,
        unselectedItemColor: Palette.textMuted,
        type: BottomNavigationBarType.fixed,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Palette.surface,
        side: const BorderSide(color: Palette.surfaceBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Tokens.radiusStadium)),
        labelStyle: textTheme.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: Tokens.space3, vertical: Tokens.space1),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Palette.accentBlue,
        linearTrackColor: Palette.surfaceBorder,
      ),
    );
  }

  static TextTheme _textTheme() => const TextTheme(
        displaySmall: TextStyle(
          fontFamily: Tokens.fontFamily,
          fontSize: 34,
          fontWeight: FontWeight.w700,
          height: 1.15,
          color: Palette.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontFamily: Tokens.fontFamily,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Palette.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontFamily: Tokens.fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Palette.textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: Tokens.fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Palette.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontFamily: Tokens.fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Palette.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: Tokens.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Palette.textSecondary,
        ),
        bodySmall: TextStyle(
          fontFamily: Tokens.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Palette.textMuted,
        ),
        labelLarge: TextStyle(
          fontFamily: Tokens.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Palette.textPrimary,
        ),
      );
}
