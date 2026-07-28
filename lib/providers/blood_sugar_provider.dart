import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/blood_sugar_reading.dart';
import '../repositories/blood_sugar_repository.dart';
import 'core_providers.dart';

class BloodSugarNotifier extends StateNotifier<List<BloodSugarReading>> {
  BloodSugarNotifier(this._repository) : super([]) {
    _load();
  }

  final BloodSugarRepository _repository;

  Future<void> _load() async {
    state = await _repository.getAll();
  }

  Future<void> add(BloodSugarReading reading) async {
    final saved = await _repository.add(reading);
    // getAll() orders by timestamp DESC, so a just-added reading (the most
    // recent) belongs at the front -- no need for a full reload to see it.
    state = [saved, ...state];
  }

  Future<void> delete(int id) async {
    state = state.where((r) => r.id != id).toList();
    await _repository.delete(id);
  }
}

final bloodSugarProvider = StateNotifierProvider<BloodSugarNotifier, List<BloodSugarReading>>((ref) {
  return BloodSugarNotifier(ref.watch(bloodSugarRepositoryProvider));
});
