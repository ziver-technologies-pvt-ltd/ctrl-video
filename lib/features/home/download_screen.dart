import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/media_info.dart';
import '../../services/download_execution_service.dart';
import '../../services/error_classifier.dart';
import '../../services/metadata_service.dart';
import '../../main.dart';

final metadataServiceProvider = Provider<MetadataService>((ref) {
  final engine = ref.watch(engineManagerProvider);
  return MetadataService(engineManager: engine);
});

final downloadExecutionServiceProvider = Provider<DownloadExecutionService>((ref) {
  final engine = ref.watch(engineManagerProvider);
  return DownloadExecutionService(engineManager: engine);
});

class DownloadScreen extends ConsumerStatefulWidget {
  const DownloadScreen({super.key});

  @override
  ConsumerState<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends ConsumerState<DownloadScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isLoadingMetadata = false;
  MediaInfo? _mediaInfo;
  FormatOption? _selectedFormat;
  String? _errorMessage;

  // Active download state
  bool _isDownloading = false;
  DownloadProgress _progress = const DownloadProgress();
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _checkClipboardForUrl();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _checkClipboardForUrl() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim() ?? '';
      if (MetadataService.isValidUrl(text)) {
        setState(() {
          _urlController.text = text;
        });
        _fetchMetadata();
      }
    } catch (_) {}
  }

  Future<void> _fetchMetadata() async {
    final rawUrl = _urlController.text.trim();
    if (rawUrl.isEmpty) return;

    if (!MetadataService.isValidUrl(rawUrl)) {
      setState(() {
        _errorMessage = 'Please enter a valid YouTube, Instagram, or Facebook URL.';
        _mediaInfo = null;
      });
      return;
    }

    setState(() {
      _isLoadingMetadata = true;
      _errorMessage = null;
      _mediaInfo = null;
      _isCompleted = false;
      _progress = const DownloadProgress();
    });

    try {
      final service = ref.read(metadataServiceProvider);
      final info = await service.fetchMetadata(rawUrl);
      setState(() {
        _mediaInfo = info;
        _selectedFormat = info.formats.isNotEmpty ? info.formats.first : null;
        _isLoadingMetadata = false;
      });
    } on ClassifiedError catch (e) {
      setState(() {
        _errorMessage = '${e.userMessage} ${e.suggestedAction ?? ""}';
        _isLoadingMetadata = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch video preview: $e';
        _isLoadingMetadata = false;
      });
    }
  }

  Future<void> _startDownload() async {
    if (_mediaInfo == null || _selectedFormat == null) return;

    try {
      final queueItem = await ref.read(downloadManagerProvider).enqueue(
        mediaInfo: _mediaInfo!,
        format: _selectedFormat!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added "${_mediaInfo!.title}" to queue.'),
            action: SnackBarAction(
              label: 'View Queue',
              onPressed: () {
                // User can navigate to queue
              },
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to enqueue download: $e';
      });
    }
  }

  void _cancelDownload() {
    ref.read(downloadExecutionServiceProvider).cancel();
    setState(() {
      _isDownloading = false;
      _errorMessage = 'Download cancelled.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // URL Input Bar
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        hintText: 'Paste video link (YouTube, Instagram, Facebook)...',
                        prefixIcon: const Icon(Icons.link_rounded),
                        suffixIcon: _urlController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 20),
                                onPressed: () {
                                  _urlController.clear();
                                  setState(() {
                                    _mediaInfo = null;
                                    _errorMessage = null;
                                  });
                                },
                              )
                            : IconButton(
                                icon: const Icon(Icons.paste_rounded, size: 20),
                                tooltip: 'Paste from clipboard',
                                onPressed: () async {
                                  final data = await Clipboard.getData(Clipboard.kTextPlain);
                                  if (data?.text != null) {
                                    _urlController.text = data!.text!.trim();
                                    _fetchMetadata();
                                  }
                                },
                              ),
                      ),
                      onSubmitted: (_) => _fetchMetadata(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isLoadingMetadata || _isDownloading ? null : _fetchMetadata,
                    icon: _isLoadingMetadata
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.search_rounded),
                    label: const Text('Fetch'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Error display
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: theme.colorScheme.error, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: theme.colorScheme.onErrorContainer, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              // Preview Card
              if (_mediaInfo != null) ...[
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thumbnail Preview
                            if (_mediaInfo!.thumbnailUrl != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  _mediaInfo!.thumbnailUrl!,
                                  width: 140,
                                  height: 85,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 140,
                                    height: 85,
                                    color: theme.colorScheme.surfaceContainerHighest,
                                    child: const Icon(Icons.movie_outlined),
                                  ),
                                ),
                              ),
                            const SizedBox(width: 16),

                            // Video Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _mediaInfo!.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primaryContainer,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          _mediaInfo!.platform,
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: theme.colorScheme.onPrimaryContainer,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      if (_mediaInfo!.uploader != null) ...[
                                        Text(
                                          _mediaInfo!.uploader!,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                      ],
                                      if (_mediaInfo!.formattedDuration.isNotEmpty)
                                        Text(
                                          _mediaInfo!.formattedDuration,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.outline,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const Divider(height: 28),

                        // Format Selection and Action
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<FormatOption>(
                                value: _selectedFormat,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'Choose Quality / Format',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                ),
                                items: _mediaInfo!.formats.map((f) {
                                  return DropdownMenuItem(
                                    value: f,
                                    child: Text(f.label),
                                  );
                                }).toList(),
                                onChanged: _isDownloading
                                    ? null
                                    : (val) {
                                        setState(() {
                                          _selectedFormat = val;
                                        });
                                      },
                              ),
                            ),
                            const SizedBox(width: 16),
                            FilledButton.icon(
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _isDownloading ? null : _startDownload,
                              icon: const Icon(Icons.download_rounded),
                              label: const Text('Download'),
                            ),
                          ],
                        ),

                        // Active Download Progress & Metrics
                        if (_isDownloading || _isCompleted) ...[
                          const SizedBox(height: 20),
                          LinearProgressIndicator(
                            value: _isCompleted ? 1.0 : (_progress.percent / 100.0).clamp(0.0, 1.0),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _isCompleted
                                    ? 'Completed! Saved to downloads.'
                                    : '${_progress.percent.toStringAsFixed(1)}% • Speed: ${_progress.speed}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: _isCompleted ? Colors.green : theme.colorScheme.onSurfaceVariant,
                                  fontWeight: _isCompleted ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              if (_isDownloading) ...[
                                Text(
                                  'ETA: ${_progress.eta}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                TextButton(
                                  onPressed: _cancelDownload,
                                  child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
