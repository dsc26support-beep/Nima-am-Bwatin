import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../services/localization_service.dart';

/// Loads both language string tables once at startup.
final assetStringsProvider = FutureProvider<Map<String, Map<String, String>>>((ref) {
  return LocalizationService.loadAll();
});

class LocaleNotifier extends StateNotifier<String> {
  LocaleNotifier() : super(AppConstants.languageEnglish) {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(AppConstants.prefsKeyLanguage);
    if (saved != null) {
      state = saved;
    }
  }

  Future<void> setLanguage(String languageCode) async {
    state = languageCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefsKeyLanguage, languageCode);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, String>((ref) {
  return LocaleNotifier();
});

/// Combines the loaded string tables with the current language selection
/// into a single ready-to-use translator. Widgets read strings through this.
final translatorProvider = Provider<AppTranslator>((ref) {
  final strings = ref.watch(assetStringsProvider).valueOrNull ?? {};
  final language = ref.watch(localeProvider);
  return AppTranslator(strings, language);
});
