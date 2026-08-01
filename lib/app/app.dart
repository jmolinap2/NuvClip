import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nuvclip/app/bootstrap.dart';
import 'package:nuvclip/app/navigation/app_router.dart';
import 'package:nuvclip/app/theme/app_theme.dart';
import 'package:nuvclip/app/theme/tokens.dart';
import 'package:nuvclip/features/settings/domain/app_settings.dart';
import 'package:nuvclip/features/settings/presentation/settings_controller.dart';

final _routerProvider = Provider<GoRouter>((ref) => createRouter());

class NuvClipApp extends ConsumerStatefulWidget {
  const NuvClipApp({super.key});

  @override
  ConsumerState<NuvClipApp> createState() => _NuvClipAppState();
}

class _NuvClipAppState extends ConsumerState<NuvClipApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(bootstrapProvider.notifier).start());
  }

  @override
  Widget build(BuildContext context) {
    final themePreference = ref.watch(settingsControllerProvider.select((s) => s.themePreference));
    final router = ref.watch(_routerProvider);

    return MaterialApp.router(
      title: 'NuvClip',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: switch (themePreference) {
        ThemePreference.light => ThemeMode.light,
        ThemePreference.dark => ThemeMode.dark,
        ThemePreference.system => ThemeMode.system,
      },
      routerConfig: router,
      builder: (context, child) {
        final bootstrap = ref.watch(bootstrapProvider);
        // Un widget que revienta al construirse (por ejemplo, un
        // DateFormat sin locale inicializado) por defecto pinta un
        // rectangulo gris silencioso en release, sin ninguna pista de que
        // algo fallo. Una tarjeta visible, aunque generica, es mucho mas
        // facil de reportar y diagnosticar que un hueco gris.
        ErrorWidget.builder = (details) => _BuildErrorCard(details: details);
        return Stack(
          children: [
            ?child,
            // Cubre la pantalla hasta que el motor nativo termine de
            // inicializarse (extraer yt-dlp/ffmpeg la primera vez tarda un
            // poco). Sin esto el usuario podria tocar "Analizar enlace"
            // antes de que el motor este listo.
            if (!bootstrap.isReady) const _SplashOverlay(),
          ],
        );
      },
    );
  }
}

class _BuildErrorCard extends StatelessWidget {
  const _BuildErrorCard({required this.details});

  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Palette.danger.withValues(alpha: 0.12),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(Tokens.space3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: Palette.danger, size: 20),
              const SizedBox(height: Tokens.space1),
              Text(
                'No se pudo mostrar esta seccion',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Palette.danger),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplashOverlay extends StatelessWidget {
  const _SplashOverlay();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Palette.background,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(Tokens.space4),
              decoration: BoxDecoration(gradient: Palette.brandGradient, borderRadius: BorderRadius.circular(Tokens.radiusLarge)),
              child: const Icon(Icons.file_download_rounded, color: Colors.white, size: 32),
            ),
            const SizedBox(height: Tokens.space5),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: Palette.accentBlue),
            ),
          ],
        ),
      ),
    );
  }
}
