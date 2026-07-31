import '../core/constants.dart';
import '../models/medication.dart';
import '../services/database_service.dart';

class MedicationCapExceededException implements Exception {}

class MedicationRepository {
  MedicationRepository(this._dbService);
  final DatabaseService _dbService;

  Future<List<Medication>> getAll() async {
    final db = await _dbService.database;
    final rows = await db.query('medications', orderBy: 'id');
    return rows.map(Medication.fromMap).toList();
  }

  Future<int> activeCount({int? excludingId}) async {
    final db = await _dbService.database;
    final rows = await db.query(
      'medications',
      where: excludingId == null ? 'is_active = 1' : 'is_active = 1 AND id != ?',
      whereArgs: excludingId == null ? null : [excludingId],
    );
    return rows.length;
  }

  Future<Medication> add(Medication medication) async {
    final count = await activeCount();
    if (count >= AppConstants.maxMedications) {
      throw MedicationCapExceededException();
    }
    final db = await _dbService.database;
    final map = medication.toMap()..remove('id');
    final id = await db.insert('medications', map);
    return medication.copyWith(id: id);
  }

  Future<void> update(Medication medication) async {
    final db = await _dbService.database;
    await db.update(
      'medications',
      medication.toMap(),
      where: 'id = ?',
      whereArgs: [medication.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _dbService.database;
    await db.delete('medications', where: 'id = ?', whereArgs: [id]);
  }
}
