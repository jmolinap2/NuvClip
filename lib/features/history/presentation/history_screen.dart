import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuvclip/app/theme/tokens.dart';
import 'package:nuvclip/core/providers.dart';
import 'package:nuvclip/core/utils/byte_format.dart';
import 'package:nuvclip/features/history/data/history_repository.dart';
import 'package:nuvclip/features/history/presentation/history_tile.dart';
import 'package:nuvclip/shared/widgets/glass.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

final _filterProvider = StateProvider.autoDispose((ref) => HistoryFilter.all);
final _queryProvider = StateProvider.autoDispose((ref) => '');

final _entriesProvider = StreamProvider.autoDispose((ref) {
  final filter = ref.watch(_filterProvider);
  final query = ref.watch(_queryProvider);
  return ref.watch(historyRepositoryProvider).watchEntries(filter: filter, query: query);
});

final _statsProvider = StreamProvider.autoDispose((ref) => ref.watch(historyRepositoryProvider).watchStats());

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(_entriesProvider);
    final statsAsync = ref.watch(_statsProvider);
    final filter = ref.watch(_filterProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Tokens.gutter, Tokens.space5, Tokens.gutter, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Historial', style: Theme.of(context).textTheme.displaySmall),
                  const SizedBox(height: Tokens.space1),
                  Text(
                    'Revisa tus descargas recientes',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Palette.textSecondary),
                  ),
                  const SizedBox(height: Tokens.space5),
                  statsAsync.maybeWhen(
                    data: (stats) => GlassCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: _Stat(icon: Icons.download_rounded, value: '${stats.count}', label: 'descargas'),
                          ),
                          const VerticalDivider(color: Palette.surfaceBorder),
                          Expanded(
                            child: _Stat(icon: Icons.folder_rounded, value: formatBytes(stats.totalBytes), label: 'ahorrados'),
                          ),
                        ],
                      ),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: Tokens.space4),
                  Row(
                    children: [
                      PillChip(
                        label: 'Todos',
                        icon: Icons.apps_rounded,
                        selected: filter == HistoryFilter.all,
                        onTap: () => ref.read(_filterProvider.notifier).state = HistoryFilter.all,
                      ),
                      const SizedBox(width: Tokens.space2),
                      PillChip(
                        label: 'TikTok',
                        selected: filter == HistoryFilter.tiktok,
                        onTap: () => ref.read(_filterProvider.notifier).state = HistoryFilter.tiktok,
                      ),
                      const SizedBox(width: Tokens.space2),
                      PillChip(
                        label: 'Instagram',
                        selected: filter == HistoryFilter.instagram,
                        onTap: () => ref.read(_filterProvider.notifier).state = HistoryFilter.instagram,
                      ),
                    ],
                  ),
                  const SizedBox(height: Tokens.space3),
                  TextField(
                    onChanged: (value) => ref.read(_queryProvider.notifier).state = value,
                    style: const TextStyle(fontFamily: Tokens.fontFamily, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Buscar en historial...',
                      prefixIcon: Icon(Icons.search_rounded, color: Palette.textMuted),
                    ),
                  ),
                  const SizedBox(height: Tokens.space4),
                ],
              ),
            ),
            Expanded(
              child: entriesAsync.when(
                data: (entries) {
                  if (entries.isEmpty) {
                    return Center(
                      child: Text('Sin descargas todavia.', style: Theme.of(context).textTheme.bodyMedium),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(Tokens.gutter, 0, Tokens.gutter, Tokens.space7),
                    itemCount: entries.length,
                    separatorBuilder: (context, index) => const SizedBox(height: Tokens.space3),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return HistoryTile(
                        entry: entry,
                        onOpen: () => launchUrl(Uri.parse(entry.savedUri), mode: LaunchMode.externalApplication),
                        onShare: () => SharePlus.instance.share(ShareParams(uri: Uri.parse(entry.savedUri))),
                        onDelete: () => ref.read(historyRepositoryProvider).removeFromHistory(entry.id),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('$error')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(Tokens.space2),
          decoration: BoxDecoration(color: Palette.background, borderRadius: BorderRadius.circular(Tokens.radiusSmall)),
          child: Icon(icon, color: Palette.accentBlue, size: 20),
        ),
        const SizedBox(width: Tokens.space2),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: Theme.of(context).textTheme.titleMedium),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}
