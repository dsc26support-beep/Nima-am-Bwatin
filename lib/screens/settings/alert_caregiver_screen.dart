import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/caregiver.dart';
import '../../providers/caregiver_provider.dart';
import '../../services/caregiver_alert_service.dart';
import '../../widgets/empty_state.dart';
import 'manage_caregivers_screen.dart';

/// Reached either from Settings ("Ask someone to remind me") or from the
/// "Alert caregiver" action on a ringing medication alarm -- in which case
/// [medicationName] is set so the pre-filled message names the medication.
class AlertCaregiverScreen extends ConsumerWidget {
  const AlertCaregiverScreen({super.key, this.medicationName});

  final String? medicationName;

  String _message(WidgetRef ref) {
    return medicationName != null
        ? ref.t('caregiver_message_with_medication', {'name': medicationName!})
        : ref.t('caregiver_message_generic');
  }

  Future<void> _send(BuildContext context, WidgetRef ref, Caregiver caregiver, CaregiverChannel channel) async {
    final opened = await CaregiverAlertService.send(caregiver, channel, _message(ref));
    if (!context.mounted) return;

    final messageKey = switch (channel) {
      CaregiverChannel.email => opened ? 'caregiver_sent_email' : 'caregiver_failed_generic',
      CaregiverChannel.whatsapp => opened ? 'caregiver_sent_whatsapp' : 'caregiver_failed_generic',
      CaregiverChannel.messenger => 'caregiver_sent_messenger',
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ref.tImperative(messageKey, {'name': caregiver.name}))),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caregivers = ref.watch(caregiverProvider);

    return Scaffold(
      appBar: AppBar(title: Text(ref.t('alert_caregiver_title'))),
      body: SafeArea(
        child: caregivers.isEmpty
            ? EmptyState(
                message: ref.t('alert_caregiver_no_caregivers'),
                icon: Icons.people_outline,
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(ref.t('alert_caregiver_intro'), style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  for (final caregiver in caregivers)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person_outline, color: AppColors.coral),
                                const SizedBox(width: 8),
                                Text(caregiver.name, style: Theme.of(context).textTheme.titleMedium),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (caregiver.email != null)
                                  ElevatedButton.icon(
                                    onPressed: () => _send(context, ref, caregiver, CaregiverChannel.email),
                                    icon: const Icon(Icons.email_outlined, size: 18),
                                    label: Text(ref.t('caregiver_email')),
                                  ),
                                if (caregiver.whatsappNumber != null)
                                  ElevatedButton.icon(
                                    onPressed: () => _send(context, ref, caregiver, CaregiverChannel.whatsapp),
                                    icon: const Icon(Icons.chat_outlined, size: 18),
                                    label: Text(ref.t('caregiver_whatsapp')),
                                  ),
                                if (caregiver.messengerUsername != null)
                                  ElevatedButton.icon(
                                    onPressed: () => _send(context, ref, caregiver, CaregiverChannel.messenger),
                                    icon: const Icon(Icons.message_outlined, size: 18),
                                    label: Text(ref.t('caregiver_messenger')),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ManageCaregiversScreen()),
                    ),
                    child: Text(ref.t('manage_caregivers_title')),
                  ),
                ],
              ),
      ),
    );
  }
}
