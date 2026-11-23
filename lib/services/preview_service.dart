import 'package:logger/logger.dart';
import '../models/media_info.dart';
import 'format_service.dart';

class PreviewStreamInfo {
  final String videoUrl;
  final String? audioUrl;
  final Map<String, String> httpHeaders;
  final String label;

  const PreviewStreamInfo({
    required this.videoUrl,
    this.audioUrl,
    this.httpHeaders = const {},
    required this.label,
  });
}

/// Service that selects optimal low-bandwidth streams for the in-app desktop preview player.
class PreviewService {
  final Logger _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, colors: false, printEmojis: false),
  );

  /// Resolves the best preview stream from yt-dlp metadata:
  /// - Prefers lightweight progressive streams (<= 720p) with combined audio/video.
  /// - If only separate streams exist, pairs a 720p/480p video stream with a standard audio stream.
  PreviewStreamInfo? resolvePreviewStream(Map<String, dynamic> rawMetadata) {
    try {
      final formats = rawMetadata['formats'] as List<dynamic>? ?? [];
      if (formats.isEmpty) return null;

      final httpHeaders = <String, String>{};
      final rawHeaders = rawMetadata['http_headers'] as Map<String, dynamic>?;
      if (rawHeaders != null) {
        rawHeaders.forEach((key, value) {
          httpHeaders[key] = value.toString();
        });
      }

      // 1. Look for pre-combined video+audio streams <= 720p, sorted by best resolution
      final combinedCandidates = <Map<String, dynamic>>[];
      for (final f in formats) {
        final map = f as Map<String, dynamic>;
        final vcodec = map['vcodec']?.toString();
        final acodec = map['acodec']?.toString();
        final height = map['height'] as int?;
        final url = map['url']?.toString();

        if (url != null &&
            vcodec != null &&
            vcodec != 'none' &&
            acodec != null &&
            acodec != 'none' &&
            (height == null || height <= 720)) {
          combinedCandidates.add(map);
        }
      }

      if (combinedCandidates.isNotEmpty) {
        combinedCandidates.sort((a, b) => ((b['height'] as int?) ?? 0).compareTo((a['height'] as int?) ?? 0));
        final best = combinedCandidates.first;
        return PreviewStreamInfo(
          videoUrl: best['url'].toString(),
          httpHeaders: httpHeaders,
          label: '${best['height'] ?? 480}p (Combined)',
        );
      }

      // 2. Pair separate video stream (<= 720p) with audio stream
      String? videoUrl;
      String? audioUrl;
      int? videoHeight;

      for (final f in formats) {
        final map = f as Map<String, dynamic>;
        final vcodec = map['vcodec']?.toString();
        final acodec = map['acodec']?.toString();
        final height = map['height'] as int?;
        final url = map['url']?.toString();

        if (url == null) continue;

        if (videoUrl == null && vcodec != null && vcodec != 'none' && (height == null || height <= 720)) {
          videoUrl = url;
          videoHeight = height;
        }

        if (audioUrl == null && (vcodec == null || vcodec == 'none') && acodec != null && acodec != 'none') {
          audioUrl = url;
        }

        if (videoUrl != null && audioUrl != null) break;
      }

      if (videoUrl != null) {
        return PreviewStreamInfo(
          videoUrl: videoUrl,
          audioUrl: audioUrl,
          httpHeaders: httpHeaders,
          label: '${videoHeight ?? 720}p (Separate Audio)',
        );
      }

      // 3. Fallback: take first format with valid URL
      final firstWithUrl = formats.firstWhere(
        (f) => (f as Map<String, dynamic>)['url'] != null,
        orElse: () => null,
      );
      if (firstWithUrl != null) {
        final map = firstWithUrl as Map<String, dynamic>;
        return PreviewStreamInfo(
          videoUrl: map['url'].toString(),
          httpHeaders: httpHeaders,
          label: 'Default Stream',
        );
      }

      return null;
    } catch (e) {
      _logger.e('Error resolving preview stream: $e');
      return null;
    }
  }
}
