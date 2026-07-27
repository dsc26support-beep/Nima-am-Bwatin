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
    await _repository.add(reading);
    await _load();
  }

  Future<void> delete(int id) async {
    await _repository.delete(id);
    await _load();
  }
}

final bloodSugarProvider = StateNotifierProvider<BloodSugarNotifier, List<BloodSugarReading>>((ref) {
  return BloodSugarNotifier(ref.watch(bloodSugarRepositoryProvider));
});
