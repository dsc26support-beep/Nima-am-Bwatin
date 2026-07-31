import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/medication.dart';
import '../../providers/medication_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/entity_thumbnail.dart';
import 'medication_form_screen.dart';

class MedicationListScreen extends ConsumerWidget {
  const MedicationListScreen({super.key});

  String _scheduleSummary(WidgetRef ref, Medication medication) {
    final times = medication.schedule.times.map((t) {
      final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
      final minute = t.minute.toString().padLeft(2, '0');
      final period = t.period == DayPeriod.am ? 'AM' : 'PM';
      return '$hour:$minute $period';
    }).join(', ');
    return times;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medications = ref.watch(medicationProvider);

    return Scaffold(
      appBar: AppBar(title: Text(ref.t('medications_title'))),
      body: SafeArea(
        child: medications.isEmpty
            ? EmptyState(message: ref.t('medications_empty'), icon: Icons.medication_outlined)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: medications.length,
                itemBuilder: (context, index) {
                  final medication = medications[index];
                  return Card(
                    child: ListTile(
                      leading: EntityThumbnail(photoPath: medication.photoPath, icon: Icons.medication),
                      title: Text(medication.name),
                      subtitle: Text('${medication.dosage} · ${_scheduleSummary(ref, medication)}'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MedicationFormScreen(existing: medication),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MedicationFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
