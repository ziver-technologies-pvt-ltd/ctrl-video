import 'package:flutter_test/flutter_test.dart';
import 'package:ctrl_video/services/error_classifier.dart';
import 'package:ctrl_video/services/metadata_service.dart';

void main() {
  group('MetadataService URL validation', () {
    test('accepts valid YouTube URLs', () {
      expect(MetadataService.isValidUrl('https://www.youtube.com/watch?v=dQw4w9WgXcQ'), isTrue);
      expect(MetadataService.isValidUrl('https://youtu.be/dQw4w9WgXcQ'), isTrue);
      expect(MetadataService.isValidUrl('https://youtube.com/shorts/3xyz123'), isTrue);
    });

    test('accepts valid Instagram URLs', () {
      expect(MetadataService.isValidUrl('https://www.instagram.com/reel/C7XYZ123/'), isTrue);
      expect(MetadataService.isValidUrl('https://instagram.com/p/C7XYZ123/'), isTrue);
    });

    test('accepts valid Facebook URLs', () {
      expect(MetadataService.isValidUrl('https://www.facebook.com/watch/?v=123456789'), isTrue);
      expect(MetadataService.isValidUrl('https://fb.watch/xyz123/'), isTrue);
    });

    test('rejects arbitrary unsupported domains', () {
      expect(MetadataService.isValidUrl('https://google.com'), isFalse);
      expect(MetadataService.isValidUrl('https://tiktok.com/@user/video/123'), isFalse);
      expect(MetadataService.isValidUrl('not-a-url'), isFalse);
    });
  });

  group('ErrorClassifier tests', () {
    test('classifies private videos correctly', () {
      final classified = ErrorClassifier.classify('ERROR: [youtube] dQw4w: Private video. Sign in if you\'ve been granted access');
      expect(classified.code, DownloadErrorCode.privateVideo);
    });

    test('classifies geo-blocked videos correctly', () {
      final classified = ErrorClassifier.classify('ERROR: [youtube] Video unavailable in your country due to rights restrictions');
      expect(classified.code, DownloadErrorCode.geoBlocked);
    });

    test('classifies rate-limits correctly', () {
      final classified = ErrorClassifier.classify('HTTP Error 429: Too Many Requests');
      expect(classified.code, DownloadErrorCode.rateLimited);
    });

    test('classifies network errors correctly', () {
      final classified = ErrorClassifier.classify('URLError: <urlopen error [Errno -2] Name or service not known>');
      expect(classified.code, DownloadErrorCode.network);
    });
  });
}
