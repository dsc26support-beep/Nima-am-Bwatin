import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/appointment_repository.dart';
import '../repositories/blood_sugar_repository.dart';
import '../repositories/medication_repository.dart';
import '../services/database_service.dart';
import '../services/dietary_advice_service.dart';
import '../services/export_import_service.dart';
import '../services/notification_service.dart';
import '../services/scheduling_service.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) => DatabaseService.instance);

final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService.instance);

final schedulingServiceProvider = Provider<SchedulingService>((ref) {
  return SchedulingService(ref.watch(notificationServiceProvider));
});

final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  return MedicationRepository(ref.watch(databaseServiceProvider));
});

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  return AppointmentRepository(ref.watch(databaseServiceProvider));
});

final bloodSugarRepositoryProvider = Provider<BloodSugarRepository>((ref) {
  return BloodSugarRepository(ref.watch(databaseServiceProvider));
});

final dietaryAdviceServiceProvider = FutureProvider<DietaryAdviceService>((ref) async {
  final service = DietaryAdviceService();
  await service.load();
  return service;
});

final exportImportServiceProvider = Provider<ExportImportService>((ref) {
  return ExportImportService(
    medicationRepository: ref.watch(medicationRepositoryProvider),
    appointmentRepository: ref.watch(appointmentRepositoryProvider),
    bloodSugarRepository: ref.watch(bloodSugarRepositoryProvider),
    databaseService: ref.watch(databaseServiceProvider),
    schedulingService: ref.watch(schedulingServiceProvider),
  );
});
