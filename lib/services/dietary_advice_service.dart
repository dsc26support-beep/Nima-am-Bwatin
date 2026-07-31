import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/blood_sugar_band.dart';

/// Loads dietary advice text keyed by test type + band, per language, from
/// assets/data/dietary_advice.json. Content lives entirely in that JSON file
/// so wording can be updated without touching Dart code.
class DietaryAdviceService {
  Map<String, dynamic> _data = {};

  Future<void> load() async {
    final raw = await rootBundle.loadString('assets/data/dietary_advice.json');
    _data = jsonDecode(raw) as Map<String, dynamic>;
  }

  String adviceFor(GlucoseTestType type, GlucoseBand band, String languageCode) {
    final key = '${type.name}_${band.name}';
    final entry = _data[key] as Map<String, dynamic>?;
    if (entry == null) return '';
    return (entry[languageCode] ?? entry['en'] ?? '').toString();
  }
}
