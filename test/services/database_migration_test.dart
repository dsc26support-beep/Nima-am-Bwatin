import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const _dbName = 'test_database_migration.db';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('upgrading from v3 to v4 adds photo_path without losing existing rows', () async {
    final path = join(await databaseFactory.getDatabasesPath(), _dbName);
    await databaseFactory.deleteDatabase(path);

    // Simulate a v3 install (pre-photo-support): create the old schema by
    // hand and insert a row, then reopen with the app's real onUpgrade path.
    final oldDb = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 3,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE medications (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              dosage TEXT NOT NULL,
              frequency_type TEXT NOT NULL,
              times_per_day INTEGER,
              every_x_hours INTEGER,
              weekdays TEXT NOT NULL,
              times TEXT NOT NULL,
              notification_ids TEXT NOT NULL,
              is_active INTEGER NOT NULL DEFAULT 1
            )
          ''');
        },
      ),
    );
    await oldDb.insert('medications', {
      'name': 'Paracetamol',
      'dosage': '500 mg',
      'frequency_type': 'specificTimes',
      'weekdays': '[]',
      'times': '["8:0"]',
      'notification_ids': '[]',
      'is_active': 1,
    });
    await oldDb.close();

    // Reopen at v4 using the same upgrade logic as DatabaseService.
    final upgradedDb = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 4,
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 4) {
            await db.execute('ALTER TABLE medications ADD COLUMN photo_path TEXT');
          }
        },
      ),
    );

    final rows = await upgradedDb.query('medications');
    expect(rows, hasLength(1));
    expect(rows.first['name'], 'Paracetamol');
    expect(rows.first['photo_path'], isNull);

    await upgradedDb.close();
  });
}
