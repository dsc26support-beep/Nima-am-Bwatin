import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/medication.dart';
import '../../providers/medication_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';

/// Where medications get deleted from -- kept out of the main Medications
/// tab so a stray tap there can't accidentally remove a reminder.
class ManageMedicationsScreen extends ConsumerWidget {
  const ManageMedicationsScreen({super.key});

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
      appBar: AppBar(title: Text(ref.t('manage_medications_title'))),
      body: SafeArea(
        child: medications.isEmpty
            ? EmptyState(message: ref.t('manage_medications_empty'), icon: Icons.medication_outlined)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: medications.length,
                itemBuilder: (context, index) {
                  final medication = medications[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.medication, color: AppColors.coral),
                      title: Text(medication.name),
                      subtitle: Text(medication.dosage),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _delete(context, ref, medication),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
