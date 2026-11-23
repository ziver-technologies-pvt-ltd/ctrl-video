import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/path_resolver.dart';
import '../../main.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _downloadDir = '';
  int _concurrency = 2;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final db = ref.read(databaseProvider);
    final savedDir = await db.getSetting('downloadDir');
    final savedConcurrency = await db.getSetting('concurrency');

    if (savedDir != null && savedDir.isNotEmpty) {
      _downloadDir = savedDir;
    } else {
      final defaultDir = await PathResolver.getDefaultDownloadsDirectory();
      _downloadDir = defaultDir.path;
    }

    if (savedConcurrency != null) {
      _concurrency = int.tryParse(savedConcurrency) ?? 2;
    }

    if (mounted) setState(() {});
  }

  Future<void> _pickDirectory() async {
    final selected = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select Download Folder',
    );
    if (selected != null) {
      setState(() {
        _downloadDir = selected;
      });
      final db = ref.read(databaseProvider);
      await db.setSetting('downloadDir', selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final engineManager = ref.watch(engineManagerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Settings', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              // Download Directory
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Download Directory', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(
                        'Where downloaded videos and audio files are saved.',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _downloadDir.isNotEmpty ? _downloadDir : 'Loading...',
                                style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton.tonalIcon(
                            onPressed: _pickDirectory,
                            icon: const Icon(Icons.folder_open_rounded, size: 18),
                            label: const Text('Change'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Concurrency
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Concurrent Downloads', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(
                            'Maximum number of simultaneous active downloads.',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                      DropdownButton<int>(
                        value: _concurrency,
                        items: [1, 2, 3, 4].map((n) {
                          return DropdownMenuItem(value: n, child: Text('$n downloads'));
                        }).toList(),
                        onChanged: (val) async {
                          if (val != null) {
                            setState(() => _concurrency = val);
                            final db = ref.read(databaseProvider);
                            await db.setSetting('concurrency', val.toString());
                            ref.read(downloadManagerProvider).setMaxConcurrent(val);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Engine Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Engine Version', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(
                            'yt-dlp: ${engineManager.ytDlpVersion ?? "local sidecar"}',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.sync_rounded, size: 18),
                        label: const Text('Check for Updates'),
                        onPressed: () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Checking engine updates...')),
                          );
                          await engineManager.ensureEngineReady();
                          if (mounted) setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
