/// Categorized error types for download and extraction failures.
enum DownloadErrorCode {
  unsupportedUrl,
  privateVideo,
  unavailable,
  geoBlocked,
  rateLimited,
  engineOutdated,
  network,
  disk,
  unknown,
}

class ClassifiedError {
  final DownloadErrorCode code;
  final String userMessage;
  final String? suggestedAction;
  final String rawStderr;

  const ClassifiedError({
    required this.code,
    required this.userMessage,
    this.suggestedAction,
    required this.rawStderr,
  });
}

/// Classifies yt-dlp stderr output into structured, user-friendly errors.
class ErrorClassifier {
  ErrorClassifier._();

  static ClassifiedError classify(String stderr) {
    final lower = stderr.toLowerCase();

    if (lower.contains('unsupported url') || lower.contains('is not a valid url')) {
      return ClassifiedError(
        code: DownloadErrorCode.unsupportedUrl,
        userMessage: "This link isn't supported yet.",
        suggestedAction: "Please enter a valid YouTube, Instagram, or Facebook link.",
        rawStderr: stderr,
      );
    }

    if (lower.contains('sign in') ||
        lower.contains('private video') ||
        lower.contains('this video is private') ||
        lower.contains('login required')) {
      return ClassifiedError(
        code: DownloadErrorCode.privateVideo,
        userMessage: "This video requires login or is private.",
        suggestedAction: "Private and age-restricted links are not supported in this version.",
        rawStderr: stderr,
      );
    }

    if (lower.contains('not available in your country') ||
        lower.contains('unavailable in your country') ||
        lower.contains('unavailable in your region') ||
        lower.contains('geoblocked') ||
        lower.contains('geo-restricted') ||
        lower.contains('not available in your region')) {
      return ClassifiedError(
        code: DownloadErrorCode.geoBlocked,
        userMessage: "This video is not available in your region.",
        rawStderr: stderr,
      );
    }

    if (lower.contains('video unavailable') ||
        lower.contains('has been removed') ||
        lower.contains('not found') ||
        lower.contains('404')) {
      return ClassifiedError(
        code: DownloadErrorCode.unavailable,
        userMessage: "This video is unavailable or has been removed.",
        suggestedAction: "Check if the video link opens in your browser.",
        rawStderr: stderr,
      );
    }

    if (lower.contains('429') ||
        lower.contains('rate limit') ||
        lower.contains('bot detection') ||
        lower.contains('too many requests')) {
      return ClassifiedError(
        code: DownloadErrorCode.rateLimited,
        userMessage: "The platform is currently limiting requests.",
        suggestedAction: "Wait a few minutes before trying again.",
        rawStderr: stderr,
      );
    }

    if (lower.contains('extractor error') ||
        lower.contains('unable to extract') ||
        lower.contains('signature solving failed') ||
        lower.contains('n challenge') ||
        lower.contains('nsig extraction failed')) {
      return ClassifiedError(
        code: DownloadErrorCode.engineOutdated,
        userMessage: "Platform extraction format changed.",
        suggestedAction: "Updating the engine may fix this issue.",
        rawStderr: stderr,
      );
    }

    if (lower.contains('timed out') ||
        lower.contains('connection refused') ||
        lower.contains('urlerror') ||
        lower.contains('urlopen error') ||
        lower.contains('name or service not known') ||
        lower.contains('nodename nor servname provided') ||
        lower.contains('temporary failure in name resolution') ||
        lower.contains('network is unreachable')) {
      return ClassifiedError(
        code: DownloadErrorCode.network,
        userMessage: "Network connection failed.",
        suggestedAction: "Please check your internet connection and retry.",
        rawStderr: stderr,
      );
    }

    if (lower.contains('no space left on device') ||
        lower.contains('permission denied') ||
        lower.contains('read-only file system')) {
      return ClassifiedError(
        code: DownloadErrorCode.disk,
        userMessage: "Cannot write to the selected destination folder.",
        suggestedAction: "Check your disk space and folder permissions in Settings.",
        rawStderr: stderr,
      );
    }

    return ClassifiedError(
      code: DownloadErrorCode.unknown,
      userMessage: "An unexpected error occurred during processing.",
      suggestedAction: "Try again or copy the diagnostic log for assistance.",
      rawStderr: stderr,
    );
  }
}
