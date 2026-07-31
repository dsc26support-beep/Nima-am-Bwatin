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
    // Update state immediately so the new medication shows up instantly,
    // rather than waiting on notification scheduling (a separate, slower,
    // and sometimes-failing step) before the list reflects what was saved.
    state = [...state, saved];

    var ids = <int>[];
    try {
      ids = await _schedulingService.scheduleMedication(saved, _translator);
    } catch (_) {
      // Notification scheduling can fail independently of saving the
      // medication itself (e.g. the exact-alarm permission hasn't been
      // granted on this device yet) -- that must never block the saved
      // medication from showing up.
    }
    final withIds = saved.copyWith(notificationIds: ids);
    await _repository.update(withIds);
    state = [for (final m in state) if (m.id == saved.id) withIds else m];
  }

  Future<void> update(Medication medication) async {
    await _repository.update(medication);
    state = [for (final m in state) if (m.id == medication.id) medication else m];

    var ids = <int>[];
    try {
      ids = await _schedulingService.scheduleMedication(medication, _translator);
    } catch (_) {
      // See add().
    }
    final withIds = medication.copyWith(notificationIds: ids);
    await _repository.update(withIds);
    state = [for (final m in state) if (m.id == medication.id) withIds else m];
  }

  Future<void> delete(Medication medication) async {
    state = state.where((m) => m.id != medication.id).toList();

    try {
      await _schedulingService.cancelMedication(medication);
    } catch (_) {
      // Ignore -- still proceed with deleting the medication itself.
    }
    if (medication.id != null) {
      await _repository.delete(medication.id!);
    }
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
