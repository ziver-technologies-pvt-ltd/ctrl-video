import 'package:flutter_test/flutter_test.dart';
import 'package:ctrl_video/services/trim_service.dart';

void main() {
  group('TrimRange timecode parsing and formatting', () {
    test('formats duration correctly with milliseconds', () {
      const range = TrimRange(
        start: Duration(minutes: 1, seconds: 12, milliseconds: 480),
        end: Duration(minutes: 2, seconds: 5, milliseconds: 0),
        mode: TrimMode.exact,
      );

      expect(range.formattedStart, '00:01:12.480');
      expect(range.formattedEnd, '00:02:05.000');
      expect(range.isValid, isTrue);
    });

    test('parses timecode string back into Duration', () {
      final parsed = TrimRange.parseTimecode('00:01:14.250');
      expect(parsed, isNotNull);
      expect(parsed!.inMilliseconds, 74250);
    });

    test('exact mode generates --force-keyframes-at-cuts', () {
      const range = TrimRange(
        start: Duration(seconds: 10),
        end: Duration(seconds: 30),
        mode: TrimMode.exact,
      );

      final args = range.toYtDlpArgs();
      expect(args.contains('--download-sections'), isTrue);
      expect(args.contains('*00:00:10.000-00:00:30.000'), isTrue);
      expect(args.contains('--force-keyframes-at-cuts'), isTrue);
    });

    test('fast mode omits keyframe force argument', () {
      const range = TrimRange(
        start: Duration(seconds: 10),
        end: Duration(minutes: 15),
        mode: TrimMode.fast,
      );

      final args = range.toYtDlpArgs();
      expect(args.contains('--download-sections'), isTrue);
      expect(args.contains('--force-keyframes-at-cuts'), isFalse);
    });

    test('invalid range generates empty arguments', () {
      const invalidRange = TrimRange(
        start: Duration(seconds: 30),
        end: Duration(seconds: 10),
      );
      expect(invalidRange.isValid, isFalse);
      expect(invalidRange.toYtDlpArgs(), isEmpty);
    });
  });

  group('TrimService recommendations', () {
    test('recommends exact mode for short clips <= 5 mins', () {
      expect(TrimService.recommendMode(const Duration(minutes: 2)), TrimMode.exact);
      expect(TrimService.recommendMode(const Duration(seconds: 45)), TrimMode.exact);
    });

    test('recommends fast mode for clips > 5 mins', () {
      expect(TrimService.recommendMode(const Duration(minutes: 12)), TrimMode.fast);
    });
  });
}
