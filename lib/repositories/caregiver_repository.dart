import '../models/caregiver.dart';
import '../services/database_service.dart';

class CaregiverRepository {
  CaregiverRepository(this._dbService);
  final DatabaseService _dbService;

  Future<List<Caregiver>> getAll() async {
    final db = await _dbService.database;
    final rows = await db.query('caregivers', orderBy: 'id');
    return rows.map(Caregiver.fromMap).toList();
  }

  Future<Caregiver> add(Caregiver caregiver) async {
    final db = await _dbService.database;
    final id = await db.insert('caregivers', caregiver.toMap()..remove('id'));
    return caregiver.copyWith(id: id);
  }

  Future<void> update(Caregiver caregiver) async {
    final db = await _dbService.database;
    await db.update('caregivers', caregiver.toMap(), where: 'id = ?', whereArgs: [caregiver.id]);
  }

  Future<void> delete(int id) async {
    final db = await _dbService.database;
    await db.delete('caregivers', where: 'id = ?', whereArgs: [id]);
  }
}
