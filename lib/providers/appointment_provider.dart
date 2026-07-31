import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/appointment.dart';
import '../repositories/appointment_repository.dart';
import '../services/localization_service.dart';
import '../services/scheduling_service.dart';
import 'core_providers.dart';
import 'locale_provider.dart';

class AppointmentNotifier extends StateNotifier<List<Appointment>> {
  AppointmentNotifier(this._repository, this._schedulingService, this._translator) : super([]) {
    _load();
  }

  final AppointmentRepository _repository;
  final SchedulingService _schedulingService;
  final AppTranslator _translator;

  Future<void> _load() async {
    state = await _repository.getAll();
  }

  Future<void> add(Appointment appointment) async {
    final saved = await _repository.add(appointment);
    // Show the new appointment right away rather than waiting on
    // notification scheduling (slower, and can fail independently).
    state = [...state, saved];

    int? id;
    try {
      id = await _schedulingService.scheduleAppointment(saved, _translator);
    } catch (_) {
      // A notification-scheduling failure (e.g. missing exact-alarm
      // permission) must not prevent the saved appointment from showing up.
    }
    final withId = saved.copyWith(notificationId: id);
    await _repository.update(withId);
    state = [for (final a in state) if (a.id == saved.id) withId else a];
  }

  Future<void> update(Appointment appointment) async {
    await _repository.update(appointment);
    state = [for (final a in state) if (a.id == appointment.id) appointment else a];

    int? id;
    try {
      id = await _schedulingService.scheduleAppointment(appointment, _translator);
    } catch (_) {
      // See add().
    }
    final withId = appointment.copyWith(notificationId: id);
    await _repository.update(withId);
    state = [for (final a in state) if (a.id == appointment.id) withId else a];
  }

  Future<void> delete(Appointment appointment) async {
    state = state.where((a) => a.id != appointment.id).toList();

    try {
      await _schedulingService.cancelAppointment(appointment);
    } catch (_) {
      // Ignore -- still proceed with deleting the appointment itself.
    }
    if (appointment.id != null) {
      await _repository.delete(appointment.id!);
    }
  }
}

final appointmentProvider = StateNotifierProvider<AppointmentNotifier, List<Appointment>>((ref) {
  return AppointmentNotifier(
    ref.watch(appointmentRepositoryProvider),
    ref.watch(schedulingServiceProvider),
    ref.watch(translatorProvider),
  );
});
