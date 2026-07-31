import '../models/blood_sugar_reading.dart';
import '../services/database_service.dart';

class BloodSugarRepository {
  BloodSugarRepository(this._dbService);
  final DatabaseService _dbService;

  Future<List<BloodSugarReading>> getAll() async {
    final db = await _dbService.database;
    final rows = await db.query('blood_sugar_readings', orderBy: 'timestamp DESC');
    return rows.map(BloodSugarReading.fromMap).toList();
  }

  Future<BloodSugarReading> add(BloodSugarReading reading) async {
    final db = await _dbService.database;
    final map = reading.toMap()..remove('id');
    final id = await db.insert('blood_sugar_readings', map);
    return BloodSugarReading(
      id: id,
      type: reading.type,
      value: reading.value,
      unit: reading.unit,
      timestamp: reading.timestamp,
    );
  }

  Future<void> delete(int id) async {
    final db = await _dbService.database;
    await db.delete('blood_sugar_readings', where: 'id = ?', whereArgs: [id]);
  }
}
