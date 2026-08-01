import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuvclip/app/theme/tokens.dart';
import 'package:nuvclip/core/db/database.dart';
import 'package:nuvclip/core/platform/download_engine.g.dart';
import 'package:nuvclip/core/utils/byte_format.dart';
import 'package:nuvclip/core/utils/duration_format.dart';
import 'package:nuvclip/shared/widgets/glass.dart';

final _dateFormat = DateFormat('d MMM yyyy', 'es');

class HistoryTile extends StatelessWidget {
  const HistoryTile({
    super.key,
    required this.entry,
    required this.onOpen,
    required this.onShare,
    required this.onDelete,
  });

  final HistoryEntry entry;
  final VoidCallback onOpen;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(Tokens.space3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Thumbnail(url: entry.thumbnailUrl, durationSeconds: entry.durationSeconds),
          const SizedBox(width: Tokens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: Tokens.space1),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 12, color: Palette.textMuted),
                    const SizedBox(width: 4),
                    Text(_dateFormat.format(entry.downloadedAt), style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(width: Tokens.space2),
                    Icon(Icons.schedule_rounded, size: 12, color: Palette.textMuted),
                    const SizedBox(width: 4),
                    Text(formatDuration(entry.durationSeconds), style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: Tokens.space2),
                Row(
                  children: [
                    PlatformBadge(isTikTok: entry.platform == SourcePlatform.tiktok, size: 18),
                    const SizedBox(width: Tokens.space2),
                    Text(formatBytes(entry.sizeBytes), style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: onOpen,
                icon: const Icon(Icons.play_circle_fill_rounded),
                color: Palette.accentBlue,
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: Palette.textMuted),
                color: Palette.surface,
                onSelected: (value) {
                  if (value == 'share') onShare();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'share', child: Text('Compartir')),
                  PopupMenuItem(value: 'delete', child: Text('Eliminar del historial')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.url, required this.durationSeconds});

  final String? url;
  final int durationSeconds;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(Tokens.radiusMedium),
      child: SizedBox(
        width: 64,
        height: 64,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (url != null && url!.isNotEmpty)
              Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => const _ThumbnailFallback(),
              )
            else
              const _ThumbnailFallback(),
            Positioned(
              left: 4,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  formatDuration(durationSeconds),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThumbnailFallback extends StatelessWidget {
  const _ThumbnailFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Palette.surface,
      child: Icon(Icons.movie_rounded, color: Palette.textMuted),
    );
  }
}
