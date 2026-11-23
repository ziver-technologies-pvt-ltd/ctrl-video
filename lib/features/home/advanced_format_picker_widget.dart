import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/format_selection.dart';
import '../../services/format_service.dart';

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
  late TabController _tabController;
  bool _isAdvancedMode = false;
  String _simplePreset = 'best';
  String _selectedContainer = 'mp4';

  StreamItem? _selectedVideoOnly;
  StreamItem? _selectedAudioOnly;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _emitSimpleSelection() {
    final selection = FormatSelection.simplePreset(
      _simplePreset,
      container: _selectedContainer,
    );
    widget.onSelectionChanged(selection);
  }

  void _emitAdvancedSelection() {
    if (_selectedVideoOnly != null && _selectedAudioOnly != null) {
      final selection = FormatSelection(
        videoFormatId: _selectedVideoOnly!.formatId,
        audioFormatId: _selectedAudioOnly!.formatId,
        container: _selectedContainer,
        label: '${_selectedVideoOnly!.resolutionLabel} (${_selectedVideoOnly!.codecLabel}) + ${_selectedAudioOnly!.codecLabel}',
      );
      widget.onSelectionChanged(selection);
    } else if (_selectedAudioOnly != null && _tabController.index == 2) {
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
      children: [
        // Mode Switcher Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Simple Preset')),
                ButtonSegment(value: true, label: Text('Advanced Streams')),
              ],
              selected: {_isAdvancedMode},
              onSelectionChanged: (set) {
                setState(() {
                  _isAdvancedMode = set.first;
                });
                if (!_isAdvancedMode) {
                  _emitSimpleSelection();
                }
              },
            ),

            // Container Picker
            Row(
              children: [
                Text('Format: ', style: theme.textTheme.bodySmall),
                DropdownButton<String>(
                  value: _selectedContainer,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: 'mp4', child: Text('MP4')),
                    DropdownMenuItem(value: 'mkv', child: Text('MKV')),
                    DropdownMenuItem(value: 'webm', child: Text('WebM')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedContainer = val);
                      if (_isAdvancedMode) {
                        _emitAdvancedSelection();
                      } else {
                        _emitSimpleSelection();
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Simple Mode View
        if (!_isAdvancedMode) ...[
          DropdownButtonFormField<String>(
            value: _simplePreset,
            decoration: const InputDecoration(
              labelText: 'Quality & Output Option',
            ),
            items: const [
              DropdownMenuItem(value: 'best', child: Text('Best Available Quality (Auto)')),
              DropdownMenuItem(value: '1080p', child: Text('1080p Full HD')),
              DropdownMenuItem(value: '720p', child: Text('720p HD')),
              DropdownMenuItem(value: '480p', child: Text('480p SD')),
              DropdownMenuItem(value: 'audio_mp3', child: Text('Audio Only (MP3 High Quality)')),
              DropdownMenuItem(value: 'audio_m4a', child: Text('Audio Only (M4A / AAC)')),
              DropdownMenuItem(value: 'audio_opus', child: Text('Audio Only (Opus)')),
              DropdownMenuItem(value: 'audio_flac', child: Text('Audio Only (Lossless FLAC)')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() => _simplePreset = val);
                _emitSimpleSelection();
              }
            },
          ),
        ] else ...[
          // Advanced Mode Stream Tables
          TabBar(
            controller: _tabController,
            labelColor: AppColors.accent,
            indicatorColor: AppColors.accent,
            tabs: [
              Tab(text: 'Video (${videoOnly.length})'),
              Tab(text: 'Audio (${audioOnly.length})'),
              Tab(text: 'Combined (${combined.length})'),
            ],
          ),
          const SizedBox(height: 8),

          SizedBox(
            height: 180,
            child: TabBarView(
              controller: _tabController,
              children: [
                // Video Only List
                _buildStreamList(
                  videoOnly,
                  selectedId: _selectedVideoOnly?.formatId,
                  onSelect: (item) {
                    setState(() => _selectedVideoOnly = item);
                    _emitAdvancedSelection();
                  },
                ),

                // Audio Only List
                _buildStreamList(
                  audioOnly,
                  selectedId: _selectedAudioOnly?.formatId,
                  onSelect: (item) {
                    setState(() => _selectedAudioOnly = item);
                    _emitAdvancedSelection();
                  },
                ),

                // Combined List
                _buildStreamList(
                  combined,
                  selectedId: _selectedVideoOnly?.formatId,
                  onSelect: (item) {
                    setState(() {
                      _selectedVideoOnly = item;
                      _selectedAudioOnly = null;
                    });
                    final selection = FormatSelection(
                      videoFormatId: item.formatId,
                      container: item.ext,
                      label: '${item.resolutionLabel} (${item.codecLabel})',
                    );
                    widget.onSelectionChanged(selection);
                  },
                ),
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
      return const Center(child: Text('No streams available in this category'));
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final stream = items[index];
        final isSelected = stream.formatId == selectedId;

        return ListTile(
          dense: true,
          selected: isSelected,
          selectedTileColor: AppColors.accent.withValues(alpha: 0.15),
          leading: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accent : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              stream.resolutionLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.black : null,
              ),
            ),
          ),
          title: Text('${stream.codecLabel} • ${stream.ext.toUpperCase()}'),
          subtitle: Text('${stream.dynamicRange} • ${stream.fps != null ? "${stream.fps}fps" : ""}'),
          trailing: Text(
            stream.formattedSize,
            style: AppTheme.monoStyle.copyWith(fontSize: 11),
          ),
          onTap: () => onSelect(stream),
        );
      },
    );
  }
}
