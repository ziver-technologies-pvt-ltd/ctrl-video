import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:ctrl_video/data/database.dart';

void main() {
  test('Database: v2 schema supports format and trim columns', () async {
    final db = AppDatabase(NativeDatabase.memory());

    final id = await db.insertRecord(
      DownloadRecordsCompanion.insert(
        url: 'https://youtube.com/watch?v=v2test',
        platform: 'YouTube',
        title: 'v2 Video with Trim',
        formatLabel: '1080p MP4',
        status: 'completed',
        videoFormatId: const drift.Value('137'),
        audioFormatId: const drift.Value('140'),
        container: const drift.Value('mp4'),
        audioCodec: const drift.Value('aac'),
        trimStartMs: const drift.Value(15000),
        trimEndMs: const drift.Value(45000),
        trimMode: const drift.Value('exact'),
      ),
    );

    final history = await db.getAllHistory();
    expect(history.length, 1);
    final record = history.first;

    expect(record.title, 'v2 Video with Trim');
    expect(record.videoFormatId, '137');
    expect(record.audioFormatId, '140');
    expect(record.container, 'mp4');
    expect(record.trimStartMs, 15000);
    expect(record.trimEndMs, 45000);
    expect(record.trimMode, 'exact');

    await db.close();
  });
}
