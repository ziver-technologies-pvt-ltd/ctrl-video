import '../models/format_selection.dart';
import '../models/media_info.dart';

/// Detailed stream information parsed from raw metadata.
class StreamItem {
  final String formatId;
  final String ext;
  final int? height;
  final int? width;
  final int? fps;
  final String? vcodec;
  final String? acodec;
  final int? filesize;
  final double? tbr;
  final String dynamicRange; // SDR / HDR
  final bool isVideoOnly;
  final bool isAudioOnly;
  final bool isCombined;

  const StreamItem({
    required this.formatId,
    required this.ext,
    this.height,
    this.width,
    this.fps,
    this.vcodec,
    this.acodec,
    this.filesize,
    this.tbr,
    this.dynamicRange = 'SDR',
    required this.isVideoOnly,
    required this.isAudioOnly,
    required this.isCombined,
  });

  String get resolutionLabel => height != null ? '${height}p' : ext.toUpperCase();

  String get formattedSize {
    if (filesize == null || filesize! <= 0) return '≈ Size unknown';
    final mb = filesize! / (1024 * 1024);
    if (mb >= 1024) return '≈ ${(mb / 1024).toStringAsFixed(1)} GB';
    return '≈ ${mb.toStringAsFixed(1)} MB';
  }

  String get codecLabel {
    if (isVideoOnly) return _simplifyCodec(vcodec);
    if (isAudioOnly) return _simplifyCodec(acodec);
    return '${_simplifyCodec(vcodec)} / ${_simplifyCodec(acodec)}';
  }

  String _simplifyCodec(String? c) {
    if (c == null || c == 'none') return '';
    final lower = c.toLowerCase();
    if (lower.contains('avc1') || lower.contains('h264')) return 'H.264';
    if (lower.contains('vp9')) return 'VP9';
    if (lower.contains('av01') || lower.contains('av1')) return 'AV1';
    if (lower.contains('mp4a') || lower.contains('aac')) return 'AAC';
    if (lower.contains('opus')) return 'Opus';
    if (lower.contains('mp3')) return 'MP3';
    return c.split('.')[0];
  }

  factory StreamItem.fromJson(Map<String, dynamic> json) {
    final vcodec = json['vcodec']?.toString();
    final acodec = json['acodec']?.toString();
    final hasVideo = vcodec != null && vcodec != 'none';
    final hasAudio = acodec != null && acodec != 'none';

    final isVideoOnly = hasVideo && !hasAudio;
    final isAudioOnly = !hasVideo && hasAudio;
    final isCombined = hasVideo && hasAudio;

    final filesize = (json['filesize'] as num?)?.toInt() ??
        (json['filesize_approx'] as num?)?.toInt();

    final dynamicRange = json['dynamic_range']?.toString() ?? 'SDR';

    return StreamItem(
      formatId: json['format_id']?.toString() ?? '',
      ext: json['ext']?.toString() ?? 'mp4',
      height: json['height'] as int?,
      width: json['width'] as int?,
      fps: (json['fps'] as num?)?.toInt(),
      vcodec: vcodec,
      acodec: acodec,
      filesize: filesize,
      tbr: (json['tbr'] as num?)?.toDouble(),
      dynamicRange: dynamicRange,
      isVideoOnly: isVideoOnly,
      isAudioOnly: isAudioOnly,
      isCombined: isCombined,
    );
  }
}

/// Service that classifies and structures available streams for advanced format picking.
class FormatService {
  FormatService._();

  static List<StreamItem> parseRawStreams(Map<String, dynamic> rawMetadata) {
    final formats = rawMetadata['formats'] as List<dynamic>? ?? [];
    return formats
        .map((f) => StreamItem.fromJson(f as Map<String, dynamic>))
        .where((s) => s.formatId.isNotEmpty)
        .toList();
  }

  static List<StreamItem> getCombinedStreams(List<StreamItem> streams) {
    return streams.where((s) => s.isCombined).toList()
      ..sort((a, b) => (b.height ?? 0).compareTo(a.height ?? 0));
  }

  static List<StreamItem> getVideoOnlyStreams(List<StreamItem> streams) {
    return streams.where((s) => s.isVideoOnly).toList()
      ..sort((a, b) => (b.height ?? 0).compareTo(a.height ?? 0));
  }

  static List<StreamItem> getAudioOnlyStreams(List<StreamItem> streams) {
    return streams.where((s) => s.isAudioOnly).toList()
      ..sort((a, b) => (b.tbr ?? 0).compareTo(a.tbr ?? 0));
  }
}
