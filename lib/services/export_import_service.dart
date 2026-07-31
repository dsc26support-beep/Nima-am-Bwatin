import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/appointment.dart';
import '../models/blood_sugar_reading.dart';
import '../models/medication.dart';
import '../repositories/appointment_repository.dart';
import '../repositories/blood_sugar_repository.dart';
import '../repositories/medication_repository.dart';
import 'database_service.dart';
import 'localization_service.dart';
import 'scheduling_service.dart';

class ImportValidationException implements Exception {}

/// Exports all app data (medications, appointments, blood sugar readings) to
/// a single JSON backup file, and imports one back with replace-all
/// semantics -- simplest, least error-prone for a non-technical user
/// restoring data onto a new phone.
class ExportImportService {
  ExportImportService({
    required this.medicationRepository,
    required this.appointmentRepository,
    required this.bloodSugarRepository,
    required this.databaseService,
    required this.schedulingService,
  });

  final MedicationRepository medicationRepository;
  final AppointmentRepository appointmentRepository;
  final BloodSugarRepository bloodSugarRepository;
  final DatabaseService databaseService;
  final SchedulingService schedulingService;

  static const int exportVersion = 1;

  Future<File> exportToFile() async {
    final medications = await medicationRepository.getAll();
    final appointments = await appointmentRepository.getAll();
    final readings = await bloodSugarRepository.getAll();

    final payload = {
      'exportVersion': exportVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'medications': medications.map((m) => m.toJson()).toList(),
      'appointments': appointments.map((a) => a.toJson()).toList(),
      'bloodSugarReadings': readings.map((r) => r.toJson()).toList(),
    };

    final dir = await getTemporaryDirectory();
    final stamp = DateTime.now().toIso8601String().split('T').first.replaceAll('-', '');
    final file = File('${dir.path}/nima-am-bwatin-backup-$stamp.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(payload));
    return file;
  }

  Future<void> shareExport() async {
    final file = await exportToFile();
    await Share.shareXFiles([XFile(file.path)]);
  }

  /// Lets the user pick a backup JSON file. Returns null if they cancelled.
  Future<File?> pickImportFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.single.path == null) return null;
    return File(result.files.single.path!);
  }

  /// Replaces all current data with the contents of [file]. Cancels all
  /// existing notifications first, then reschedules fresh ones for the
  /// imported data so it goes live immediately.
  Future<void> importFromFile(File file, AppTranslator translator) async {
    final raw = await file.readAsString();
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic> || decoded['exportVersion'] != exportVersion) {
      throw ImportValidationException();
    }

    final medications = (decoded['medications'] as List)
        .map((m) => Medication.fromJson(m as Map<String, dynamic>))
        .toList();
    final appointments = (decoded['appointments'] as List)
        .map((a) => Appointment.fromJson(a as Map<String, dynamic>))
        .toList();
    final readings = (decoded['bloodSugarReadings'] as List)
        .map((r) => BloodSugarReading.fromJson(r as Map<String, dynamic>))
        .toList();

    final existingMedications = await medicationRepository.getAll();
    final existingAppointments = await appointmentRepository.getAll();
    for (final medication in existingMedications) {
      await schedulingService.cancelMedication(medication);
    }
    for (final appointment in existingAppointments) {
      await schedulingService.cancelAppointment(appointment);
    }

    final db = await databaseService.database;
    await db.delete('medications');
    await db.delete('appointments');
    await db.delete('blood_sugar_readings');

    final savedMedications = <Medication>[];
    for (final medication in medications.take(10)) {
      savedMedications.add(await medicationRepository.add(medication));
    }
    final savedAppointments = <Appointment>[];
    for (final appointment in appointments) {
      savedAppointments.add(await appointmentRepository.add(appointment));
    }
    for (final reading in readings) {
      await bloodSugarRepository.add(reading);
    }

    await schedulingService.rescheduleAll(savedMedications, savedAppointments, translator);
  }
}
