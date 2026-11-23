import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Resolves directories for user app data, engine binaries, downloads, and logs.
class PathResolver {
  PathResolver._();

  static Directory? _cachedAppDataDir;

  /// Returns the per-user data directory for ctrl_video:
  /// - Linux: ~/.local/share/ctrl_video
  /// - macOS: ~/Library/Application Support/ctrl_video
  /// - Windows: %APPDATA%/ctrl_video
  static Future<Directory> getAppDataDirectory() async {
    if (_cachedAppDataDir != null) return _cachedAppDataDir!;

    final supportDir = await getApplicationSupportDirectory();
    final appDir = Directory(p.join(supportDir.path, 'ctrl_video'));
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    _cachedAppDataDir = appDir;
    return appDir;
  }

  /// The engine directory where the active yt-dlp and ffmpeg binaries reside.
  static Future<Directory> getEngineDirectory() async {
    final appData = await getAppDataDirectory();
    final engineDir = Directory(p.join(appData.path, 'engine'));
    if (!await engineDir.exists()) {
      await engineDir.create(recursive: true);
    }
    return engineDir;
  }

  /// Default downloads directory (user's system Downloads folder).
  static Future<Directory> getDefaultDownloadsDirectory() async {
    final downloads = await getDownloadsDirectory();
    if (downloads != null) return downloads;
    final appData = await getAppDataDirectory();
    final fallback = Directory(p.join(appData.path, 'downloads'));
    if (!await fallback.exists()) {
      await fallback.create(recursive: true);
    }
    return fallback;
  }

  /// Directory for rotating diagnostic log files.
  static Future<Directory> getLogsDirectory() async {
    final appData = await getAppDataDirectory();
    final logsDir = Directory(p.join(appData.path, 'logs'));
    if (!await logsDir.exists()) {
      await logsDir.create(recursive: true);
    }
    return logsDir;
  }

  /// Helper to get current OS platform key.
  static String getPlatformKey() {
    if (Platform.isLinux) return 'linux-x64';
    if (Platform.isWindows) return 'windows-x64';
    if (Platform.isMacOS) {
      // In Dart/Flutter, detect arm64 architecture if possible
      final isArm64 = Platform.version.contains('arm64') ||
          Platform.version.contains('aarch64');
      return isArm64 ? 'macos-arm64' : 'macos-x64';
    }
    return 'unknown';
  }

  /// Binary file name for yt-dlp on the current OS.
  static String getYtDlpFileName() =>
      Platform.isWindows ? 'yt-dlp.exe' : 'yt-dlp';

  /// Binary file name for ffmpeg on the current OS.
  static String getFfmpegFileName() =>
      Platform.isWindows ? 'ffmpeg.exe' : 'ffmpeg';
}
