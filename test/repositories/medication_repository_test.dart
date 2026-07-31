import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:nima_am_bwatin/models/medication.dart';
import 'package:nima_am_bwatin/models/medication_schedule.dart';
import 'package:nima_am_bwatin/repositories/medication_repository.dart';
import 'package:nima_am_bwatin/services/database_service.dart';

const _dbName = 'test_medication_repository.db';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    // Each test file gets its own db file name -- sharing one across files
    // causes disk I/O errors when flutter test runs files concurrently.
    final path = join(await databaseFactory.getDatabasesPath(), _dbName);
    await databaseFactory.deleteDatabase(path);
  });

  test('editing a specific-times schedule and saving persists the new time', () async {
    final repository = MedicationRepository(DatabaseService.forTesting(_dbName));

    final original = await repository.add(const Medication(
      name: 'Paracetamol',
      dosage: '500 mg',
      schedule: MedicationSchedule(
        type: FrequencyType.specificTimes,
        times: [TimeOfDay(hour: 8, minute: 0)],
      ),
    ));

    // Simulate the edit form: load existing, change the time, save --
    // exactly what MedicationFormScreen._save() does.
    final edited = original.copyWith(
      schedule: const MedicationSchedule(
        type: FrequencyType.specificTimes,
        times: [TimeOfDay(hour: 18, minute: 0)],
      ),
    );
    await repository.update(edited);

    final all = await repository.getAll();
    expect(all, hasLength(1));
    expect(all.first.schedule.times, [const TimeOfDay(hour: 18, minute: 0)]);
  });
}
