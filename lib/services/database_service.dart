import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  DatabaseService._({this.dbName = 'nima_am_bwatin.db'});
  static final DatabaseService instance = DatabaseService._();

  /// Gives tests their own isolated database file. Without this, separate
  /// test files sharing the same physical sqlite file (via
  /// sqflite_common_ffi) can hit disk I/O errors from concurrent access
  /// when `flutter test` runs files in parallel.
  @visibleForTesting
  DatabaseService.forTesting(String dbName) : this._(dbName: dbName);

  final String dbName;
  Database? _db;

  static const int _dbVersion = 3;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);
    return openDatabase(
      path,
      version: _dbVersion,
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
        await db.execute('''
          CREATE TABLE appointments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            location TEXT NOT NULL,
            date_time TEXT NOT NULL,
            reminder_lead_minutes INTEGER NOT NULL,
            notification_id INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE blood_sugar_readings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            value REAL NOT NULL,
            unit TEXT NOT NULL,
            timestamp TEXT NOT NULL
          )
        ''');
        await _createMedicationLogTable(db);
        await _createCaregiversTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createMedicationLogTable(db);
        }
        if (oldVersion < 3) {
          await _createCaregiversTable(db);
        }
      },
    );
  }

  Future<void> _createMedicationLogTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE medication_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medication_name TEXT NOT NULL,
        taken_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createCaregiversTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE caregivers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT,
        whatsapp_number TEXT,
        messenger_username TEXT
      )
    ''');
  }
}
