import 'dart:async';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../data/database.dart';
import '../models/format_selection.dart';
import '../models/media_info.dart';
import 'download_execution_service.dart';
import 'error_classifier.dart';
import 'trim_service.dart';

class QueueItem {
  final int recordId;
  final MediaInfo mediaInfo;
  final FormatOption format;
  final FormatSelection? formatSelection;
  final TrimRange? trimRange;
  DownloadStatus status;
  DownloadProgress progress;
  String? error;
  String? filePath;

  QueueItem({
    required this.recordId,
    required this.mediaInfo,
    required this.format,
    this.formatSelection,
    this.trimRange,
    this.status = DownloadStatus.idle,
    this.progress = const DownloadProgress(),
    this.error,
    this.filePath,
  });
}

class DownloadManager extends ChangeNotifier {
  final AppDatabase _db;
  final DownloadExecutionService _executionService;
  final Logger _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, colors: false, printEmojis: false),
  );

  final List<QueueItem> _queue = [];
  int _maxConcurrent = 2;
  int _activeCount = 0;

  DownloadManager({
    required AppDatabase db,
    required DownloadExecutionService executionService,
  })  : _db = db,
        _executionService = executionService;

  List<QueueItem> get queue => List.unmodifiable(_queue);
  int get activeCount => _activeCount;
  int get maxConcurrent => _maxConcurrent;

  void setMaxConcurrent(int value) {
    if (value > 0) {
      _maxConcurrent = value;
      _processQueue();
      notifyListeners();
    }
  }

  /// Adds a media item to download queue and persists the initial record in SQLite.
  Future<QueueItem> enqueue({
    required MediaInfo mediaInfo,
    required FormatOption format,
    FormatSelection? formatSelection,
    TrimRange? trimRange,
  }) async {
    final recordId = await _db.insertRecord(
      DownloadRecordsCompanion(
        url: Value(mediaInfo.url),
        platform: Value(mediaInfo.platform),
        title: Value(mediaInfo.title),
        thumbnailUrl: Value(mediaInfo.thumbnailUrl),
        formatLabel: Value(formatSelection?.label ?? format.label),
        status: const Value('pending'),
        videoFormatId: Value(formatSelection?.videoFormatId),
        audioFormatId: Value(formatSelection?.audioFormatId),
        container: Value(formatSelection?.container),
        audioCodec: Value(formatSelection?.audioCodec),
        trimStartMs: Value(trimRange?.start.inMilliseconds),
        trimEndMs: Value(trimRange?.end.inMilliseconds),
        trimMode: Value(trimRange?.mode.name),
      ),
    );

    final item = QueueItem(
      recordId: recordId,
      mediaInfo: mediaInfo,
      format: format,
      formatSelection: formatSelection,
      trimRange: trimRange,
    );

    _queue.add(item);
    notifyListeners();
    _processQueue();
    return item;
  }

  void _processQueue() {
    if (_activeCount >= _maxConcurrent) return;

    for (final item in _queue) {
      if (_activeCount >= _maxConcurrent) break;

      if (item.status == DownloadStatus.idle) {
        _runTask(item);
      }
    }
  }

  Future<void> _runTask(QueueItem item) async {
    _activeCount++;
    item.status = DownloadStatus.downloading;
    item.error = null;
    notifyListeners();

    try {
      final customDir = await _db.getSetting('downloadDir');
      Directory? targetDir;
      if (customDir != null && customDir.isNotEmpty) {
        targetDir = Directory(customDir);
      }

      final downloadedPath = await _executionService.startDownload(
        mediaInfo: item.mediaInfo,
        format: item.format,
        formatSelection: item.formatSelection,
        trimRange: item.trimRange,
        destinationDir: targetDir,
        onProgress: (p) {
          item.progress = p;
          notifyListeners();
        },
      );

      item.status = DownloadStatus.completed;
      item.filePath = downloadedPath;
      await _db.updateRecordStatus(
        item.recordId,
        'completed',
        filePath: downloadedPath,
      );
    } on ClassifiedError catch (e) {
      item.status = DownloadStatus.failed;
      item.error = e.userMessage;
      await _db.updateRecordStatus(
        item.recordId,
        'failed',
        errorCode: e.code.name,
      );
    } catch (e) {
      item.status = DownloadStatus.failed;
      item.error = 'Download failed: $e';
      await _db.updateRecordStatus(
        item.recordId,
        'failed',
        errorCode: 'unknown',
      );
    } finally {
      _activeCount--;
      notifyListeners();
      _processQueue();
    }
  }

  void cancelTask(QueueItem item) {
    if (item.status == DownloadStatus.downloading) {
      _executionService.cancel();
      item.status = DownloadStatus.cancelled;
      _activeCount = (_activeCount - 1).clamp(0, _maxConcurrent);
      _db.updateRecordStatus(item.recordId, 'cancelled');
      notifyListeners();
      _processQueue();
    } else if (item.status == DownloadStatus.idle) {
      item.status = DownloadStatus.cancelled;
      _db.updateRecordStatus(item.recordId, 'cancelled');
      notifyListeners();
    }
  }

  void retryTask(QueueItem item) {
    if (item.status == DownloadStatus.failed || item.status == DownloadStatus.cancelled) {
      item.status = DownloadStatus.idle;
      item.error = null;
      item.progress = const DownloadProgress();
      notifyListeners();
      _processQueue();
    }
  }

  void removeCompleted(QueueItem item) {
    _queue.remove(item);
    notifyListeners();
  }
}
