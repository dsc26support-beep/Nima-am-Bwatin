import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/medication.dart';
import '../repositories/medication_repository.dart';
import '../services/localization_service.dart';
import '../services/scheduling_service.dart';
import 'core_providers.dart';
import 'locale_provider.dart';

class MedicationNotifier extends StateNotifier<List<Medication>> {
  MedicationNotifier(this._repository, this._schedulingService, this._translator) : super([]) {
    _load();
  }

  final MedicationRepository _repository;
  final SchedulingService _schedulingService;
  final AppTranslator _translator;

  Future<void> _load() async {
    state = await _repository.getAll();
  }

  Future<void> add(Medication medication) async {
    final saved = await _repository.add(medication);
    final ids = await _schedulingService.scheduleMedication(saved, _translator);
    await _repository.update(saved.copyWith(notificationIds: ids));
    await _load();
  }

  Future<void> update(Medication medication) async {
    await _repository.update(medication);
    final ids = await _schedulingService.scheduleMedication(medication, _translator);
    await _repository.update(medication.copyWith(notificationIds: ids));
    await _load();
  }

  Future<void> delete(Medication medication) async {
    await _schedulingService.cancelMedication(medication);
    if (medication.id != null) {
      await _repository.delete(medication.id!);
    }
    await _load();
  }

  Future<void> toggleActive(Medication medication) async {
    await update(medication.copyWith(isActive: !medication.isActive));
  }
}

final medicationProvider = StateNotifierProvider<MedicationNotifier, List<Medication>>((ref) {
  return MedicationNotifier(
    ref.watch(medicationRepositoryProvider),
    ref.watch(schedulingServiceProvider),
    ref.watch(translatorProvider),
  );
});
