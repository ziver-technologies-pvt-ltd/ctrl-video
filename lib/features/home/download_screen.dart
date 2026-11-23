import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../models/format_selection.dart';
import '../../models/media_info.dart';
import '../../services/download_execution_service.dart';
import '../../services/download_manager.dart';
import '../../services/error_classifier.dart';
import '../../services/format_service.dart';
import '../../services/metadata_service.dart';
import '../../services/preview_service.dart';
import '../../services/trim_service.dart';
import '../../main.dart';
import 'advanced_format_picker_widget.dart';
import 'desktop_preview_player_widget.dart';
import 'timeline_trim_widget.dart';

final previewServiceProvider = Provider<PreviewService>((ref) {
  return PreviewService();
});

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
  final GlobalKey<DesktopPreviewPlayerWidgetState> _playerKey = GlobalKey<DesktopPreviewPlayerWidgetState>();
  final TextEditingController _urlController = TextEditingController();
  bool _isLoadingMetadata = false;
  MediaInfo? _mediaInfo;
  PreviewStreamInfo? _previewStream;
  List<StreamItem> _parsedStreams = [];
  FormatOption? _selectedFormat;
  FormatSelection _formatSelection = FormatSelection.simplePreset('best');
  TrimRange? _trimRange;
  Duration _playerCurrentPosition = Duration.zero;
  String? _errorMessage;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _fetchMetadata() async {
    final rawUrl = _urlController.text.trim();
    if (rawUrl.isEmpty) return;

    if (!MetadataService.isValidUrl(rawUrl)) {
      setState(() {
        _errorMessage = 'Please enter a valid YouTube, Instagram, or Facebook URL.';
        _mediaInfo = null;
        _previewStream = null;
      });
      return;
    }

    setState(() {
      _isLoadingMetadata = true;
      _errorMessage = null;
      _mediaInfo = null;
      _previewStream = null;
      _parsedStreams = [];
      _trimRange = null;
    });

    try {
      final service = ref.read(metadataServiceProvider);
      final info = await service.fetchMetadata(rawUrl);

      PreviewStreamInfo? preview;
      List<StreamItem> streams = [];
      if (info.rawJson != null) {
        preview = ref.read(previewServiceProvider).resolvePreviewStream(info.rawJson!);
        streams = FormatService.parseRawStreams(info.rawJson!);
      }

      setState(() {
        _mediaInfo = info;
        _previewStream = preview;
        _parsedStreams = streams;
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
      final item = await ref.read(downloadManagerProvider).enqueue(
        mediaInfo: _mediaInfo!,
        format: _selectedFormat ?? _mediaInfo!.formats.first,
        formatSelection: _formatSelection,
        trimRange: _trimRange,
      );

      if (mounted) {
        _showDownloadStartedToast(item);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to enqueue download: $e';
      });
    }
  }

  void _showDownloadStartedToast(QueueItem item) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 24, right: 24, left: 24),
        backgroundColor: AppColors.darkSurface2,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.accent, width: 1.2),
        ),
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            const Icon(Icons.download_rounded, color: AppColors.accent, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Download Started',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                  ),
                  Text(
                    '${item.mediaInfo.title} (${item.formatSelection?.label ?? item.format.label})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. TOP URL BAR
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Paste video link (YouTube, Instagram, Facebook)...',
                    prefixIcon: const Icon(Icons.link_rounded, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    suffixIcon: _urlController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _urlController.clear();
                              setState(() {
                                _mediaInfo = null;
                                _previewStream = null;
                                _errorMessage = null;
                                _trimRange = null;
                              });
                            },
                          )
                        : IconButton(
                            icon: const Icon(Icons.paste_rounded, size: 18),
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
              const SizedBox(width: 10),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _isLoadingMetadata ? null : _fetchMetadata,
                icon: _isLoadingMetadata
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : const Icon(Icons.search_rounded, size: 18),
                label: const Text('Fetch', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),

          // 2. ERROR DISPLAY
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: theme.colorScheme.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: theme.colorScheme.onErrorContainer, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // 3. MAIN WORKSPACE AREA (Viewport-fitted zero-scroll layout)
          Expanded(
            child: _mediaInfo == null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_circle_outline_rounded, size: 64, color: theme.colorScheme.outlineVariant),
                        const SizedBox(height: 12),
                        Text(
                          'Ready to download',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Enter any video link above to preview, select formats, or trim clips',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                        ),
                      ],
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 820;

                      // LEFT PANE: Dedicated, cinematic preview player
                      final leftPane = Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _previewStream != null
                            ? DesktopPreviewPlayerWidget(
                                key: _playerKey,
                                streamInfo: _previewStream!,
                                trimRange: _trimRange,
                                onPositionChanged: (pos) {
                                  _playerCurrentPosition = pos;
                                },
                              )
                            : (_mediaInfo!.thumbnailUrl != null
                                ? Center(
                                    child: Image.network(
                                      _mediaInfo!.thumbnailUrl!,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                                    ),
                                  )
                                : const SizedBox.shrink()),
                      );

                      // RIGHT PANE: Title, Format Options, Trim Controls, and Download Action
                      final rightPane = Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Title and Platform Header
                              Text(
                                _mediaInfo!.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _mediaInfo!.platform,
                                      style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
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

                              const Divider(height: 18),

                              // Scrollable controls area for Format and Trimming
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // 1. Format Picker
                                      AdvancedFormatPickerWidget(
                                        streams: _parsedStreams,
                                        initialSelection: _formatSelection,
                                        onSelectionChanged: (selection) {
                                          setState(() {
                                            _formatSelection = selection;
                                          });
                                        },
                                      ),

                                      const SizedBox(height: 14),

                                      // 2. Video Trimming Option (Moved to right panel)
                                      if (_mediaInfo!.durationSeconds != null && _mediaInfo!.durationSeconds! > 0) ...[
                                        TimelineTrimWidget(
                                          totalDuration: Duration(seconds: _mediaInfo!.durationSeconds!),
                                          currentPosition: _playerCurrentPosition,
                                          onRangeChanged: (range) {
                                            setState(() => _trimRange = range);
                                            // When trim range is set/updated, seek preview player to clip start
                                            if (range != null && range.isValid) {
                                              _playerKey.currentState?.seekTo(range.start);
                                            }
                                          },
                                          onSeekRequested: (target) {
                                            _playerKey.currentState?.seekTo(target);
                                          },
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Bottom Download Button
                              Align(
                                alignment: Alignment.centerRight,
                                child: FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.accent,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: _startDownload,
                                  icon: const Icon(Icons.download_rounded, size: 18),
                                  label: const Text('Download', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );

                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(flex: 5, child: leftPane),
                            const SizedBox(width: 14),
                            Expanded(flex: 4, child: rightPane),
                          ],
                        );
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(flex: 5, child: leftPane),
                            const SizedBox(height: 10),
                            Expanded(flex: 5, child: rightPane),
                          ],
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
