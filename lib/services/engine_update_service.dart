import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'path_resolver.dart';

class ReleaseInfo {
  final String version;
  final String downloadUrl;
  final String checksumsUrl;

  const ReleaseInfo({
    required this.version,
    required this.downloadUrl,
    required this.checksumsUrl,
  });
}

/// Service to check, download, and verify new yt-dlp releases from GitHub.
class EngineUpdateService {
  final http.Client _client;
  final Logger _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, colors: false, printEmojis: false),
  );

  EngineUpdateService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches the latest yt-dlp release metadata from the GitHub API.
  Future<ReleaseInfo?> checkLatestRelease() async {
    const url = 'https://api.github.com/repos/yt-dlp/yt-dlp/releases/latest';
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      if (response.statusCode != 200) {
        _logger.w('GitHub release check returned status: ${response.statusCode}');
        return null;
      }

      final jsonMap = json.decode(response.body) as Map<String, dynamic>;
      final tagName = jsonMap['tag_name']?.toString() ?? '';
      final assets = jsonMap['assets'] as List<dynamic>? ?? [];

      String? downloadUrl;
      String? checksumsUrl;

      final targetAssetName = PathResolver.getYtDlpFileName();

      for (final asset in assets) {
        final name = asset['name']?.toString() ?? '';
        final browserUrl = asset['browser_download_url']?.toString() ?? '';

        if (name == targetAssetName) {
          downloadUrl = browserUrl;
        } else if (name == 'SHA2-256SUMS') {
          checksumsUrl = browserUrl;
        }
      }

      if (downloadUrl != null && checksumsUrl != null) {
        return ReleaseInfo(
          version: tagName,
          downloadUrl: downloadUrl,
          checksumsUrl: checksumsUrl,
        );
      }
      return null;
    } catch (e) {
      _logger.e('Error checking latest yt-dlp release: $e');
      return null;
    }
  }

  /// Downloads release asset to a destination file and verifies its SHA-256 hash.
  Future<bool> downloadAndVerify({
    required ReleaseInfo release,
    required File targetFile,
    void Function(double progress)? onProgress,
  }) async {
    try {
      // 1. Fetch checksums file
      final checksumsResponse = await _client.get(Uri.parse(release.checksumsUrl));
      if (checksumsResponse.statusCode != 200) {
        _logger.e('Failed to fetch SHA2-256SUMS');
        return false;
      }

      final expectedHash = _parseExpectedHash(
        checksumsResponse.body,
        PathResolver.getYtDlpFileName(),
      );

      if (expectedHash == null) {
        _logger.e('Expected hash not found in checksums file');
        return false;
      }

      // 2. Download binary to target file
      final request = http.Request('GET', Uri.parse(release.downloadUrl));
      final streamedResponse = await _client.send(request);

      final totalBytes = streamedResponse.contentLength ?? 0;
      var receivedBytes = 0;

      final fileSink = targetFile.openWrite();

      await for (final chunk in streamedResponse.stream) {
        fileSink.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0 && onProgress != null) {
          onProgress(receivedBytes / totalBytes);
        }
      }
      await fileSink.flush();
      await fileSink.close();

      // 3. Compute SHA-256 and verify
      final bytes = await targetFile.readAsBytes();
      final actualHash = sha256.convert(bytes).toString().toLowerCase();

      if (actualHash == expectedHash.toLowerCase()) {
        _logger.i('Checksum verified successfully: $actualHash');
        return true;
      } else {
        _logger.e('Checksum mismatch! Expected: $expectedHash, Actual: $actualHash');
        if (await targetFile.exists()) {
          await targetFile.delete();
        }
        return false;
      }
    } catch (e) {
      _logger.e('Failed to download and verify release: $e');
      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      return false;
    }
  }

  String? _parseExpectedHash(String checksumsContent, String fileName) {
    final lines = checksumsContent.split('\n');
    for (final line in lines) {
      final parts = line.trim().split(RegExp(r'\s+'));
      if (parts.length >= 2 && parts[1].endsWith(fileName)) {
        return parts[0].trim();
      }
    }
    return null;
  }
}
