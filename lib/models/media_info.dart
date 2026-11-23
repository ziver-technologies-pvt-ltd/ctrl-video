/// Represents an available download format or quality level.
class FormatOption {
  final String formatId;
  final String ext;
  final int? height;
  final String? videoCodec;
  final String? audioCodec;
  final int? filesizeBytes;
  final String label;
  final bool isAudioOnly;

  const FormatOption({
    required this.formatId,
    required this.ext,
    this.height,
    this.videoCodec,
    this.audioCodec,
    this.filesizeBytes,
    required this.label,
    this.isAudioOnly = false,
  });

  String get formattedSize {
    if (filesizeBytes == null || filesizeBytes! <= 0) return '';
    final mb = filesizeBytes! / (1024 * 1024);
    if (mb >= 1024) {
      final gb = mb / 1024;
      return '${gb.toStringAsFixed(1)} GB';
    }
    return '${mb.toStringAsFixed(1)} MB';
  }

  factory FormatOption.fromJson(Map<String, dynamic> json) {
    final formatId = json['format_id']?.toString() ?? 'best';
    final ext = json['ext']?.toString() ?? 'mp4';
    final height = json['height'] as int?;
    final vcodec = json['vcodec']?.toString();
    final acodec = json['acodec']?.toString();
    final filesize = (json['filesize'] as num?)?.toInt() ??
        (json['filesize_approx'] as num?)?.toInt();

    final isAudioOnly = (vcodec == 'none' || vcodec == null) &&
        (acodec != 'none' && acodec != null);

    String label;
    if (isAudioOnly) {
      label = 'Audio Only ($ext)';
    } else if (height != null) {
      label = '${height}p ($ext)';
    } else {
      label = json['format_note']?.toString() ?? formatId;
    }

    return FormatOption(
      formatId: formatId,
      ext: ext,
      height: height,
      videoCodec: vcodec,
      audioCodec: acodec,
      filesizeBytes: filesize,
      label: label,
      isAudioOnly: isAudioOnly,
    );
  }
}

/// Metadata extracted for a video or audio link.
class MediaInfo {
  final String url;
  final String platform;
  final String id;
  final String title;
  final String? thumbnailUrl;
  final int? durationSeconds;
  final String? uploader;
  final List<FormatOption> formats;
  final Map<String, dynamic>? rawJson;

  const MediaInfo({
    required this.url,
    required this.platform,
    required this.id,
    required this.title,
    this.thumbnailUrl,
    this.durationSeconds,
    this.uploader,
    this.formats = const [],
    this.rawJson,
  });

  String get formattedDuration {
    if (durationSeconds == null) return '';
    final duration = Duration(seconds: durationSeconds!);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = duration.inHours;
    if (hours > 0) {
      return '$hours:${minutes.remainder(60).toString().padLeft(2, '0')}:$seconds';
    }
    return '$minutes:$seconds';
  }

  factory MediaInfo.fromJson(Map<String, dynamic> json, String originalUrl) {
    final extractorKey = json['extractor_key']?.toString().toLowerCase() ?? '';
    String platform = 'generic';
    if (extractorKey.contains('youtube')) {
      platform = 'YouTube';
    } else if (extractorKey.contains('instagram')) {
      platform = 'Instagram';
    } else if (extractorKey.contains('facebook')) {
      platform = 'Facebook';
    }

    final rawFormats = json['formats'] as List<dynamic>? ?? [];
    final parsedFormats = <FormatOption>[];

    // Standard preset format choices
    parsedFormats.add(const FormatOption(
      formatId: 'bestvideo*+bestaudio/best',
      ext: 'mp4',
      label: 'Best Available (Auto)',
    ));
    parsedFormats.add(const FormatOption(
      formatId: 'bv*[height<=1080]+ba/b[height<=1080]',
      ext: 'mp4',
      height: 1080,
      label: '1080p Full HD (MP4)',
    ));
    parsedFormats.add(const FormatOption(
      formatId: 'bv*[height<=720]+ba/b[height<=720]',
      ext: 'mp4',
      height: 720,
      label: '720p HD (MP4)',
    ));
    parsedFormats.add(const FormatOption(
      formatId: 'bv*[height<=480]+ba/b[height<=480]',
      ext: 'mp4',
      height: 480,
      label: '480p SD (MP4)',
    ));
    parsedFormats.add(const FormatOption(
      formatId: 'ba/b',
      ext: 'mp3',
      label: 'Audio Only (MP3)',
      isAudioOnly: true,
    ));

    return MediaInfo(
      url: originalUrl,
      platform: platform,
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Video',
      thumbnailUrl: json['thumbnail']?.toString(),
      durationSeconds: (json['duration'] as num?)?.toInt(),
      uploader: json['uploader']?.toString() ?? json['channel']?.toString(),
      formats: parsedFormats,
      rawJson: json,
    );
  }
}
