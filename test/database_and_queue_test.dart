import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:ctrl_video/data/database.dart';
import 'package:ctrl_video/models/media_info.dart';
import 'package:ctrl_video/services/download_execution_service.dart';
import 'package:ctrl_video/services/download_manager.dart';
import 'package:ctrl_video/services/engine_manager.dart';

class MockEngineManager extends EngineManager {
  @override
  Future<bool> ensureEngineReady() async => true;
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('Database: settings storage and retrieval', () async {
    await db.setSetting('downloadDir', '/home/user/Downloads');
    final dir = await db.getSetting('downloadDir');
    expect(dir, '/home/user/Downloads');
  });

  test('Database: history record lifecycle', () async {
    final recordId = await db.insertRecord(
      DownloadRecordsCompanion.insert(
        url: 'https://youtube.com/watch?v=test',
        platform: 'YouTube',
        title: 'Test Video',
        formatLabel: '1080p',
        status: 'pending',
      ),
    );

    var history = await db.getAllHistory();
    expect(history.length, 1);
    expect(history.first.title, 'Test Video');

    await db.updateRecordStatus(recordId, 'completed', filePath: '/path/to/video.mp4');
    history = await db.getAllHistory();
    expect(history.first.status, 'completed');
    expect(history.first.filePath, '/path/to/video.mp4');

    await db.deleteRecord(recordId);
    history = await db.getAllHistory();
    expect(history.isEmpty, isTrue);
  });

  test('DownloadManager: enqueue creates queue item and pending record', () async {
    final execution = DownloadExecutionService(engineManager: MockEngineManager());
    final manager = DownloadManager(db: db, executionService: execution);

    const mediaInfo = MediaInfo(
      url: 'https://youtube.com/watch?v=queue1',
      platform: 'YouTube',
      id: 'queue1',
      title: 'Queue Test Video',
    );

    const format = FormatOption(
      formatId: 'best',
      ext: 'mp4',
      label: 'Best',
    );

    final item = await manager.enqueue(mediaInfo: mediaInfo, format: format);
    expect(manager.queue.length, 1);
    expect(item.mediaInfo.title, 'Queue Test Video');

    final history = await db.getAllHistory();
    expect(history.length, 1);
  });
}
