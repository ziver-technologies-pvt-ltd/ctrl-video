enum TrimMode {
  fast, // Snaps to nearest keyframe (stream copy)
  exact, // Re-encodes boundary frames around cuts for 100% frame accuracy
}

class TrimRange {
  final Duration start;
  final Duration end;
  final TrimMode mode;

  const TrimRange({
    required this.start,
    required this.end,
    this.mode = TrimMode.exact,
  });

  Duration get duration => end - start;

  bool get isValid => start >= Duration.zero && end > start;

  String get formattedStart => formatTimecode(start);
  String get formattedEnd => formatTimecode(end);
  String get formattedDuration => formatTimecode(duration);

  static String formatTimecode(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final milliseconds = (d.inMilliseconds.remainder(1000)).toString().padLeft(3, '0');
    return '$hours:$minutes:$seconds.$milliseconds';
  }

  static Duration? parseTimecode(String text) {
    try {
      final parts = text.trim().split(':');
      if (parts.length != 3) return null;

      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);

      final secParts = parts[2].split('.');
      final seconds = int.parse(secParts[0]);
      final millis = secParts.length > 1 ? int.parse(secParts[1].padRight(3, '0').substring(0, 3)) : 0;

      return Duration(
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        milliseconds: millis,
      );
    } catch (_) {
      return null;
    }
  }

  /// Builds yt-dlp section arguments for trimming.
  List<String> toYtDlpArgs() {
    if (!isValid) return [];

    final sectionSpec = '*${formattedStart}-${formattedEnd}';
    final args = <String>[
      '--download-sections',
      sectionSpec,
    ];

    if (mode == TrimMode.exact) {
      args.add('--force-keyframes-at-cuts');
    }

    return args;
  }
}

/// Service that manages range validation, mode selection, and timecode calculations.
class TrimService {
  TrimService._();

  /// Default trim mode recommendation based on clip duration:
  /// - Exact for short clips (< 5 mins) where precision matters.
  /// - Fast for longer segments to avoid lengthy re-encoding.
  static TrimMode recommendMode(Duration clipLength) {
    return clipLength <= const Duration(minutes: 5) ? TrimMode.exact : TrimMode.fast;
  }

  static bool validate(Duration start, Duration end, Duration totalVideoDuration) {
    if (start < Duration.zero) return false;
    if (end <= start) return false;
    if (totalVideoDuration > Duration.zero && end > totalVideoDuration) return false;
    return true;
  }
}
