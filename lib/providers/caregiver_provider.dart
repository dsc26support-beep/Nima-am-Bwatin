import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/caregiver.dart';
import '../repositories/caregiver_repository.dart';
import 'core_providers.dart';

class CaregiverNotifier extends StateNotifier<List<Caregiver>> {
  CaregiverNotifier(this._repository) : super([]) {
    _load();
  }

  final CaregiverRepository _repository;

  Future<void> _load() async {
    state = await _repository.getAll();
  }

  Future<void> add(Caregiver caregiver) async {
    final saved = await _repository.add(caregiver);
    state = [...state, saved];
  }

  Future<void> update(Caregiver caregiver) async {
    await _repository.update(caregiver);
    state = [for (final c in state) if (c.id == caregiver.id) caregiver else c];
  }

  Future<void> delete(int id) async {
    state = state.where((c) => c.id != id).toList();
    await _repository.delete(id);
  }
}

final caregiverProvider = StateNotifierProvider<CaregiverNotifier, List<Caregiver>>((ref) {
  return CaregiverNotifier(ref.watch(caregiverRepositoryProvider));
});
