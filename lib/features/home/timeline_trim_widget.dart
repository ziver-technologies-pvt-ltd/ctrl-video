import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../services/trim_service.dart';

class TimelineTrimWidget extends StatefulWidget {
  final Duration totalDuration;
  final Duration currentPosition;
  final ValueChanged<TrimRange?> onRangeChanged;
  final ValueChanged<Duration>? onSeekRequested;

  const TimelineTrimWidget({
    super.key,
    required this.totalDuration,
    required this.currentPosition,
    required this.onRangeChanged,
    this.onSeekRequested,
  });

  @override
  State<TimelineTrimWidget> createState() => _TimelineTrimWidgetState();
}

class _TimelineTrimWidgetState extends State<TimelineTrimWidget> {
  bool _isTrimEnabled = false;
  late Duration _start;
  late Duration _end;
  TrimMode _mode = TrimMode.exact;

  late final TextEditingController _startController;
  late final TextEditingController _endController;

  @override
  void initState() {
    super.initState();
    _start = Duration.zero;
    _end = widget.totalDuration > Duration.zero
        ? widget.totalDuration
        : const Duration(minutes: 1);

    _mode = TrimService.recommendMode(_end - _start);

    _startController = TextEditingController(text: TrimRange.formatTimecode(_start));
    _endController = TextEditingController(text: TrimRange.formatTimecode(_end));
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  void _notifyRange() {
    if (_isTrimEnabled) {
      widget.onRangeChanged(TrimRange(
        start: _start,
        end: _end,
        mode: _mode,
      ));
    } else {
      widget.onRangeChanged(null);
    }
  }

  void _setStartAtCurrent() {
    if (widget.currentPosition < _end) {
      setState(() {
        _start = widget.currentPosition;
        _startController.text = TrimRange.formatTimecode(_start);
      });
      _notifyRange();
    }
  }

  void _setEndAtCurrent() {
    if (widget.currentPosition > _start) {
      setState(() {
        _end = widget.currentPosition;
        _endController.text = TrimRange.formatTimecode(_end);
      });
      _notifyRange();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clipDuration = _end - _start;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Enable / Disable Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.content_cut_rounded, size: 20, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Text(
                      'Trim Video / Clip Selection',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Switch(
                  value: _isTrimEnabled,
                  activeColor: AppColors.accent,
                  onChanged: (val) {
                    setState(() => _isTrimEnabled = val);
                    _notifyRange();
                  },
                ),
              ],
            ),

            if (_isTrimEnabled) ...[
              const SizedBox(height: 12),

              // Interactive Range Slider
              RangeSlider(
                values: RangeValues(
                  _start.inMilliseconds.toDouble().clamp(0.0, widget.totalDuration.inMilliseconds.toDouble()),
                  _end.inMilliseconds.toDouble().clamp(0.0, widget.totalDuration.inMilliseconds.toDouble()),
                ),
                min: 0.0,
                max: widget.totalDuration.inMilliseconds.toDouble() > 0
                    ? widget.totalDuration.inMilliseconds.toDouble()
                    : 1.0,
                activeColor: AppColors.accent,
                inactiveColor: theme.colorScheme.surfaceContainerHighest,
                onChanged: (RangeValues values) {
                  setState(() {
                    _start = Duration(milliseconds: values.start.toInt());
                    _end = Duration(milliseconds: values.end.toInt());
                    _startController.text = TrimRange.formatTimecode(_start);
                    _endController.text = TrimRange.formatTimecode(_end);
                  });
                  _notifyRange();
                },
              ),

              // Quick In/Out buttons & Mode Switcher (Responsive)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 420;
                  final inOutButtons = Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        icon: const Icon(Icons.arrow_downward_rounded, size: 14),
                        label: const Text('[I] Start'),
                        onPressed: _setStartAtCurrent,
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        icon: const Icon(Icons.arrow_upward_rounded, size: 14),
                        label: const Text('[O] End'),
                        onPressed: _setEndAtCurrent,
                      ),
                    ],
                  );

                  final modeSegment = SegmentedButton<TrimMode>(
                    style: const ButtonStyle(visualDensity: VisualDensity.compact),
                    segments: const [
                      ButtonSegment(value: TrimMode.exact, label: Text('Exact (Frame)')),
                      ButtonSegment(value: TrimMode.fast, label: Text('Fast (Keyframe)')),
                    ],
                    selected: {_mode},
                    onSelectionChanged: (set) {
                      setState(() => _mode = set.first);
                      _notifyRange();
                    },
                  );

                  if (isCompact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        inOutButtons,
                        const SizedBox(height: 8),
                        modeSegment,
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      inOutButtons,
                      modeSegment,
                    ],
                  );
                },
              ),

              const SizedBox(height: 12),

              // Timecode Inputs & Length Display
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _startController,
                      style: AppTheme.monoStyle.copyWith(fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'Start Time (HH:MM:SS.mmm)',
                        prefixIcon: Icon(Icons.play_circle_outline, size: 18),
                      ),
                      onSubmitted: (val) {
                        final parsed = TrimRange.parseTimecode(val);
                        if (parsed != null && parsed < _end) {
                          setState(() => _start = parsed);
                          _notifyRange();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _endController,
                      style: AppTheme.monoStyle.copyWith(fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'End Time (HH:MM:SS.mmm)',
                        prefixIcon: Icon(Icons.stop_circle_outlined, size: 18),
                      ),
                      onSubmitted: (val) {
                        final parsed = TrimRange.parseTimecode(val);
                        if (parsed != null && parsed > _start) {
                          setState(() => _end = parsed);
                          _notifyRange();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Clip Length', style: theme.textTheme.labelSmall),
                        Text(
                          TrimRange.formatTimecode(clipDuration),
                          style: AppTheme.monoStyle.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
