import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/caregiver.dart';
import '../../providers/caregiver_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import 'caregiver_form_screen.dart';

class ManageCaregiversScreen extends ConsumerWidget {
  const ManageCaregiversScreen({super.key});

  String _summary(WidgetRef ref, Caregiver caregiver) {
    final parts = <String>[
      if (caregiver.email != null) ref.t('caregiver_email'),
      if (caregiver.whatsappNumber != null) ref.t('caregiver_whatsapp'),
      if (caregiver.messengerUsername != null) ref.t('caregiver_messenger'),
    ];
    return parts.isEmpty ? ref.t('caregiver_no_contact_info') : parts.join(', ');
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Caregiver caregiver) async {
    final confirmed = await showConfirmDialog(
      context,
      message: ref.tImperative('caregiver_delete_confirm'),
      confirmLabel: ref.tImperative('common_delete'),
      cancelLabel: ref.tImperative('common_cancel'),
    );
    if (confirmed && caregiver.id != null) {
      await ref.read(caregiverProvider.notifier).delete(caregiver.id!);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caregivers = ref.watch(caregiverProvider);

    return Scaffold(
      appBar: AppBar(title: Text(ref.t('manage_caregivers_title'))),
      body: SafeArea(
        child: caregivers.isEmpty
            ? EmptyState(message: ref.t('manage_caregivers_empty'), icon: Icons.people_outline)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: caregivers.length,
                itemBuilder: (context, index) {
                  final caregiver = caregivers[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.person_outline, color: AppColors.coral),
                      title: Text(caregiver.name),
                      subtitle: Text(_summary(ref, caregiver)),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => CaregiverFormScreen(existing: caregiver)),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _delete(context, ref, caregiver),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CaregiverFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
