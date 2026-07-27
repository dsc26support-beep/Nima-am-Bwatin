import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/blood_sugar_reading.dart';
import '../../providers/core_providers.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/band_badge.dart';

class BloodSugarAdviceScreen extends ConsumerWidget {
  const BloodSugarAdviceScreen({super.key, required this.reading});

  final BloodSugarReading reading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adviceAsync = ref.watch(dietaryAdviceServiceProvider);
    final language = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(ref.t('advice_title'))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: BandBadge(band: reading.band)),
              const SizedBox(height: 24),
              adviceAsync.when(
                data: (service) => Text(
                  service.adviceFor(reading.type, reading.band, language),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),
              Text(
                ref.t('advice_disclaimer'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(ref.t('common_ok')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
