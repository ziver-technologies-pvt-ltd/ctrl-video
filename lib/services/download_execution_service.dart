import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import '../models/media_info.dart';
import 'engine_manager.dart';
import 'error_classifier.dart';
import 'path_resolver.dart';
import 'process_runner.dart';

enum DownloadStatus {
  idle,
  downloading,
  completed,
  failed,
  cancelled,
}

class DownloadProgress {
  final double percent; // 0.0 to 100.0
  final String speed;
  final String eta;

  const DownloadProgress({
    this.percent = 0.0,
    this.speed = '--',
    this.eta = '--',
  });
}

class DownloadExecutionService {
  final EngineManager _engineManager;
  final ProcessRunner _runner;
  Process? _activeProcess;

  DownloadExecutionService({
    required EngineManager engineManager,
    ProcessRunner? runner,
  })  : _engineManager = engineManager,
        _runner = runner ?? ProcessRunner();

  /// Starts downloading a media link with the selected format option.
  /// Emits real-time progress through onProgress callback.
  Future<String> startDownload({
    required MediaInfo mediaInfo,
    required FormatOption format,
    Directory? destinationDir,
    required void Function(DownloadProgress progress) onProgress,
  }) async {
    final ytDlpFile = await _engineManager.getYtDlpFile();
    final ffmpegFile = await _engineManager.getFfmpegFile();
    final targetFolder = destinationDir ?? await PathResolver.getDefaultDownloadsDirectory();

    final args = <String>[
      '--no-playlist',
      '--newline',
      '--continue',
      if (await ffmpegFile.exists()) ...[
        '--ffmpeg-location',
        ffmpegFile.parent.path,
      ],
    ];

    if (format.isAudioOnly) {
      args.addAll([
        '-x',
        '--audio-format',
        format.ext.isNotEmpty ? format.ext : 'mp3',
        '--audio-quality',
        '0',
      ]);
    } else {
      args.addAll([
        '-f',
        format.formatId,
        '--merge-output-format',
        'mp4',
      ]);
    }

    final outputTemplate = p.join(
      targetFolder.path,
      '%(title).150B [%(id)s].%(ext)s',
    );

    args.addAll([
      '-o',
      outputTemplate,
      '--progress-template',
      'download:%(progress._percent_str)s|%(progress._speed_str)s|%(progress._eta_str)s',
      '--',
      mediaInfo.url,
    ]);

    final stderrLines = <String>[];
    final completer = Completer<String>();

    try {
      _activeProcess = await _runner.startStreaming(
        executable: ytDlpFile.path,
        arguments: args,
        onStdoutLine: (line) {
          if (line.startsWith('download:')) {
            final parts = line.replaceFirst('download:', '').split('|');
            if (parts.length >= 3) {
              final rawPercent = parts[0].replaceAll('%', '').trim();
              final percent = double.tryParse(rawPercent) ?? 0.0;
              final speed = parts[1].trim();
              final eta = parts[2].trim();
              onProgress(DownloadProgress(
                percent: percent,
                speed: speed.isNotEmpty ? speed : '--',
                eta: eta.isNotEmpty ? eta : '--',
              ));
            }
          }
        },
        onStderrLine: (line) {
          stderrLines.add(line);
        },
      );

      final exitCode = await _activeProcess!.exitCode;
      _activeProcess = null;

      if (exitCode == 0) {
        onProgress(const DownloadProgress(percent: 100.0, speed: 'Done', eta: '0s'));
        completer.complete(targetFolder.path);
      } else {
        final error = ErrorClassifier.classify(stderrLines.join('\n'));
        completer.completeError(error);
      }
    } catch (e) {
      completer.completeError(e);
    }

    return completer.future;
  }

  void cancel() {
    if (_activeProcess != null) {
      _activeProcess!.kill(ProcessSignal.sigkill);
      _activeProcess = null;
    }
  }
}
