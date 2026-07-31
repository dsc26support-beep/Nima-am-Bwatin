import '../models/appointment.dart';
import '../services/database_service.dart';

class AppointmentRepository {
  AppointmentRepository(this._dbService);
  final DatabaseService _dbService;

  Future<List<Appointment>> getAll() async {
    final db = await _dbService.database;
    final rows = await db.query('appointments', orderBy: 'date_time ASC');
    return rows.map(Appointment.fromMap).toList();
  }

  Future<Appointment> add(Appointment appointment) async {
    final db = await _dbService.database;
    final map = appointment.toMap()..remove('id');
    final id = await db.insert('appointments', map);
    return appointment.copyWith(id: id);
  }

  Future<void> update(Appointment appointment) async {
    final db = await _dbService.database;
    await db.update(
      'appointments',
      appointment.toMap(),
      where: 'id = ?',
      whereArgs: [appointment.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _dbService.database;
    await db.delete('appointments', where: 'id = ?', whereArgs: [id]);
  }
}
