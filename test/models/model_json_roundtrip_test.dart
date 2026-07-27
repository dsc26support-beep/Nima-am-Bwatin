import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nima_am_bwatin/models/appointment.dart';
import 'package:nima_am_bwatin/models/blood_sugar_band.dart';
import 'package:nima_am_bwatin/models/blood_sugar_reading.dart';
import 'package:nima_am_bwatin/models/medication.dart';
import 'package:nima_am_bwatin/models/medication_schedule.dart';

void main() {
  test('Medication survives a toJson/fromJson roundtrip', () {
    const original = Medication(
      id: 1,
      name: 'Metformin',
      dosage: '500 mg',
      schedule: MedicationSchedule(
        type: FrequencyType.specificWeekdays,
        times: [TimeOfDay(hour: 8, minute: 0), TimeOfDay(hour: 20, minute: 30)],
        weekdays: [1, 3, 5],
      ),
      notificationIds: [1300, 1301],
      isActive: true,
    );

    final restored = Medication.fromJson(original.toJson());

    expect(restored.name, original.name);
    expect(restored.dosage, original.dosage);
    expect(restored.schedule.type, original.schedule.type);
    expect(restored.schedule.weekdays, original.schedule.weekdays);
    expect(restored.schedule.times.map((t) => '${t.hour}:${t.minute}'), ['8:0', '20:30']);
    expect(restored.notificationIds, original.notificationIds);
    expect(restored.isActive, original.isActive);
  });

  test('Appointment survives a toJson/fromJson roundtrip', () {
    final original = Appointment(
      id: 2,
      title: 'Diabetes clinic',
      location: 'Tungaru Central Hospital',
      dateTime: DateTime.utc(2026, 8, 1, 9, 30),
      reminderLeadMinutes: 60,
      notificationId: 500002,
    );

    final restored = Appointment.fromJson(original.toJson());

    expect(restored.title, original.title);
    expect(restored.location, original.location);
    expect(restored.dateTime, original.dateTime);
    expect(restored.reminderLeadMinutes, original.reminderLeadMinutes);
    expect(restored.notificationId, original.notificationId);
  });

  test('BloodSugarReading survives a toJson/fromJson roundtrip', () {
    final original = BloodSugarReading(
      id: 3,
      type: GlucoseTestType.rbs,
      value: 8.4,
      unit: GlucoseUnit.mmolL,
      timestamp: DateTime.utc(2026, 7, 27, 14),
    );

    final restored = BloodSugarReading.fromJson(original.toJson());

    expect(restored.type, original.type);
    expect(restored.value, original.value);
    expect(restored.unit, original.unit);
    expect(restored.timestamp, original.timestamp);
    expect(restored.band, original.band);
  });
}
