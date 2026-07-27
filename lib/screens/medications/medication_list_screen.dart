import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/medication.dart';
import '../../providers/medication_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
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

  Future<void> _delete(BuildContext context, WidgetRef ref, Medication medication) async {
    final confirmed = await showConfirmDialog(
      context,
      message: ref.tImperative('medication_delete_confirm'),
      confirmLabel: ref.tImperative('common_delete'),
      cancelLabel: ref.tImperative('common_cancel'),
    );
    if (confirmed) {
      await ref.read(medicationProvider.notifier).delete(medication);
    }
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
                      leading: const Icon(Icons.medication, color: AppColors.coral),
                      title: Text(medication.name),
                      subtitle: Text('${medication.dosage} · ${_scheduleSummary(ref, medication)}'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MedicationFormScreen(existing: medication),
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _delete(context, ref, medication),
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
