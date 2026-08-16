import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nuvclip/app/theme/tokens.dart';
import 'package:nuvclip/core/errors/error_messages.dart';
import 'package:nuvclip/core/platform/download_engine.g.dart';
import 'package:nuvclip/core/platform/share_intent_service.dart';
import 'package:nuvclip/core/platform/url_helper.dart';
import 'package:nuvclip/core/providers.dart';
import 'package:nuvclip/features/downloader/domain/download_job.dart';
import 'package:nuvclip/features/downloader/presentation/download_controller.dart';
import 'package:nuvclip/features/history/presentation/history_tile.dart';
import 'package:nuvclip/shared/widgets/glass.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver {
  late final TextEditingController _linkController;
  static const _shareIntent = ShareIntentService();

  @override
  void initState() {
    super.initState();
    _linkController = TextEditingController(text: ref.read(downloadControllerProvider).url);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _consumeSharedLink());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _linkController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Compartir un enlace hacia una instancia de NuvClip que ya esta abierta
    // entrega el intent por `onNewIntent`, no relanza la pantalla: el
    // momento en que Flutter se entera es al volver a primer plano.
    if (state == AppLifecycleState.resumed) _consumeSharedLink();
  }

  Future<void> _consumeSharedLink() async {
    final shared = await _shareIntent.takeSharedText();
    if (shared == null || shared.trim().isEmpty || !mounted) return;
    _linkController.text = shared.trim();
    ref.read(downloadControllerProvider.notifier).setUrl(shared.trim());
    await _analyze();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) return;
    _linkController.text = text;
    ref.read(downloadControllerProvider.notifier).setUrl(text);
  }

  Future<void> _analyze() async {
    final controller = ref.read(downloadControllerProvider.notifier);
    controller.setUrl(_linkController.text);
    await controller.analyze();
    final state = ref.read(downloadControllerProvider);
    if (!mounted) return;
    if (state.stage == DownloadStage.analyzed) {
      context.push('/preview');
    } else if (state.stage == DownloadStage.failed && state.errorCode != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userMessageFor(state.errorCode!))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobState = ref.watch(downloadControllerProvider);
    final platform = detectPlatform(_linkController.text);

    ref.listen(downloadControllerProvider, (previous, next) {
      if (next.stage == DownloadStage.failed &&
          previous?.stage != DownloadStage.failed &&
          next.errorCode != null &&
          ModalRoute.of(context)?.isCurrent == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userMessageFor(next.errorCode!))),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(Tokens.gutter, Tokens.space5, Tokens.gutter, Tokens.space7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(onSettingsTap: () => context.go('/settings')),
              const SizedBox(height: Tokens.space7),
              Text('Descarga', style: Theme.of(context).textTheme.displaySmall),
              GradientText('tus videos', style: Theme.of(context).textTheme.displaySmall!),
              const SizedBox(height: Tokens.space2),
              Text(
                'Guarda contenido publico sin anuncios ni suscripciones',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Palette.textSecondary),
              ),
              const SizedBox(height: Tokens.space6),
              _LinkField(controller: _linkController, onPaste: _pasteFromClipboard, onChanged: (_) => setState(() {})),
              const SizedBox(height: Tokens.space4),
              GradientButton(
                label: jobState.updatingExtractor ? 'Actualizando extractor...' : 'Analizar enlace',
                icon: Icons.auto_awesome_rounded,
                loading: jobState.stage == DownloadStage.analyzing,
                onPressed: _linkController.text.trim().isEmpty ? null : _analyze,
              ),
              const SizedBox(height: Tokens.space5),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: Tokens.space2,
                children: [
                  Text('Compatible con', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(width: Tokens.space3),
                  const PlatformBadge(platform: SourcePlatform.tiktok, size: 20),
                  const SizedBox(width: Tokens.space1),
                  const Text('TikTok', style: TextStyle(color: Palette.textSecondary, fontSize: 13)),
                  const SizedBox(width: Tokens.space3),
                  const PlatformBadge(platform: SourcePlatform.instagram, size: 20),
                  const SizedBox(width: Tokens.space1),
                  const Text('Instagram', style: TextStyle(color: Palette.textSecondary, fontSize: 13)),
                  const SizedBox(width: Tokens.space3),
                  const PlatformBadge(platform: SourcePlatform.facebook, size: 20),
                  const SizedBox(width: Tokens.space1),
                  const Text('Facebook', style: TextStyle(color: Palette.textSecondary, fontSize: 13)),
                  const SizedBox(width: Tokens.space3),
                  const PlatformBadge(platform: SourcePlatform.youtube, size: 20),
                  const SizedBox(width: Tokens.space1),
                  const Text('YouTube', style: TextStyle(color: Palette.textSecondary, fontSize: 13)),
                ],
              ),
              if (platform == SourcePlatform.unknown && _linkController.text.trim().isNotEmpty) ...[
                const SizedBox(height: Tokens.space2),
                Text(
                  'Ese enlace no parece ser de TikTok, Instagram, Facebook ni YouTube.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Palette.danger),
                ),
              ],
              const SizedBox(height: Tokens.space7),
              SectionLabel(
                'Recientes',
                trailing: TextButton(
                  onPressed: () => context.go('/history'),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Text('Ver todo'), Icon(Icons.chevron_right_rounded, size: 18)],
                  ),
                ),
              ),
              const SizedBox(height: Tokens.space3),
              _RecentList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onSettingsTap});

  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(Tokens.space2),
              decoration: BoxDecoration(gradient: Palette.brandGradient, borderRadius: BorderRadius.circular(Tokens.radiusMedium)),
              child: const Icon(Icons.file_download_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: Tokens.space2),
            Text('Nuv', style: Theme.of(context).textTheme.headlineMedium),
            GradientText('Clip', style: Theme.of(context).textTheme.headlineMedium!),
          ],
        ),
        IconButton.filled(
          onPressed: onSettingsTap,
          style: IconButton.styleFrom(backgroundColor: Palette.surface),
          icon: const Icon(Icons.settings_rounded, color: Palette.textPrimary),
        ),
      ],
    );
  }
}

class _LinkField extends StatelessWidget {
  const _LinkField({required this.controller, required this.onPaste, required this.onChanged});

  final TextEditingController controller;
  final VoidCallback onPaste;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(fontFamily: Tokens.fontFamily, fontSize: 14, color: Palette.textPrimary),
      decoration: InputDecoration(
        hintText: 'Pega un enlace de TikTok, Instagram, Facebook o YouTube',
        prefixIcon: const Icon(Icons.link_rounded, color: Palette.textMuted),
        suffixIcon: Padding(
          padding: const EdgeInsets.all(Tokens.space1),
          child: TextButton(onPressed: onPaste, child: const Text('Pegar')),
        ),
      ),
    );
  }
}

class _RecentList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(_recentEntriesProvider);
    return entriesAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return GlassCard(
            child: Text(
              'Tus descargas apareceran aqui.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }
        return Column(
          children: [
            for (final entry in entries) ...[
              HistoryTile(
                entry: entry,
                onOpen: () => _openEntry(context, entry.savedUri),
                onShare: () => SharePlus.instance.share(ShareParams(uri: Uri.parse(entry.savedUri))),
                onDelete: () => ref.read(historyRepositoryProvider).removeFromHistory(entry.id),
              ),
              const SizedBox(height: Tokens.space3),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  void _openEntry(BuildContext context, String uri) {
    launchUrl(Uri.parse(uri), mode: LaunchMode.externalApplication);
  }
}

final _recentEntriesProvider = StreamProvider.autoDispose((ref) {
  return ref.watch(historyRepositoryProvider).watchEntries().map((entries) => entries.take(2).toList());
});
