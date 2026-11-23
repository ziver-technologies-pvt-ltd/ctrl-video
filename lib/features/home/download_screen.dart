import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../models/format_selection.dart';
import '../../models/media_info.dart';
import '../../services/download_execution_service.dart';
import '../../services/error_classifier.dart';
import '../../services/format_service.dart';
import '../../services/metadata_service.dart';
import '../../services/preview_service.dart';
import '../../services/trim_service.dart';
import '../../main.dart';
import 'advanced_format_picker_widget.dart';
import 'desktop_preview_player_widget.dart';
import 'timeline_trim_widget.dart';

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
  PreviewStreamInfo? _previewStream;
  FormatOption? _selectedFormat;
  FormatSelection _formatSelection = FormatSelection.simplePreset('best');
  TrimRange? _trimRange;
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
        format: _selectedFormat ?? _mediaInfo!.formats.first,
        formatSelection: _formatSelection,
        trimRange: _trimRange,
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

              // Preview Card & Two-Pane Workspace
              if (_mediaInfo != null) ...[
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 820;

                    final leftPane = Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // In-App Desktop Preview Player
                        if (_previewStream != null)
                          DesktopPreviewPlayerWidget(streamInfo: _previewStream!)
                        else if (_mediaInfo!.thumbnailUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              _mediaInfo!.thumbnailUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                            ),
                          ),

                        const SizedBox(height: 14),

                        // Interactive Video Trimming Widget
                        if (_mediaInfo!.durationSeconds != null && _mediaInfo!.durationSeconds! > 0)
                          TimelineTrimWidget(
                            totalDuration: Duration(seconds: _mediaInfo!.durationSeconds!),
                            currentPosition: Duration.zero,
                            onRangeChanged: (range) {
                              setState(() => _trimRange = range);
                            },
                          ),
                      ],
                    );

                    final rightPane = Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _mediaInfo!.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
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
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (_mediaInfo!.uploader != null)
                                  Expanded(
                                    child: Text(
                                      _mediaInfo!.uploader!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            const Divider(height: 28),

                            // Advanced Format Selector & Container Switcher
                            AdvancedFormatPickerWidget(
                              streams: const [],
                              initialSelection: _formatSelection,
                              onSelectionChanged: (selection) {
                                setState(() {
                                  _formatSelection = selection;
                                });
                              },
                            ),

                            const SizedBox(height: 20),

                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: _startDownload,
                                icon: const Icon(Icons.download_rounded),
                                label: const Text('Download', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );

                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: leftPane),
                          const SizedBox(width: 20),
                          Expanded(flex: 4, child: rightPane),
                        ],
                      );
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          leftPane,
                          const SizedBox(height: 16),
                          rightPane,
                        ],
                      );
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
