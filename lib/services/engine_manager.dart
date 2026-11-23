import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:logger/logger.dart';
import 'path_resolver.dart';
import 'process_runner.dart';

/// Status of the local download engine (yt-dlp and ffmpeg).
enum EngineStatus {
  uninitialized,
  ready,
  missingBinaries,
  error,
}

class EngineManager {
  final ProcessRunner _runner;
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      colors: false,
      printEmojis: false,
    ),
  );

  EngineStatus _status = EngineStatus.uninitialized;
  String? _ytDlpVersion;

  EngineManager({ProcessRunner? runner}) : _runner = runner ?? ProcessRunner();

  EngineStatus get status => _status;
  String? get ytDlpVersion => _ytDlpVersion;

  /// Returns the absolute path of the active yt-dlp binary.
  Future<File> getYtDlpFile() async {
    final engineDir = await PathResolver.getEngineDirectory();
    return File(p.join(engineDir.path, PathResolver.getYtDlpFileName()));
  }

  /// Returns the absolute path of the active ffmpeg binary.
  Future<File> getFfmpegFile() async {
    final engineDir = await PathResolver.getEngineDirectory();
    return File(p.join(engineDir.path, PathResolver.getFfmpegFileName()));
  }

  /// Ensures both yt-dlp and ffmpeg exist in the user's engine directory.
  /// If not found, attempts to seed from bundled assets.
  Future<bool> ensureEngineReady() async {
    try {
      final ytDlpFile = await getYtDlpFile();
      final ffmpegFile = await getFfmpegFile();

      // Check if yt-dlp needs seeding
      if (!await ytDlpFile.exists()) {
        await _seedBinaryFromAssets(PathResolver.getYtDlpFileName(), ytDlpFile);
      }

      // Check if ffmpeg needs seeding
      if (!await ffmpegFile.exists()) {
        await _seedBinaryFromAssets(PathResolver.getFfmpegFileName(), ffmpegFile);
      }

      // If either still doesn't exist, check system PATH as fallback
      if (!await ytDlpFile.exists() || !await ffmpegFile.exists()) {
        final hasSystemYtDlp = await _hasSystemBinary('yt-dlp');
        final hasSystemFfmpeg = await _hasSystemBinary('ffmpeg');
        if (hasSystemYtDlp && hasSystemFfmpeg) {
          _status = EngineStatus.ready;
          return true;
        }
        _status = EngineStatus.missingBinaries;
        return false;
      }

      // Validate engine with smoke test
      final versionResult = await _runner.run(
        executable: ytDlpFile.path,
        arguments: ['--version'],
        timeout: const Duration(seconds: 10),
      );

      if (versionResult.isSuccess) {
        _ytDlpVersion = versionResult.stdout.trim();
        _status = EngineStatus.ready;
        _logger.i('Engine ready: yt-dlp version $_ytDlpVersion');
        return true;
      } else {
        _logger.e('Failed to execute yt-dlp smoke test: ${versionResult.stderr}');
        _status = EngineStatus.error;
        return false;
      }
    } catch (e, stack) {
      _logger.e('Error initializing engine: $e', error: e, stackTrace: stack);
      _status = EngineStatus.error;
      return false;
    }
  }

  /// Copies a binary from bundled Flutter assets to the target file and ensures executable permission.
  Future<void> _seedBinaryFromAssets(String fileName, File destination) async {
    final platformKey = PathResolver.getPlatformKey();
    final assetPath = 'assets/engine/$platformKey/$fileName';

    try {
      final byteData = await rootBundle.load(assetPath);
      final bytes = byteData.buffer.asUint8List();
      await destination.parent.create(recursive: true);
      await destination.writeAsBytes(bytes, flush: true);

      // On Unix-like systems, set executable permission (0755)
      if (!Platform.isWindows) {
        await Process.run('chmod', ['+x', destination.path]);
      }
      _logger.i('Seeded engine binary $fileName to ${destination.path}');
    } catch (e) {
      _logger.w('Bundled asset not found: $assetPath ($e)');
    }
  }

  Future<bool> _hasSystemBinary(String name) async {
    try {
      final result = await Process.run('which', [name]);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }
}
