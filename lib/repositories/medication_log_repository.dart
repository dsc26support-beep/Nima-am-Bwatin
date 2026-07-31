import '../models/medication_log_entry.dart';
import '../services/database_service.dart';

class MedicationLogRepository {
  MedicationLogRepository(this._dbService);
  final DatabaseService _dbService;

  Future<List<MedicationLogEntry>> getAll() async {
    final db = await _dbService.database;
    final rows = await db.query('medication_log', orderBy: 'taken_at DESC');
    return rows.map(MedicationLogEntry.fromMap).toList();
  }

  Future<void> add(MedicationLogEntry entry) async {
    final db = await _dbService.database;
    await db.insert('medication_log', entry.toMap()..remove('id'));
  }
}
