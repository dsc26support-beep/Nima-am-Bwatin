import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:nima_am_bwatin/models/medication.dart';
import 'package:nima_am_bwatin/models/medication_schedule.dart';
import 'package:nima_am_bwatin/repositories/medication_repository.dart';
import 'package:nima_am_bwatin/services/database_service.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    // The ffi factory persists to a real file on disk (unlike a real device's
    // sandboxed storage), so start from a clean slate regardless of what any
    // earlier test run left behind.
    final path = join(await databaseFactory.getDatabasesPath(), 'nima_am_bwatin.db');
    await databaseFactory.deleteDatabase(path);
  });

  test('editing a specific-times schedule and saving persists the new time', () async {
    final repository = MedicationRepository(DatabaseService.instance);

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
