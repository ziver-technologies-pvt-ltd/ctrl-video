import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
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
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search history by title or platform...',
                        prefixIcon: Icon(Icons.search_rounded, size: 20),
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                          Icon(Icons.history_rounded, size: 52, color: theme.colorScheme.outline),
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
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final record = filtered[index];
                        final isDone = record.status == 'completed';

                        return Card(
                          child: ListTile(
                            leading: record.thumbnailUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(
                                      record.thumbnailUrl!,
                                      width: 60,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.movie_outlined),
                                    ),
                                  )
                                : const Icon(Icons.movie_outlined),
                            title: Text(
                              record.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            subtitle: Text(
                              '${record.platform} • ${record.formatLabel} • ${record.status}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDone ? Colors.green : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            trailing: Row(
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
