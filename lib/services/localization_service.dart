import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../core/constants.dart';

/// Loads the flat English/Kiribati string tables from
/// assets/lang/en.json and assets/lang/gil.json.
///
/// Kiribati (gil) is not an ICU-supported locale, so language switching is
/// handled entirely through these JSON key/value maps rather than Flutter's
/// built-in intl locale machinery.
class LocalizationService {
  static Future<Map<String, Map<String, String>>> loadAll() async {
    final en = await _loadLanguageFile('assets/lang/en.json');
    final gil = await _loadLanguageFile('assets/lang/gil.json');
    return {
      AppConstants.languageEnglish: en,
      AppConstants.languageKiribati: gil,
    };
  }

  static Future<Map<String, String>> _loadLanguageFile(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value.toString()));
  }
}

/// Looks up a translated string for the currently selected language,
/// falling back to English when a key is missing.
class AppTranslator {
  const AppTranslator(this._strings, this.languageCode);

  final Map<String, Map<String, String>> _strings;
  final String languageCode;

  String t(String key, [Map<String, String>? params]) {
    final value = _strings[languageCode]?[key] ??
        _strings[AppConstants.languageEnglish]?[key] ??
        key;
    if (params == null || params.isEmpty) return value;
    var result = value;
    for (final entry in params.entries) {
      result = result.replaceAll('{${entry.key}}', entry.value);
    }
    return result;
  }
}
