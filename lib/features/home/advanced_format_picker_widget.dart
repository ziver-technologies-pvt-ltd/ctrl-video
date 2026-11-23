import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/format_selection.dart';
import '../../services/format_service.dart';

enum MediaOutputCategory {
  video,
  audio,
  advanced,
}

class AdvancedFormatPickerWidget extends StatefulWidget {
  final List<StreamItem> streams;
  final FormatSelection initialSelection;
  final ValueChanged<FormatSelection> onSelectionChanged;

  const AdvancedFormatPickerWidget({
    super.key,
    required this.streams,
    required this.initialSelection,
    required this.onSelectionChanged,
  });

  @override
  State<AdvancedFormatPickerWidget> createState() => _AdvancedFormatPickerWidgetState();
}

class _AdvancedFormatPickerWidgetState extends State<AdvancedFormatPickerWidget> with SingleTickerProviderStateMixin {
  late TabController _advancedTabController;
  MediaOutputCategory _outputCategory = MediaOutputCategory.video;

  // Video preset options
  String _videoQualityPreset = 'best';
  String _videoContainer = 'mp4';

  // Audio preset options
  String _audioQualityPreset = 'audio_mp3';
  String _audioContainer = 'mp3';

  // Advanced selection
  StreamItem? _selectedVideoOnly;
  StreamItem? _selectedAudioOnly;

  @override
  void initState() {
    super.initState();
    _advancedTabController = TabController(length: 3, vsync: this);
    if (widget.initialSelection.isAudioOnly) {
      _outputCategory = MediaOutputCategory.audio;
    }
  }

  @override
  void dispose() {
    _advancedTabController.dispose();
    super.dispose();
  }

  void _emitVideoSelection() {
    final selection = FormatSelection.simplePreset(
      _videoQualityPreset,
      container: _videoContainer,
    );
    widget.onSelectionChanged(selection);
  }

  void _emitAudioSelection() {
    String formatId = 'ba/b';
    String codec = _audioContainer;
    String label = 'Audio Only (${_audioContainer.toUpperCase()})';

    final selection = FormatSelection(
      audioFormatId: formatId,
      container: _audioContainer,
      isAudioOnly: true,
      audioCodec: codec,
      label: label,
    );
    widget.onSelectionChanged(selection);
  }

  void _emitAdvancedSelection() {
    if (_selectedVideoOnly != null && _selectedAudioOnly != null) {
      final selection = FormatSelection(
        videoFormatId: _selectedVideoOnly!.formatId,
        audioFormatId: _selectedAudioOnly!.formatId,
        container: _videoContainer,
        label: '${_selectedVideoOnly!.resolutionLabel} (${_selectedVideoOnly!.codecLabel}) + ${_selectedAudioOnly!.codecLabel}',
      );
      widget.onSelectionChanged(selection);
    } else if (_selectedAudioOnly != null && _advancedTabController.index == 2) {
      final selection = FormatSelection(
        audioFormatId: _selectedAudioOnly!.formatId,
        container: _selectedAudioOnly!.ext,
        isAudioOnly: true,
        audioCodec: _selectedAudioOnly!.acodec,
        label: 'Audio Only (${_selectedAudioOnly!.codecLabel})',
      );
      widget.onSelectionChanged(selection);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final combined = FormatService.getCombinedStreams(widget.streams);
    final videoOnly = FormatService.getVideoOnlyStreams(widget.streams);
    final audioOnly = FormatService.getAudioOnlyStreams(widget.streams);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top-Level Media Category Toggle: [ 🎬 Video ] [ 🎵 Audio Only ] [ ⚙ Advanced ]
        SegmentedButton<MediaOutputCategory>(
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
          segments: const [
            ButtonSegment(
              value: MediaOutputCategory.video,
              icon: Icon(Icons.videocam_rounded, size: 16),
              label: Text('Video'),
            ),
            ButtonSegment(
              value: MediaOutputCategory.audio,
              icon: Icon(Icons.music_note_rounded, size: 16),
              label: Text('Audio Only'),
            ),
            ButtonSegment(
              value: MediaOutputCategory.advanced,
              icon: Icon(Icons.tune_rounded, size: 16),
              label: Text('Advanced'),
            ),
          ],
          selected: {_outputCategory},
          onSelectionChanged: (set) {
            setState(() {
              _outputCategory = set.first;
            });
            if (_outputCategory == MediaOutputCategory.video) {
              _emitVideoSelection();
            } else if (_outputCategory == MediaOutputCategory.audio) {
              _emitAudioSelection();
            } else {
              _emitAdvancedSelection();
            }
          },
        ),

        const SizedBox(height: 12),

        // 1. VIDEO MODE CONTROLS
        if (_outputCategory == MediaOutputCategory.video) ...[
          Row(
            children: [
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  isDense: true,
                  value: _videoQualityPreset,
                  decoration: const InputDecoration(
                    labelText: 'Video Quality',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'best', child: Text('Best Available Quality (Auto)')),
                    DropdownMenuItem(value: '1080p', child: Text('1080p Full HD')),
                    DropdownMenuItem(value: '720p', child: Text('720p HD')),
                    DropdownMenuItem(value: '480p', child: Text('480p SD')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _videoQualityPreset = val);
                      _emitVideoSelection();
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  isDense: true,
                  value: _videoContainer,
                  decoration: const InputDecoration(
                    labelText: 'Container',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'mp4', child: Text('MP4')),
                    DropdownMenuItem(value: 'mkv', child: Text('MKV')),
                    DropdownMenuItem(value: 'webm', child: Text('WebM')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _videoContainer = val);
                      _emitVideoSelection();
                    }
                  },
                ),
              ),
            ],
          ),
        ]
        // 2. AUDIO ONLY MODE CONTROLS
        else if (_outputCategory == MediaOutputCategory.audio) ...[
          Row(
            children: [
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  isDense: true,
                  value: _audioContainer,
                  decoration: const InputDecoration(
                    labelText: 'Audio Format',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'mp3', child: Text('MP3 (Universal Audio)')),
                    DropdownMenuItem(value: 'm4a', child: Text('M4A / AAC (Apple/Standard)')),
                    DropdownMenuItem(value: 'flac', child: Text('FLAC (Lossless Audio)')),
                    DropdownMenuItem(value: 'opus', child: Text('Opus (High Efficiency)')),
                    DropdownMenuItem(value: 'wav', child: Text('WAV (Uncompressed PCM)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _audioContainer = val);
                      _emitAudioSelection();
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  isDense: true,
                  value: _audioQualityPreset,
                  decoration: const InputDecoration(
                    labelText: 'Quality',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'audio_mp3', child: Text('Best (320k)')),
                    DropdownMenuItem(value: 'audio_m4a', child: Text('Standard (192k)')),
                    DropdownMenuItem(value: 'audio_opus', child: Text('Voice (128k)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _audioQualityPreset = val);
                      _emitAudioSelection();
                    }
                  },
                ),
              ),
            ],
          ),
        ]
        // 3. ADVANCED MODE WITH STREAMS TABLE
        else ...[
          TabBar(
            controller: _advancedTabController,
            labelColor: AppColors.accent,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            indicatorColor: AppColors.accent,
            isScrollable: true,
            tabs: [
              Tab(text: 'Combined (${combined.length})'),
              Tab(text: 'Video Only (${videoOnly.length})'),
              Tab(text: 'Audio Only (${audioOnly.length})'),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: TabBarView(
              controller: _advancedTabController,
              children: [
                _buildStreamList(combined, onSelect: (s) {
                  final sel = FormatSelection(
                    videoFormatId: s.formatId,
                    container: s.ext,
                    label: '${s.resolutionLabel} (${s.codecLabel})',
                  );
                  widget.onSelectionChanged(sel);
                }),
                _buildStreamList(videoOnly, selectedId: _selectedVideoOnly?.formatId, onSelect: (s) {
                  setState(() => _selectedVideoOnly = s);
                  _emitAdvancedSelection();
                }),
                _buildStreamList(audioOnly, selectedId: _selectedAudioOnly?.formatId, onSelect: (s) {
                  setState(() => _selectedAudioOnly = s);
                  _emitAdvancedSelection();
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStreamList(
    List<StreamItem> items, {
    String? selectedId,
    required ValueChanged<StreamItem> onSelect,
  }) {
    if (items.isEmpty) {
      return const Center(
        child: Text('No matching streams found for this video.'),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, idx) {
        final item = items[idx];
        final isSelected = item.formatId == selectedId;

        return InkWell(
          onTap: () => onSelect(item),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accent.withValues(alpha: 0.15) : null,
              border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 0.5)),
            ),
            child: Row(
              children: [
                if (isSelected) const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.accent)
                else const SizedBox(width: 14),
                const SizedBox(width: 8),
                Text(item.resolutionLabel, style: AppTheme.monoStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(item.ext.toUpperCase(), style: const TextStyle(fontSize: 10)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(item.codecLabel, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
                ),
                Text(item.formattedSize, style: AppTheme.monoStyle.copyWith(fontSize: 11)),
              ],
            ),
          ),
        );
      },
    );
  }
}
