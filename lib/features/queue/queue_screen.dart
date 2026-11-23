import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/download_execution_service.dart';
import '../../services/download_manager.dart';
import '../../main.dart';

class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manager = ref.watch(downloadManagerProvider);
    final theme = Theme.of(context);
    final items = manager.queue;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              'No downloads in queue',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Paste a video link on the Download tab to start',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        final isDownloading = item.status == DownloadStatus.downloading;
        final isCompleted = item.status == DownloadStatus.completed;
        final isFailed = item.status == DownloadStatus.failed;
        final isCancelled = item.status == DownloadStatus.cancelled;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Small thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: item.mediaInfo.thumbnailUrl != null
                          ? Image.network(
                              item.mediaInfo.thumbnailUrl!,
                              width: 80,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 80,
                                height: 50,
                                color: theme.colorScheme.surfaceContainerHighest,
                                child: const Icon(Icons.movie_outlined, size: 24),
                              ),
                            )
                          : Container(
                              width: 80,
                              height: 50,
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.movie_outlined, size: 24),
                            ),
                    ),
                    const SizedBox(width: 14),

                    // Title & format
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.mediaInfo.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.mediaInfo.platform} • ${item.format.label}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Actions
                    if (isDownloading)
                      IconButton(
                        tooltip: 'Cancel',
                        icon: const Icon(Icons.close_rounded, color: Colors.red),
                        onPressed: () => manager.cancelTask(item),
                      )
                    else if (isFailed || isCancelled)
                      IconButton(
                        tooltip: 'Retry',
                        icon: const Icon(Icons.refresh_rounded),
                        onPressed: () => manager.retryTask(item),
                      )
                    else if (isCompleted)
                      IconButton(
                        tooltip: 'Dismiss',
                        icon: const Icon(Icons.check_rounded, color: Colors.green),
                        onPressed: () => manager.removeCompleted(item),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Progress Bar
                LinearProgressIndicator(
                  value: isCompleted
                      ? 1.0
                      : isDownloading
                          ? (item.progress.percent / 100.0).clamp(0.0, 1.0)
                          : 0.0,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                  color: isCompleted
                      ? Colors.green
                      : isFailed
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                ),
                const SizedBox(height: 6),

                // Metrics row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isCompleted
                          ? 'Completed'
                          : isDownloading
                              ? '${item.progress.percent.toStringAsFixed(1)}% • ${item.progress.speed}'
                              : isFailed
                                  ? (item.error ?? 'Download failed')
                                  : isCancelled
                                      ? 'Cancelled'
                                      : 'Waiting in queue...',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isCompleted
                            ? Colors.green
                            : isFailed
                                ? theme.colorScheme.error
                                : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (isDownloading)
                      Text(
                        'ETA: ${item.progress.eta}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
