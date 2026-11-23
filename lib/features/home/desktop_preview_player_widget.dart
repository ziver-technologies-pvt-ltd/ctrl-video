import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../app/theme.dart';
import '../../services/preview_service.dart';

class DesktopPreviewPlayerWidget extends StatefulWidget {
  final PreviewStreamInfo streamInfo;
  final VoidCallback? onClosed;

  const DesktopPreviewPlayerWidget({
    super.key,
    required this.streamInfo,
    this.onClosed,
  });

  @override
  State<DesktopPreviewPlayerWidget> createState() => _DesktopPreviewPlayerWidgetState();
}

class _DesktopPreviewPlayerWidgetState extends State<DesktopPreviewPlayerWidget> {
  late final Player _player;
  late final VideoController _videoController;

  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _videoController = VideoController(_player);

    _player.stream.playing.listen((playing) {
      if (mounted) setState(() => _isPlaying = playing);
    });

    _player.stream.position.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });

    _player.stream.duration.listen((dur) {
      if (mounted) setState(() => _duration = dur);
    });

    _openMedia();
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
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
          ),
          clipBehavior: Clip.antiAlias,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                Video(controller: _videoController),

                // Overlay Controls
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

                        // Playback Control Buttons
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Colors.white,
                              ),
                              onPressed: () => _player.playOrPause(),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                              style: AppTheme.monoStyle.copyWith(color: Colors.white70, fontSize: 12),
                            ),
                            const Spacer(),
                            IconButton(
                              tooltip: 'Seek -5s (←)',
                              icon: const Icon(Icons.replay_5_rounded, color: Colors.white70, size: 20),
                              onPressed: () => _player.seek(_position - const Duration(seconds: 5)),
                            ),
                            IconButton(
                              tooltip: 'Seek +5s (→)',
                              icon: const Icon(Icons.forward_5_rounded, color: Colors.white70, size: 20),
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
      ),
    );
  }
}
