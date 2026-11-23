import 'dart:convert';
import 'package:logger/logger.dart';
import '../models/media_info.dart';
import 'engine_manager.dart';
import 'error_classifier.dart';
import 'process_runner.dart';

/// Service responsible for validating video URLs and extracting metadata via yt-dlp.
class MetadataService {
  final EngineManager _engineManager;
  final ProcessRunner _runner;
  final Logger _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, colors: false, printEmojis: false),
  );

  static final List<RegExp> _allowedHosts = [
    RegExp(r'^(https?:\/\/)?(www\.)?(youtube\.com|youtu\.be)\/.*$', caseSensitive: false),
    RegExp(r'^(https?:\/\/)?(www\.)?(instagram\.com)\/.*$', caseSensitive: false),
    RegExp(r'^(https?:\/\/)?(www\.)?(facebook\.com|fb\.watch)\/.*$', caseSensitive: false),
  ];

  MetadataService({
    required EngineManager engineManager,
    ProcessRunner? runner,
  })  : _engineManager = engineManager,
        _runner = runner ?? ProcessRunner();

  /// Validates if a URL matches one of the supported platforms.
  static bool isValidUrl(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return false;
    final uri = Uri.tryParse(trimmed);
    if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      return false;
    }
    return _allowedHosts.any((regex) => regex.hasMatch(trimmed));
  }

  /// Fetches media metadata using yt-dlp --dump-single-json.
  Future<MediaInfo> fetchMetadata(String url) async {
    final trimmed = url.trim();
    if (!isValidUrl(trimmed)) {
      throw const FormatException('URL is not from a supported platform (YouTube, Instagram, Facebook)');
    }

    final ytDlpFile = await _engineManager.getYtDlpFile();
    if (!await ytDlpFile.exists()) {
      await _engineManager.ensureEngineReady();
    }

    final args = [
      '--dump-single-json',
      '--no-playlist',
      '--no-warnings',
      '--', // Prevent flag injection
      trimmed,
    ];

    final result = await _runner.run(
      executable: ytDlpFile.path,
      arguments: args,
      timeout: const Duration(seconds: 40),
    );

    if (!result.isSuccess) {
      final classified = ErrorClassifier.classify(result.stderr);
      _logger.e('Metadata fetch error: ${classified.userMessage}\n${result.stderr}');
      throw classified;
    }

    try {
      final jsonMap = json.decode(result.stdout) as Map<String, dynamic>;
      return MediaInfo.fromJson(jsonMap, trimmed);
    } catch (e, stack) {
      _logger.e('Failed to parse metadata JSON: $e', error: e, stackTrace: stack);
      throw FormatException('Failed to parse media metadata: $e');
    }
  }
}
