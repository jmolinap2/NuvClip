import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nuvclip/app/theme/tokens.dart';
import 'package:nuvclip/core/errors/error_messages.dart';
import 'package:nuvclip/core/platform/download_engine.g.dart';
import 'package:nuvclip/core/platform/url_helper.dart';
import 'package:nuvclip/core/utils/byte_format.dart';
import 'package:nuvclip/core/utils/duration_format.dart';
import 'package:nuvclip/features/downloader/domain/download_job.dart';
import 'package:nuvclip/features/downloader/presentation/download_controller.dart';
import 'package:nuvclip/shared/widgets/glass.dart';

class PreviewScreen extends ConsumerWidget {
  const PreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(downloadControllerProvider);
    final analysis = state.analysis;

    return Scaffold(
      appBar: AppBar(title: const Text('Vista previa')),
      body: analysis == null
          ? const Center(child: Text('No hay un video analizado.'))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(Tokens.gutter, Tokens.space4, Tokens.gutter, Tokens.space7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _VideoPreview(analysis: analysis),
                    const SizedBox(height: Tokens.space5),
                    Text(analysis.title, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: Tokens.space4),
                    _InfoRow(analysis: analysis, selectedFormat: state.selectedFormat),
                    const SizedBox(height: Tokens.space6),
                    switch (state.stage) {
                      DownloadStage.downloading => _DownloadingSection(state: state),
                      DownloadStage.completed => const _CompletedSection(),
                      DownloadStage.failed => _FailedSection(state: state),
                      _ => _QualitySection(analysis: analysis, state: state),
                    },
                  ],
                ),
              ),
            ),
    );
  }
}

class _VideoPreview extends StatelessWidget {
  const _VideoPreview({required this.analysis});

  final VideoAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(Tokens.radiusLarge),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (analysis.thumbnailUrl != null)
              Image.network(
                analysis.thumbnailUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => const ColoredBox(color: Palette.surface),
              )
            else
              const ColoredBox(color: Palette.surface),
            Positioned(
              top: Tokens.space3,
              left: Tokens.space3,
              child: PillChip(
                label: platformLabel(analysis.platform),
                icon: platformIcon(analysis.platform),
              ),
            ),
            if (analysis.author != null)
              Positioned(
                top: Tokens.space3,
                right: Tokens.space3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: Tokens.space2, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(Tokens.radiusStadium)),
                  child: Text('@${analysis.author}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ),
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), shape: BoxShape.circle),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
              ),
            ),
            Positioned(
              left: Tokens.space3,
              bottom: Tokens.space3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: Tokens.space2, vertical: 2),
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(6)),
                child: Text(
                  formatDuration(analysis.durationSeconds),
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.analysis, required this.selectedFormat});

  final VideoAnalysis analysis;
  final VideoFormatOption? selectedFormat;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: Tokens.space4, vertical: Tokens.space3),
      child: Row(
        children: [
          Expanded(
            child: _InfoItem(
              icon: Icons.person_outline_rounded,
              label: 'Autor',
              value: analysis.author ?? 'Desconocido',
            ),
          ),
          const VerticalDivider(color: Palette.surfaceBorder),
          Expanded(
            child: _InfoItem(
              icon: Icons.schedule_rounded,
              label: 'Duracion',
              value: formatDuration(analysis.durationSeconds),
            ),
          ),
          const VerticalDivider(color: Palette.surfaceBorder),
          Expanded(
            child: _InfoItem(
              icon: Icons.sd_storage_rounded,
              label: 'Tamano estimado',
              value: selectedFormat?.approxSizeBytes != null ? formatBytes(selectedFormat!.approxSizeBytes!) : '--',
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Icon(icon, size: 14, color: Palette.textMuted), const SizedBox(width: 4), Text(label, style: Theme.of(context).textTheme.bodySmall)]),
        const SizedBox(height: 4),
        Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _QualitySection extends ConsumerWidget {
  const _QualitySection({required this.analysis, required this.state});

  final VideoAnalysis analysis;
  final DownloadJobState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(downloadControllerProvider.notifier);
    final formats = state.audioOnly ? analysis.audioFormats : analysis.formats;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: PillChip(
                label: 'Video',
                icon: Icons.videocam_rounded,
                selected: !state.audioOnly,
                onTap: () => controller.setAudioOnly(false),
              ),
            ),
            const SizedBox(width: Tokens.space2),
            Expanded(
              child: PillChip(
                label: 'Solo audio',
                icon: Icons.music_note_rounded,
                selected: state.audioOnly,
                onTap: () => controller.setAudioOnly(true),
              ),
            ),
          ],
        ),
        const SizedBox(height: Tokens.space5),
        Text('Calidad', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: Tokens.space3),
        Row(
          children: [
            for (final format in formats) ...[
              Expanded(
                child: _QualityOption(
                  audioOnly: state.audioOnly,
                  format: format,
                  selected: state.selectedFormat?.formatId == format.formatId,
                  onTap: () => controller.selectFormat(format),
                ),
              ),
              if (format != formats.last) const SizedBox(width: Tokens.space2),
            ],
          ],
        ),
        const SizedBox(height: Tokens.space6),
        GradientButton(
          label: state.audioOnly ? 'Descargar audio' : 'Descargar video',
          icon: state.audioOnly ? Icons.audiotrack_rounded : Icons.download_rounded,
          onPressed: state.selectedFormat == null ? null : controller.startDownload,
        ),
        const SizedBox(height: Tokens.space3),
        OutlineActionButton(
          label: 'Copiar enlace',
          icon: Icons.link_rounded,
          onPressed: () {
            Clipboard.setData(ClipboardData(text: analysis.sourceUrl));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enlace copiado')));
          },
        ),
      ],
    );
  }
}

class _QualityOption extends StatelessWidget {
  const _QualityOption({required this.audioOnly, required this.format, required this.selected, required this.onTap});

  final bool audioOnly;
  final VideoFormatOption format;
  final bool selected;
  final VoidCallback onTap;

  int get _audioKbps => int.tryParse(format.formatId.replaceFirst('audio-', '')) ?? 0;

  String get _tag => audioOnly ? 'MP3' : ((format.height ?? 0) >= 720 ? 'HD' : 'SD');

  String get _hint {
    if (audioOnly) {
      if (_audioKbps >= 192) return 'Mejor calidad';
      if (_audioKbps >= 128) return 'Buena calidad';
      return 'Tamano menor';
    }
    final height = format.height ?? 0;
    if (height >= 1080) return 'Mejor calidad';
    if (height >= 720) return 'Buena calidad';
    return 'Tamano menor';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Tokens.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(Tokens.space3),
        decoration: BoxDecoration(
          color: Palette.surface,
          borderRadius: BorderRadius.circular(Tokens.radiusMedium),
          border: Border.all(color: selected ? Palette.accentBlue : Palette.surfaceBorder, width: selected ? 1.5 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Palette.background, borderRadius: BorderRadius.circular(6)),
                  child: Text(_tag, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Palette.accentBlue)),
                ),
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  size: 18,
                  color: selected ? Palette.accentBlue : Palette.textMuted,
                ),
              ],
            ),
            const SizedBox(height: Tokens.space2),
            Text(format.qualityLabel, style: Theme.of(context).textTheme.titleMedium),
            Text(_hint, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _DownloadingSection extends ConsumerWidget {
  const _DownloadingSection({required this.state});

  final DownloadJobState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final percent = state.progressPercent.clamp(0, 100);
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Descargando...', style: Theme.of(context).textTheme.titleMedium),
              Text('${percent.toStringAsFixed(0)}%', style: const TextStyle(color: Palette.accentBlue, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: Tokens.space3),
          ClipRRect(
            borderRadius: BorderRadius.circular(Tokens.radiusStadium),
            child: LinearProgressIndicator(value: percent / 100, minHeight: 8),
          ),
          const SizedBox(height: Tokens.space3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                state.totalBytesLabel,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (state.etaSeconds != null)
                Text('Quedan ${formatDuration(state.etaSeconds!)}', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: Tokens.space5),
          OutlineActionButton(
            label: 'Cancelar descarga',
            icon: Icons.close_rounded,
            onPressed: () => ref.read(downloadControllerProvider.notifier).cancel(),
          ),
        ],
      ),
    );
  }
}

extension on DownloadJobState {
  String get totalBytesLabel {
    final total = selectedFormat?.approxSizeBytes;
    if (total == null) return formatBytes(downloadedBytes);
    return '${formatBytes(downloadedBytes)} de ${formatBytes(total)}';
  }
}

class _CompletedSection extends ConsumerWidget {
  const _CompletedSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      borderColor: Palette.success,
      child: Column(
        children: [
          const Icon(Icons.check_circle_rounded, color: Palette.success, size: 40),
          const SizedBox(height: Tokens.space3),
          Text('Video guardado', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: Tokens.space1),
          Text(
            'Se guardo en Descargas/NuvClip',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Tokens.space5),
          GradientButton(
            label: 'Ver en Historial',
            icon: Icons.history_rounded,
            onPressed: () {
              ref.read(downloadControllerProvider.notifier).reset();
              context.go('/history');
            },
          ),
          const SizedBox(height: Tokens.space3),
          OutlineActionButton(
            label: 'Descargar otro video',
            icon: Icons.add_rounded,
            onPressed: () {
              ref.read(downloadControllerProvider.notifier).reset();
              context.pop();
            },
          ),
        ],
      ),
    );
  }
}

class _FailedSection extends ConsumerWidget {
  const _FailedSection({required this.state});

  final DownloadJobState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      borderColor: Palette.danger,
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, color: Palette.danger, size: 40),
          const SizedBox(height: Tokens.space3),
          Text(
            state.errorCode != null ? userMessageFor(state.errorCode!) : 'Algo salio mal.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: Tokens.space5),
          OutlineActionButton(
            label: 'Volver',
            icon: Icons.arrow_back_rounded,
            onPressed: () {
              ref.read(downloadControllerProvider.notifier).reset();
              context.pop();
            },
          ),
        ],
      ),
    );
  }
}
