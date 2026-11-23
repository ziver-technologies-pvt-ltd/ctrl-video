import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/app_logger.dart';
import '../../services/engine_manager.dart';
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
  bool _isUpdatingEngine = false;
  double? _updateProgress;
  String? _updateMessage;

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

  Future<void> _triggerEngineUpdate() async {
    setState(() {
      _isUpdatingEngine = true;
      _updateProgress = null;
      _updateMessage = 'Checking GitHub releases for latest version...';
    });

    final engineManager = ref.read(engineManagerProvider);
    final success = await engineManager.updateEngine(
      onProgress: (progress) {
        setState(() {
          _updateProgress = progress;
          _updateMessage = 'Downloading engine update: ${(progress * 100).toStringAsFixed(0)}%';
        });
      },
    );

    setState(() {
      _isUpdatingEngine = false;
      _updateMessage = success
          ? 'Engine successfully updated to ${engineManager.ytDlpVersion ?? "latest"}.'
          : 'Engine is already up to date or update was aborted.';
    });
  }

  Future<void> _copyDiagnosticLogs() async {
    final diagnostics = await AppLogger.getDiagnosticInfo();
    await Clipboard.setData(ClipboardData(text: diagnostics));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Diagnostic information copied to clipboard.')),
      );
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

              // Engine Version & Update
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Engine Lifecycle', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(
                                'Current version: ${engineManager.ytDlpVersion ?? "local"}',
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                          FilledButton.icon(
                            icon: _isUpdatingEngine
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.sync_rounded, size: 18),
                            label: const Text('Update Engine'),
                            onPressed: _isUpdatingEngine ? null : _triggerEngineUpdate,
                          ),
                        ],
                      ),
                      if (_updateMessage != null) ...[
                        const SizedBox(height: 12),
                        if (_updateProgress != null)
                          LinearProgressIndicator(value: _updateProgress),
                        const SizedBox(height: 6),
                        Text(
                          _updateMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Diagnostics & Logs
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Diagnostics & Support', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(
                            'Copy system environment and recent execution logs.',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: const Text('Copy Logs'),
                        onPressed: _copyDiagnosticLogs,
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
