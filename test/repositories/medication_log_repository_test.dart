import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:nima_am_bwatin/models/medication_log_entry.dart';
import 'package:nima_am_bwatin/repositories/medication_log_repository.dart';
import 'package:nima_am_bwatin/services/database_service.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final path = join(await databaseFactory.getDatabasesPath(), 'nima_am_bwatin.db');
    await databaseFactory.deleteDatabase(path);
  });

  test('logging a taken pill persists and reads back newest first', () async {
    final repository = MedicationLogRepository(DatabaseService.instance);

    await repository.add(MedicationLogEntry(
      medicationName: 'Paracetamol',
      takenAt: DateTime.utc(2026, 7, 28, 8),
    ));
    await repository.add(MedicationLogEntry(
      medicationName: 'Metformin',
      takenAt: DateTime.utc(2026, 7, 28, 20),
    ));

    final all = await repository.getAll();
    expect(all, hasLength(2));
    expect(all.first.medicationName, 'Metformin'); // most recent first
    expect(all.last.medicationName, 'Paracetamol');
  });
}
