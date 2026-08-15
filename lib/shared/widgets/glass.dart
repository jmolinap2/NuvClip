import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nuvclip/app/theme/tokens.dart';
import 'package:nuvclip/core/platform/download_engine.g.dart';

/// Tarjeta translucida con blur sutil, la unidad visual base de las tres
/// pantallas (tarjetas de historial, bloque de vista previa, filas de
/// ajustes).
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Tokens.space5),
    this.borderColor,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = ClipRRect(
      borderRadius: BorderRadius.circular(Tokens.radiusLarge),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Palette.surface.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(Tokens.radiusLarge),
            border: Border.all(color: borderColor ?? Palette.surfaceBorder),
          ),
          child: child,
        ),
      ),
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(Tokens.radiusLarge),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Tokens.radiusLarge),
        child: content,
      ),
    );
  }
}

/// Boton de accion principal ("Analizar enlace", "Descargar video"): el
/// unico elemento que lleva el degradado de marca a pantalla completa.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return Opacity(
      opacity: enabled || loading ? 1 : 0.45,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: Palette.brandGradient,
          borderRadius: BorderRadius.circular(Tokens.radiusStadium),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: Palette.accentViolet.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ]
              : const [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(Tokens.radiusStadium),
            onTap: enabled ? onPressed : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Tokens.space4),
              child: Center(
                child: loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null) ...[
                            Icon(icon, color: Colors.white, size: 20),
                            const SizedBox(width: Tokens.space2),
                          ],
                          Text(
                            label,
                            style: const TextStyle(
                              fontFamily: Tokens.fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Boton secundario de contorno, para acciones que acompañan a la principal
/// ("Copiar enlace", "Ver todo").
class OutlineActionButton extends StatelessWidget {
  const OutlineActionButton({super.key, required this.label, required this.onPressed, this.icon});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon, size: 18) : const SizedBox.shrink(),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: Palette.textPrimary,
          side: const BorderSide(color: Palette.surfaceBorder),
          padding: const EdgeInsets.symmetric(vertical: Tokens.space4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Tokens.radiusStadium)),
        ),
      ),
    );
  }
}

/// Texto con el degradado de marca aplicado via ShaderMask, usado en el
/// wordmark "Nuv[Clip]" y en el titulo "Descarga [tus videos]".
class GradientText extends StatelessWidget {
  const GradientText(this.text, {super.key, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => Palette.brandGradient.createShader(bounds),
      child: Text(text, style: style.copyWith(color: Colors.white)),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text, style: Theme.of(context).textTheme.headlineSmall),
        ?trailing,
      ],
    );
  }
}

/// Chip pequeño usado para "Compatible con TikTok / Instagram / Facebook / YouTube" y para el
/// filtro de plataforma en el historial.
class PillChip extends StatelessWidget {
  const PillChip({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.onTap,
    this.iconColor,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Tokens.radiusStadium),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: Tokens.space4, vertical: Tokens.space2),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: selected ? Palette.brandGradient : null,
            color: selected ? null : Palette.surface,
            borderRadius: BorderRadius.circular(Tokens.radiusStadium),
            border: Border.all(color: selected ? Colors.transparent : Palette.surfaceBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: selected ? Colors.white : (iconColor ?? Palette.textSecondary)),
                const SizedBox(width: Tokens.space2),
              ],
              Text(
                label,
                style: TextStyle(
                  fontFamily: Tokens.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : Palette.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Glifo generico por plataforma, usado tanto por [PlatformBadge] como por
/// los chips de vista previa/historial, para no repetir el mismo switch en
/// cada pantalla.
IconData platformIcon(SourcePlatform platform) => switch (platform) {
      SourcePlatform.tiktok => Icons.music_note_rounded,
      SourcePlatform.instagram => Icons.camera_alt_rounded,
      SourcePlatform.facebook => Icons.thumb_up_rounded,
      SourcePlatform.youtube => Icons.play_arrow_rounded,
      SourcePlatform.unknown => Icons.link_rounded,
    };

/// Insignia de plataforma reconocible sin usar los logotipos registrados de
/// TikTok/Instagram/Facebook/YouTube: un glifo generico dentro de una
/// insignia con los colores de marca de cada plataforma. Decision
/// deliberada para no empaquetar assets de marcas de terceros.
class PlatformBadge extends StatelessWidget {
  const PlatformBadge({super.key, required this.platform, this.size = 22});

  final SourcePlatform platform;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: switch (platform) {
          SourcePlatform.tiktok => Colors.black,
          SourcePlatform.facebook => const Color(0xFF1877F2),
          SourcePlatform.youtube => const Color(0xFFFF0000),
          SourcePlatform.instagram => null,
          SourcePlatform.unknown => Palette.surfaceBorder,
        },
        gradient: platform == SourcePlatform.instagram
            ? const LinearGradient(
                colors: [Color(0xFFFEDA75), Color(0xFFD62976), Color(0xFF4F5BD5)],
              )
            : null,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(
        platformIcon(platform),
        size: size * 0.62,
        color: Colors.white,
      ),
    );
  }
}
