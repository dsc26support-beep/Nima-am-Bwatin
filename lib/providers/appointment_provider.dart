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
    final id = await _schedulingService.scheduleAppointment(saved, _translator);
    await _repository.update(saved.copyWith(notificationId: id));
    await _load();
  }

  Future<void> update(Appointment appointment) async {
    await _repository.update(appointment);
    final id = await _schedulingService.scheduleAppointment(appointment, _translator);
    await _repository.update(appointment.copyWith(notificationId: id));
    await _load();
  }

  Future<void> delete(Appointment appointment) async {
    await _schedulingService.cancelAppointment(appointment);
    if (appointment.id != null) {
      await _repository.delete(appointment.id!);
    }
    await _load();
  }
}

final appointmentProvider = StateNotifierProvider<AppointmentNotifier, List<Appointment>>((ref) {
  return AppointmentNotifier(
    ref.watch(appointmentRepositoryProvider),
    ref.watch(schedulingServiceProvider),
    ref.watch(translatorProvider),
  );
});
