import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:nima_am_bwatin/models/medication.dart';
import 'package:nima_am_bwatin/models/medication_schedule.dart';
import 'package:nima_am_bwatin/providers/medication_provider.dart';
import 'package:nima_am_bwatin/repositories/medication_repository.dart';
import 'package:nima_am_bwatin/services/database_service.dart';
import 'package:nima_am_bwatin/services/localization_service.dart';
import 'package:nima_am_bwatin/services/notification_service.dart';
import 'package:nima_am_bwatin/services/scheduling_service.dart';

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

  test(
    'state still reflects a saved time change even if notification scheduling fails',
    () async {
      // In the test environment (no real Android platform), calls through
      // flutter_local_notifications' method channel fail -- this stands in
      // for a real device where e.g. the exact-alarm permission hasn't been
      // granted, which previously left the in-memory list stale after a save.
      final notifier = MedicationNotifier(
        MedicationRepository(DatabaseService.instance),
        SchedulingService(NotificationService.instance),
        const AppTranslator({}, 'en'),
      );

      await notifier.add(const Medication(
        name: 'Paracetamol',
        dosage: '500 mg',
        schedule: MedicationSchedule(
          type: FrequencyType.specificTimes,
          times: [TimeOfDay(hour: 8, minute: 0)],
        ),
      ));

      expect(notifier.state, hasLength(1));
      final saved = notifier.state.first;

      await notifier.update(saved.copyWith(
        schedule: const MedicationSchedule(
          type: FrequencyType.specificTimes,
          times: [TimeOfDay(hour: 18, minute: 0)],
        ),
      ));

      expect(notifier.state, hasLength(1));
      expect(notifier.state.first.schedule.times, [const TimeOfDay(hour: 18, minute: 0)]);
    },
  );
}
