import 'package:flutter_test/flutter_test.dart';
import 'package:ctrl_video/services/preview_service.dart';

void main() {
  test('PreviewService: resolves combined progressive stream <= 720p', () {
    final metadata = {
      'http_headers': {
        'User-Agent': 'Mozilla/5.0 TestBrowser',
      },
      'formats': [
        {
          'format_id': '18',
          'url': 'https://video.test/360p.mp4',
          'vcodec': 'avc1.42001E',
          'acodec': 'mp4a.40.2',
          'height': 360,
        },
        {
          'format_id': '22',
          'url': 'https://video.test/720p.mp4',
          'vcodec': 'avc1.64001F',
          'acodec': 'mp4a.40.2',
          'height': 720,
        },
        {
          'format_id': '137',
          'url': 'https://video.test/1080p_video.mp4',
          'vcodec': 'avc1.640028',
          'acodec': 'none',
          'height': 1080,
        },
      ],
    };

    final service = PreviewService();
    final preview = service.resolvePreviewStream(metadata);

    expect(preview, isNotNull);
    expect(preview!.videoUrl, 'https://video.test/720p.mp4');
    expect(preview.httpHeaders['User-Agent'], 'Mozilla/5.0 TestBrowser');
  });

  test('PreviewService: pairs separate video and audio streams when combined is missing', () {
    final metadata = {
      'formats': [
        {
          'format_id': '136',
          'url': 'https://video.test/720p_video.mp4',
          'vcodec': 'avc1.4d401f',
          'acodec': 'none',
          'height': 720,
        },
        {
          'format_id': '140',
          'url': 'https://audio.test/audio.m4a',
          'vcodec': 'none',
          'acodec': 'mp4a.40.2',
        },
      ],
    };

    final service = PreviewService();
    final preview = service.resolvePreviewStream(metadata);

    expect(preview, isNotNull);
    expect(preview!.videoUrl, 'https://video.test/720p_video.mp4');
    expect(preview.audioUrl, 'https://audio.test/audio.m4a');
  });
}
