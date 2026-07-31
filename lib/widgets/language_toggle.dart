import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';

class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider);

    return SegmentedButton<String>(
      segments: [
        ButtonSegment(
          value: AppConstants.languageEnglish,
          label: Text(ref.t('settings_language_english')),
        ),
        ButtonSegment(
          value: AppConstants.languageKiribati,
          label: Text(ref.t('settings_language_kiribati')),
        ),
      ],
      selected: {current},
      onSelectionChanged: (selection) {
        ref.read(localeProvider.notifier).setLanguage(selection.first);
      },
    );
  }
}
