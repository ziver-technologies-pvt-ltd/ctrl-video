import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import '../../app/theme.dart';
import '../../data/database.dart';
import '../../main.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filterQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFile(String? path) async {
    if (path == null) {
      _showSnack('No file recorded.');
      return;
    }

    final file = File(path);
    if (file.existsSync()) {
      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done && Platform.isLinux) {
        await Process.run('xdg-open', [file.path]);
      }
    } else {
      _showSnack('File not found on disk ($path).');
    }
  }

  Future<void> _openFolder(String? path) async {
    if (path == null) {
      _showSnack('No path recorded.');
      return;
    }

    String folderPath = path;
    if (File(path).existsSync()) {
      folderPath = File(path).parent.path;
    } else if (!Directory(path).existsSync() && path.contains('/')) {
      final parent = Directory(path).parent;
      if (parent.existsSync()) {
        folderPath = parent.path;
      }
    }

    if (Directory(folderPath).existsSync()) {
      final result = await OpenFilex.open(folderPath);
      if (result.type != ResultType.done && Platform.isLinux) {
        await Process.run('xdg-open', [folderPath]);
      }
    } else {
      _showSnack('Folder not found on disk ($folderPath).');
    }
  }

  void _showSnack(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  String _formatDateTime(DateTime dt) {
    final local = dt.toLocal();
    final y = local.year;
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }

  String _formatElapsed(DateTime start, DateTime? end) {
    if (end == null) return '';
    final diff = end.difference(start);
    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s';
    }
    final mins = diff.inMinutes;
    final secs = diff.inSeconds.remainder(60);
    return '${mins}m ${secs}s';
  }

  String _formatFileSize(int? bytes) {
    if (bytes == null || bytes <= 0) return '';
    final mb = bytes / (1024 * 1024);
    if (mb >= 1024) {
      return '${(mb / 1024).toStringAsFixed(1)} GB';
    }
    return '${mb.toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final theme = Theme.of(context);

    return StreamBuilder<List<DownloadRecord>>(
      stream: db.watchAllHistory(),
      builder: (context, snapshot) {
        final records = snapshot.data ?? [];
        final filtered = records.where((r) {
          if (_filterQuery.isEmpty) return true;
          return r.title.toLowerCase().contains(_filterQuery.toLowerCase()) ||
              r.platform.toLowerCase().contains(_filterQuery.toLowerCase());
        }).toList();

        return Column(
          children: [
            // Search Bar & Clear Action
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: 'Search history by title or platform...',
                        prefixIcon: Icon(Icons.search_rounded, size: 20),
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _filterQuery = val.trim();
                        });
                      },
                    ),
                  ),
                  if (records.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                      label: const Text('Clear All'),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Clear History'),
                            content: const Text('Remove all download records from history?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Clear'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await db.clearHistory();
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),

            // History Records List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.history_rounded, size: 52, color: theme.colorScheme.outlineVariant),
                          const SizedBox(height: 12),
                          Text(
                            _filterQuery.isNotEmpty ? 'No matches found' : 'No download history yet',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final record = filtered[index];
                        final isDone = record.status == 'completed';
                        final elapsed = _formatElapsed(record.createdAt, record.completedAt);
                        final size = _formatFileSize(record.sizeBytes);

                        return Card(
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Thumbnail
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: record.thumbnailUrl != null
                                      ? Image.network(
                                          record.thumbnailUrl!,
                                          width: 72,
                                          height: 48,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            width: 72,
                                            height: 48,
                                            color: theme.colorScheme.surfaceContainerHighest,
                                            child: const Icon(Icons.movie_outlined, size: 24),
                                          ),
                                        )
                                      : Container(
                                          width: 72,
                                          height: 48,
                                          color: theme.colorScheme.surfaceContainerHighest,
                                          child: const Icon(Icons.movie_outlined, size: 24),
                                        ),
                                ),
                                const SizedBox(width: 14),

                                // Title, Meta & Date Information
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        record.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primaryContainer,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              record.platform,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: theme.colorScheme.onPrimaryContainer,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              record.formatLabel,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: theme.colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                          if (size.isNotEmpty) ...[
                                            const SizedBox(width: 6),
                                            Text('• $size', style: AppTheme.monoStyle.copyWith(fontSize: 11)),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      // Date & Download Duration Row
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today_rounded, size: 12, color: theme.colorScheme.outline),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatDateTime(record.createdAt),
                                            style: AppTheme.monoStyle.copyWith(
                                              fontSize: 11,
                                              color: theme.colorScheme.outline,
                                            ),
                                          ),
                                          if (elapsed.isNotEmpty) ...[
                                            const SizedBox(width: 8),
                                            Icon(Icons.timer_outlined, size: 12, color: theme.colorScheme.outline),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Took $elapsed',
                                              style: AppTheme.monoStyle.copyWith(
                                                fontSize: 11,
                                                color: theme.colorScheme.outline,
                                              ),
                                            ),
                                          ],
                                          if (record.trimStartMs != null && record.trimEndMs != null) ...[
                                            const SizedBox(width: 8),
                                            Icon(Icons.content_cut_rounded, size: 12, color: AppColors.accent),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Trimmed (${record.trimMode ?? "clip"})',
                                              style: AppTheme.monoStyle.copyWith(
                                                fontSize: 11,
                                                color: AppColors.accent,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Actions
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isDone && record.filePath != null) ...[
                                      IconButton(
                                        tooltip: 'Open File',
                                        icon: const Icon(Icons.play_circle_outline_rounded, size: 20),
                                        onPressed: () => _openFile(record.filePath),
                                      ),
                                      IconButton(
                                        tooltip: 'Open Folder',
                                        icon: const Icon(Icons.folder_open_rounded, size: 20),
                                        onPressed: () => _openFolder(record.filePath),
                                      ),
                                    ],
                                    IconButton(
                                      tooltip: 'Delete Record',
                                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                                      onPressed: () => db.deleteRecord(record.id),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
