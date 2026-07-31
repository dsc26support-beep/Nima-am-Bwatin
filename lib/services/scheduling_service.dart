import 'dart:convert';

import 'package:flutter/material.dart' show TimeOfDay;

import '../models/appointment.dart';
import '../models/medication.dart';
import 'localization_service.dart';
import 'notification_service.dart';

/// Generates concrete reminder times for a schedule, and orchestrates
/// scheduling/cancelling the actual notifications for medications and
/// appointments.
///
/// Notification id ranges (kept far apart so they can never collide):
/// - Medications: 1000 + medicationId * 100 + slotIndex  (up to 100 slots reserved per medication)
/// - Appointments: 500000 + appointmentId
class SchedulingService {
  SchedulingService(this._notificationService);
  final NotificationService _notificationService;

  static const int _medicationSlotCapacity = 100;
  static const int _medicationBase = 1000;
  static const int _appointmentBase = 500000;

  /// Evenly spreads [count] reminder times across a default waking window
  /// (07:00-21:00), used when the user picks "times per day" and hasn't
  /// customized individual times.
  static List<TimeOfDay> generateEvenlySpacedTimes(int count) {
    if (count <= 1) return [const TimeOfDay(hour: 8, minute: 0)];
    const startMinutes = 7 * 60;
    const endMinutes = 21 * 60;
    final step = (endMinutes - startMinutes) / (count - 1);
    return List.generate(count, (i) {
      final minutes = (startMinutes + step * i).round();
      return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
    });
  }

  /// Fixed daily clock times covering 24h, spaced [everyXHours] apart,
  /// starting from [anchor]. Deliberately a set of fixed clock times rather
  /// than a rolling "since last dose" timer, since that would require
  /// continuous background rescheduling and is far less reliable.
  static List<TimeOfDay> generateEveryXHoursTimes(
    int everyXHours, {
    TimeOfDay anchor = const TimeOfDay(hour: 6, minute: 0),
  }) {
    if (everyXHours <= 0) return [anchor];
    final count = (24 / everyXHours).floor().clamp(1, 24);
    final anchorMinutes = anchor.hour * 60 + anchor.minute;
    return List.generate(count, (i) {
      final minutes = (anchorMinutes + i * everyXHours * 60) % (24 * 60);
      return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
    });
  }

  int _medicationBaseId(int medicationId) => _medicationBase + medicationId * _medicationSlotCapacity;
  int _appointmentNotificationId(int appointmentId) => _appointmentBase + appointmentId;

  /// A flat list of (time, weekday) occurrences a schedule resolves to.
  /// weekday is null when the reminder repeats every day.
  List<({TimeOfDay time, int? weekday})> _occurrences(Medication medication) {
    final schedule = medication.schedule;
    if (schedule.weekdays.isEmpty) {
      return schedule.times.map((t) => (time: t, weekday: null)).toList();
    }
    return [
      for (final time in schedule.times)
        for (final weekday in schedule.weekdays) (time: time, weekday: weekday),
    ];
  }

  Future<void> cancelMedication(Medication medication) async {
    if (medication.id == null) return;
    await _notificationService.cancelRange(
      _medicationBaseId(medication.id!),
      _medicationSlotCapacity,
    );
  }

  /// Cancels any existing reminders for this medication, schedules fresh
  /// ones from its current schedule, and returns the notification ids used
  /// (to be persisted back onto the medication row).
  Future<List<int>> scheduleMedication(Medication medication, AppTranslator translator) async {
    if (medication.id == null) return [];
    await cancelMedication(medication);
    if (!medication.isActive) return [];

    final baseId = _medicationBaseId(medication.id!);
    final occurrences = _occurrences(medication);
    final ids = <int>[];

    final title = translator.t('medication_notification_title');
    final body = translator.t('medication_notification_body', {
      'name': medication.name,
      'dosage': medication.dosage,
    });
    final pillsTakenLabel = translator.t('pills_taken_action');
    final alertCaregiverLabel = translator.t('alert_caregiver_action');
    final payload = jsonEncode({'medicationName': medication.name});

    for (var i = 0; i < occurrences.length && i < _medicationSlotCapacity; i++) {
      final occurrence = occurrences[i];
      final id = baseId + i;
      ids.add(id);
      if (occurrence.weekday == null) {
        await _notificationService.scheduleDaily(
          id,
          title,
          body,
          occurrence.time,
          pillsTakenLabel: pillsTakenLabel,
          alertCaregiverLabel: alertCaregiverLabel,
          payload: payload,
        );
      } else {
        await _notificationService.scheduleWeekly(
          id,
          title,
          body,
          occurrence.time,
          occurrence.weekday!,
          pillsTakenLabel: pillsTakenLabel,
          alertCaregiverLabel: alertCaregiverLabel,
          payload: payload,
        );
      }
    }

    return ids;
  }

  Future<void> cancelAppointment(Appointment appointment) async {
    if (appointment.id == null) return;
    await _notificationService.cancel(_appointmentNotificationId(appointment.id!));
  }

  Future<int?> scheduleAppointment(Appointment appointment, AppTranslator translator) async {
    if (appointment.id == null) return null;
    await cancelAppointment(appointment);

    if (appointment.reminderTime.isBefore(DateTime.now())) {
      return null;
    }

    final id = _appointmentNotificationId(appointment.id!);
    final title = translator.t('appointment_notification_title');
    final body = translator.t('appointment_notification_body', {
      'title': appointment.title,
      'location': appointment.location,
    });

    await _notificationService.scheduleOneShot(id, title, body, appointment.reminderTime);
    return id;
  }

  Future<void> rescheduleAll(
    List<Medication> medications,
    List<Appointment> appointments,
    AppTranslator translator,
  ) async {
    for (final medication in medications) {
      await scheduleMedication(medication, translator);
    }
    for (final appointment in appointments) {
      await scheduleAppointment(appointment, translator);
    }
  }
}
