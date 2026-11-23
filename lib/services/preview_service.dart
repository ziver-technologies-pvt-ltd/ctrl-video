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
        final protocol = map['protocol']?.toString() ?? '';

        // Exclude m3u8_native or manifest urls if protocol is specified
        final isDirect = protocol.isEmpty || (protocol.startsWith('http') && !protocol.contains('m3u8'));

        if (url != null &&
            isDirect &&
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
        final streamHeaders = Map<String, String>.from(httpHeaders);
        if (best['http_headers'] is Map) {
          (best['http_headers'] as Map).forEach((k, v) => streamHeaders[k.toString()] = v.toString());
        }
        return PreviewStreamInfo(
          videoUrl: best['url'].toString(),
          httpHeaders: streamHeaders,
          label: '${best['height'] ?? 480}p (Combined)',
        );
      }

      // 2. Pair separate video stream (prefer 360p or 480p or 720p direct HTTPS) with audio stream
      String? videoUrl;
      String? audioUrl;
      int? videoHeight;
      Map<String, String> videoHeaders = Map.from(httpHeaders);

      // Prefer 360p-720p direct HTTPS MP4/WebM video
      final videoCandidates = <Map<String, dynamic>>[];
      final audioCandidates = <Map<String, dynamic>>[];

      for (final f in formats) {
        final map = Map<String, dynamic>.from(f as Map);
        final vcodec = map['vcodec']?.toString();
        final acodec = map['acodec']?.toString();
        final height = map['height'] as int?;
        final url = map['url']?.toString();
        final protocol = map['protocol']?.toString() ?? '';
        final isDirect = protocol.isEmpty || (protocol.startsWith('http') && !protocol.contains('m3u8'));

        if (url == null || !isDirect) continue;

        if (vcodec != null && vcodec != 'none' && (acodec == null || acodec == 'none')) {
          if (height == null || height <= 720) {
            videoCandidates.add(map);
          }
        } else if ((vcodec == null || vcodec == 'none') && acodec != null && acodec != 'none') {
          audioCandidates.add(map);
        }
      }

      if (videoCandidates.isNotEmpty) {
        // Sort descending by height, but prefer <= 720
        videoCandidates.sort((a, b) => ((b['height'] as int?) ?? 0).compareTo((a['height'] as int?) ?? 0));
        // Pick best video (ideally 480p or 720p or 360p)
        Map<String, dynamic> bestVideo = videoCandidates.first;
        for (final cand in videoCandidates) {
          final h = (cand['height'] as int?) ?? 0;
          if (h <= 720 && h >= 360) {
            bestVideo = cand;
            break;
          }
        }

        videoUrl = bestVideo['url'].toString();
        videoHeight = bestVideo['height'] as int?;
        if (bestVideo['http_headers'] is Map) {
          (bestVideo['http_headers'] as Map).forEach((k, v) => videoHeaders[k.toString()] = v.toString());
        }
      }

      if (audioCandidates.isNotEmpty) {
        // Sort descending by abr or filesize
        audioCandidates.sort((a, b) => ((b['abr'] as num?) ?? 0).compareTo((a['abr'] as num?) ?? 0));
        audioUrl = audioCandidates.first['url']?.toString();
      }

      if (videoUrl != null) {
        return PreviewStreamInfo(
          videoUrl: videoUrl,
          audioUrl: audioUrl,
          httpHeaders: videoHeaders,
          label: '${videoHeight ?? 720}p (Direct)',
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
