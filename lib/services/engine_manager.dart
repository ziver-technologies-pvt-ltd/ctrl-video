import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:logger/logger.dart';
import 'engine_update_service.dart';
import 'path_resolver.dart';
import 'process_runner.dart';

enum EngineStatus {
  uninitialized,
  ready,
  updating,
  missingBinaries,
  error,
}

class EngineManager {
  final ProcessRunner _runner;
  final EngineUpdateService _updateService;
  final Logger _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, colors: false, printEmojis: false),
  );

  EngineStatus _status = EngineStatus.uninitialized;
  String? _ytDlpVersion;

  EngineManager({
    ProcessRunner? runner,
    EngineUpdateService? updateService,
  })  : _runner = runner ?? ProcessRunner(),
        _updateService = updateService ?? EngineUpdateService();

  EngineStatus get status => _status;
  String? get ytDlpVersion => _ytDlpVersion;

  Future<File> getYtDlpFile() async {
    final engineDir = await PathResolver.getEngineDirectory();
    return File(p.join(engineDir.path, PathResolver.getYtDlpFileName()));
  }

  Future<File> getFfmpegFile() async {
    final engineDir = await PathResolver.getEngineDirectory();
    return File(p.join(engineDir.path, PathResolver.getFfmpegFileName()));
  }

  Future<File> getYtDlpPrevFile() async {
    final engineDir = await PathResolver.getEngineDirectory();
    final name = PathResolver.getYtDlpFileName();
    return File(p.join(engineDir.path, '$name.prev'));
  }

  /// Ensures both yt-dlp and ffmpeg exist and are validated.
  Future<bool> ensureEngineReady() async {
    try {
      final ytDlpFile = await getYtDlpFile();
      final ffmpegFile = await getFfmpegFile();

      if (!await ytDlpFile.exists()) {
        await _seedBinaryFromAssets(PathResolver.getYtDlpFileName(), ytDlpFile);
      }

      if (!await ffmpegFile.exists()) {
        await _seedBinaryFromAssets(PathResolver.getFfmpegFileName(), ffmpegFile);
      }

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

      return await _runSmokeTest(ytDlpFile);
    } catch (e) {
      _logger.e('Error initializing engine: $e');
      _status = EngineStatus.error;
      return false;
    }
  }

  /// Updates yt-dlp with atomic swap, checksum validation, and rollback to .prev.
  Future<bool> updateEngine({void Function(double progress)? onProgress}) async {
    _status = EngineStatus.updating;
    final release = await _updateService.checkLatestRelease();
    if (release == null) {
      _logger.w('No updates found or failed to fetch release info.');
      _status = EngineStatus.ready;
      return false;
    }

    final engineDir = await PathResolver.getEngineDirectory();
    final currentBinary = await getYtDlpFile();
    final prevBinary = await getYtDlpPrevFile();
    final tempBinary = File(p.join(engineDir.path, 'yt-dlp.tmp'));

    try {
      // 1. Download and verify hash into temp file
      final verified = await _updateService.downloadAndVerify(
        release: release,
        targetFile: tempBinary,
        onProgress: onProgress,
      );

      if (!verified) {
        _logger.e('Verification failed during engine update.');
        _status = EngineStatus.error;
        return false;
      }

      // 2. Chmod executable
      if (!Platform.isWindows) {
        await Process.run('chmod', ['+x', tempBinary.path]);
      }

      // 3. Smoke test the new binary before replacing current
      final smokePassed = await _runSmokeTest(tempBinary);
      if (!smokePassed) {
        _logger.e('New binary failed smoke test. Aborting update.');
        if (await tempBinary.exists()) await tempBinary.delete();
        _status = EngineStatus.ready;
        return false;
      }

      // 4. Atomic swap: backup current to .prev and rename temp to active
      if (await currentBinary.exists()) {
        if (await prevBinary.exists()) await prevBinary.delete();
        await currentBinary.rename(prevBinary.path);
      }
      await tempBinary.rename(currentBinary.path);

      _status = EngineStatus.ready;
      _logger.i('Engine successfully updated to version $_ytDlpVersion');
      return true;
    } catch (e) {
      _logger.e('Exception during engine update: $e. Attempting rollback.');
      await _rollback(currentBinary, prevBinary);
      _status = EngineStatus.ready;
      return false;
    }
  }

  Future<void> _rollback(File current, File prev) async {
    if (await prev.exists()) {
      if (await current.exists()) await current.delete();
      await prev.rename(current.path);
      await _runSmokeTest(current);
      _logger.i('Rolled back engine to previous version.');
    }
  }

  Future<bool> _runSmokeTest(File binary) async {
    final result = await _runner.run(
      executable: binary.path,
      arguments: ['--version'],
      timeout: const Duration(seconds: 10),
    );

    if (result.isSuccess) {
      _ytDlpVersion = result.stdout.trim();
      _status = EngineStatus.ready;
      return true;
    } else {
      _status = EngineStatus.error;
      return false;
    }
  }

  Future<void> _seedBinaryFromAssets(String fileName, File destination) async {
    final platformKey = PathResolver.getPlatformKey();
    final candidatePaths = [
      'assets/engine/$platformKey/$fileName',
      if (Platform.isMacOS) ...[
        // Fallback for macOS if architecture string wasn't matched
        'assets/engine/macos-arm64/$fileName',
        'assets/engine/macos-x64/$fileName',
      ],
      'assets/engine/$fileName',
    ];

    for (final assetPath in candidatePaths) {
      try {
        final byteData = await rootBundle.load(assetPath);
        final bytes = byteData.buffer.asUint8List();
        await destination.parent.create(recursive: true);
        await destination.writeAsBytes(bytes, flush: true);

        if (!Platform.isWindows) {
          await Process.run('chmod', ['+x', destination.path]);
        }
        _logger.i('Successfully seeded $fileName from $assetPath to ${destination.path}');
        return;
      } catch (_) {
        // Continue to next candidate path
      }
    }

    _logger.w('Failed to seed $fileName from assets. Checked paths: $candidatePaths');
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
