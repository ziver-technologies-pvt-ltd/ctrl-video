import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../app/theme.dart';
import '../../services/preview_service.dart';
import '../../services/trim_service.dart';

class DesktopPreviewPlayerWidget extends StatefulWidget {
  final PreviewStreamInfo streamInfo;
  final TrimRange? trimRange;
  final ValueChanged<Duration>? onPositionChanged;
  final VoidCallback? onClosed;

  const DesktopPreviewPlayerWidget({
    super.key,
    required this.streamInfo,
    this.trimRange,
    this.onPositionChanged,
    this.onClosed,
  });

  @override
  State<DesktopPreviewPlayerWidget> createState() => DesktopPreviewPlayerWidgetState();
}

class DesktopPreviewPlayerWidgetState extends State<DesktopPreviewPlayerWidget> {
  late final Player _player;
  late final VideoController _videoController;

  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  Player get player => _player;
  Duration get currentPosition => _position;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _videoController = VideoController(
      _player,
      configuration: const VideoControllerConfiguration(
        hwdec: 'auto-safe',
        enableHardwareAcceleration: true,
      ),
    );

    _player.stream.playing.listen((playing) {
      if (mounted) setState(() => _isPlaying = playing);
    });

    _player.stream.position.listen((pos) {
      if (mounted) {
        setState(() => _position = pos);
        widget.onPositionChanged?.call(pos);

        // If trimming is active, keep preview playback within the trimmed segment
        if (widget.trimRange != null && widget.trimRange!.isValid) {
          final start = widget.trimRange!.start;
          final end = widget.trimRange!.end;
          if (pos < start) {
            _player.seek(start);
          } else if (pos >= end) {
            _player.seek(start);
          }
        }
      }
    });

    _player.stream.duration.listen((dur) {
      if (mounted) setState(() => _duration = dur);
    });

    _openMedia();
  }

  @override
  void didUpdateWidget(covariant DesktopPreviewPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.streamInfo.videoUrl != oldWidget.streamInfo.videoUrl) {
      _openMedia();
    }
  }

  Future<void> _openMedia() async {
    final media = Media(
      widget.streamInfo.videoUrl,
      httpHeaders: widget.streamInfo.httpHeaders,
    );
    await _player.open(media);
    if (widget.streamInfo.audioUrl != null) {
      await _player.setAudioTrack(
        AudioTrack.uri(
          widget.streamInfo.audioUrl!,
          title: 'Audio Stream',
          language: 'en',
        ),
      );
    }

    // If initial trim range is already set, seek directly to start point
    if (widget.trimRange != null && widget.trimRange!.isValid) {
      await _player.seek(widget.trimRange!.start);
    }
  }

  void seekTo(Duration target) {
    _player.seek(target);
  }

  void playTrimmedSection() {
    if (widget.trimRange != null && widget.trimRange!.isValid) {
      _player.seek(widget.trimRange!.start);
      _player.play();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = d.inHours;
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.space): () {
          _player.playOrPause();
        },
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
          _player.seek(_position - const Duration(seconds: 5));
        },
        const SingleActivator(LogicalKeyboardKey.arrowRight): () {
          _player.seek(_position + const Duration(seconds: 5));
        },
      },
      child: Focus(
        autofocus: true,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Native video texture with default controls explicitly disabled
              Video(
                controller: _videoController,
                controls: NoVideoControls,
                fit: BoxFit.contain,
              ),

              // Custom Overlay Controls
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.85),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Scrubber Slider
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbColor: AppColors.accent,
                          activeTrackColor: AppColors.accent,
                          inactiveTrackColor: Colors.white24,
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        ),
                        child: Slider(
                          value: _position.inMilliseconds.toDouble().clamp(
                                0.0,
                                _duration.inMilliseconds.toDouble() > 0
                                    ? _duration.inMilliseconds.toDouble()
                                    : 1.0,
                              ),
                          max: _duration.inMilliseconds.toDouble() > 0
                              ? _duration.inMilliseconds.toDouble()
                              : 1.0,
                          onChanged: (val) {
                            _player.seek(Duration(milliseconds: val.toInt()));
                          },
                        ),
                      ),

                      // Playback Control Buttons Row
                      Row(
                        children: [
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.white,
                            ),
                            onPressed: () => _player.playOrPause(),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                            style: AppTheme.monoStyle.copyWith(color: Colors.white70, fontSize: 11),
                          ),
                          if (widget.trimRange != null && widget.trimRange!.isValid) ...[
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: playTrimmedSection,
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.accent, width: 0.8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.repeat_rounded, size: 12, color: AppColors.accent),
                                    const SizedBox(width: 4),
                                    Text('Trim Preview', style: AppTheme.monoStyle.copyWith(fontSize: 10, color: AppColors.accent)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            tooltip: 'Seek -5s (←)',
                            icon: const Icon(Icons.replay_5_rounded, color: Colors.white70, size: 18),
                            onPressed: () => _player.seek(_position - const Duration(seconds: 5)),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            tooltip: 'Seek +5s (→)',
                            icon: const Icon(Icons.forward_5_rounded, color: Colors.white70, size: 18),
                            onPressed: () => _player.seek(_position + const Duration(seconds: 5)),
                          ),
                        ],
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
