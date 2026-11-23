import 'package:flutter_test/flutter_test.dart';
import 'package:ctrl_video/models/format_selection.dart';

void main() {
  group('FormatSelection toYtDlpArgs tests', () {
    test('Simple video preset generates correct format and merge container', () {
      final selection = FormatSelection.simplePreset('1080p', container: 'mp4');
      final args = selection.toYtDlpArgs();

      expect(args.contains('-f'), isTrue);
      expect(args.contains('bv*[height<=1080]+ba/b'), isTrue);
      expect(args.contains('--merge-output-format'), isTrue);
      expect(args.contains('mp4'), isTrue);
    });

    test('MKV container selection properly passed', () {
      final selection = FormatSelection.simplePreset('720p', container: 'mkv');
      final args = selection.toYtDlpArgs();

      final mergeIndex = args.indexOf('--merge-output-format');
      expect(mergeIndex != -1, isTrue);
      expect(args[mergeIndex + 1], 'mkv');
    });

    test('Audio only MP3 generates extract and quality arguments', () {
      final selection = FormatSelection.simplePreset('audio_mp3');
      final args = selection.toYtDlpArgs();

      expect(args.contains('-x'), isTrue);
      expect(args.contains('--audio-format'), isTrue);
      final fmtIndex = args.indexOf('--audio-format');
      expect(args[fmtIndex + 1], 'mp3');
      expect(args.contains('--audio-quality'), isTrue);
      final qIndex = args.indexOf('--audio-quality');
      expect(args[qIndex + 1], '0');
    });

    test('Audio only FLAC generates flac audio format', () {
      final selection = FormatSelection.simplePreset('audio_flac');
      final args = selection.toYtDlpArgs();

      expect(args.contains('-x'), isTrue);
      final fmtIndex = args.indexOf('--audio-format');
      expect(args[fmtIndex + 1], 'flac');
    });

    test('Advanced custom stream ID combination', () {
      const selection = FormatSelection(
        videoFormatId: '399',
        audioFormatId: '140',
        container: 'mp4',
        label: '1080p AV1 + AAC',
      );
      final args = selection.toYtDlpArgs();

      expect(args.contains('-f'), isTrue);
      final fIndex = args.indexOf('-f');
      expect(args[fIndex + 1], '399+140/b');
      expect(args.contains('--merge-output-format'), isTrue);
      expect(args.contains('mp4'), isTrue);
    });
  });
}
