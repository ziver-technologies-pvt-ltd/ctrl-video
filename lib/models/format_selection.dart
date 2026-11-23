/// Encapsulates user format selections for video/audio downloading.
class FormatSelection {
  final String? videoFormatId;
  final String? audioFormatId;
  final String container; // 'mp4', 'mkv', 'webm', 'mp3', 'm4a', 'opus', 'flac', 'wav'
  final bool isAudioOnly;
  final String? audioCodec; // 'mp3', 'aac', 'opus', 'flac', 'wav'
  final String audioQuality; // '0' (best), '5' (medium), '9' (low)
  final String label;

  const FormatSelection({
    this.videoFormatId,
    this.audioFormatId,
    this.container = 'mp4',
    this.isAudioOnly = false,
    this.audioCodec,
    this.audioQuality = '0',
    required this.label,
  });

  /// Factory for standard Simple Mode presets.
  factory FormatSelection.simplePreset(String presetKey, {String container = 'mp4'}) {
    switch (presetKey) {
      case 'best':
        return FormatSelection(
          videoFormatId: 'bv*',
          audioFormatId: 'ba',
          container: container,
          label: 'Best Available ($container)',
        );
      case '1080p':
        return FormatSelection(
          videoFormatId: 'bv*[height<=1080]',
          audioFormatId: 'ba',
          container: container,
          label: '1080p Full HD ($container)',
        );
      case '720p':
        return FormatSelection(
          videoFormatId: 'bv*[height<=720]',
          audioFormatId: 'ba',
          container: container,
          label: '720p HD ($container)',
        );
      case '480p':
        return FormatSelection(
          videoFormatId: 'bv*[height<=480]',
          audioFormatId: 'ba',
          container: container,
          label: '480p SD ($container)',
        );
      case 'audio_mp3':
        return const FormatSelection(
          container: 'mp3',
          isAudioOnly: true,
          audioCodec: 'mp3',
          audioQuality: '0',
          label: 'Audio Only (MP3)',
        );
      case 'audio_m4a':
        return const FormatSelection(
          container: 'm4a',
          isAudioOnly: true,
          audioCodec: 'aac',
          audioQuality: '0',
          label: 'Audio Only (M4A / AAC)',
        );
      case 'audio_opus':
        return const FormatSelection(
          container: 'opus',
          isAudioOnly: true,
          audioCodec: 'opus',
          audioQuality: '0',
          label: 'Audio Only (Opus)',
        );
      case 'audio_flac':
        return const FormatSelection(
          container: 'flac',
          isAudioOnly: true,
          audioCodec: 'flac',
          audioQuality: '0',
          label: 'Audio Only (FLAC)',
        );
      default:
        return FormatSelection(
          videoFormatId: 'bv*',
          audioFormatId: 'ba',
          container: container,
          label: 'Best Available ($container)',
        );
    }
  }

  /// Converts the structured selection into strict yt-dlp arguments list.
  List<String> toYtDlpArgs() {
    final args = <String>[];

    if (isAudioOnly) {
      args.addAll([
        '-x',
        '--audio-format',
        audioCodec ?? (container.isNotEmpty ? container : 'mp3'),
        '--audio-quality',
        audioQuality,
      ]);
    } else {
      String formatSpec;
      if (videoFormatId != null && audioFormatId != null) {
        formatSpec = '$videoFormatId+$audioFormatId/b';
      } else if (videoFormatId != null) {
        formatSpec = '$videoFormatId+ba/b';
      } else {
        formatSpec = 'bv*+ba/b';
      }

      args.addAll([
        '-f',
        formatSpec,
        '--merge-output-format',
        container,
      ]);
    }

    return args;
  }
}
