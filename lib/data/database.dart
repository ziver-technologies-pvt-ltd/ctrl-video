import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import '../services/path_resolver.dart';

part 'database.g.dart';

/// Table storing local download history.
class DownloadRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get url => text()();
  TextColumn get platform => text()();
  TextColumn get title => text()();
  TextColumn get thumbnailUrl => text().nullable()();
  TextColumn get filePath => text().nullable()();
  TextColumn get formatLabel => text()();
  IntColumn get sizeBytes => integer().nullable()();
  TextColumn get status => text()(); // 'completed', 'failed', 'cancelled'
  TextColumn get errorCode => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get completedAt => dateTime().nullable()();
}

/// Table storing application settings key-value pairs.
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [DownloadRecords, AppSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final appDataDir = await PathResolver.getAppDataDirectory();
      final dbFile = File(p.join(appDataDir.path, 'ctrl_video.sqlite'));
      return NativeDatabase.createInBackground(dbFile);
    });
  }

  // --- Download History Helpers ---

  Future<List<DownloadRecord>> getAllHistory() {
    return (select(downloadRecords)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Stream<List<DownloadRecord>> watchAllHistory() {
    return (select(downloadRecords)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<int> insertRecord(DownloadRecordsCompanion record) {
    return into(downloadRecords).insert(record);
  }

  Future<bool> updateRecordStatus(int id, String status, {String? filePath, String? errorCode}) {
    return (update(downloadRecords)..where((t) => t.id.equals(id))).write(
      DownloadRecordsCompanion(
        status: Value(status),
        filePath: Value(filePath),
        errorCode: Value(errorCode),
        completedAt: Value(DateTime.now()),
      ),
    ).then((rows) => rows > 0);
  }

  Future<int> deleteRecord(int id) {
    return (delete(downloadRecords)..where((t) => t.id.equals(id))).go();
  }

  Future<int> clearHistory() {
    return delete(downloadRecords).go();
  }

  // --- Settings Helpers ---

  Future<String?> getSetting(String key) async {
    final query = select(appSettings)..where((t) => t.key.equals(key));
    final result = await query.getSingleOrNull();
    return result?.value;
  }

  Future<void> setSetting(String key, String value) {
    return into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion(
        key: Value(key),
        value: Value(value),
      ),
    );
  }
}
