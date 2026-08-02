import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/appointment.dart';
import '../../providers/appointment_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/entity_thumbnail.dart';

/// Where appointments get deleted from -- kept out of the main Appointments
/// tab so a stray tap there can't accidentally remove a reminder.
class ManageAppointmentsScreen extends ConsumerWidget {
  const ManageAppointmentsScreen({super.key});

  String _formatDateTime(DateTime dt) {
    final date = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    final time = TimeOfDay.fromDateTime(dt);
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$date, $hour:$minute $period';
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Appointment appointment) async {
    final confirmed = await showConfirmDialog(
      context,
      message: ref.tImperative('appointment_delete_confirm'),
      confirmLabel: ref.tImperative('common_delete'),
      cancelLabel: ref.tImperative('common_cancel'),
    );
    if (confirmed) {
      await ref.read(appointmentProvider.notifier).delete(appointment);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointments = ref.watch(appointmentProvider);

    return Scaffold(
      appBar: AppBar(title: Text(ref.t('manage_appointments_title'))),
      body: SafeArea(
        child: appointments.isEmpty
            ? EmptyState(message: ref.t('manage_appointments_empty'), icon: Icons.event_note_outlined)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointments[index];
                  return Card(
                    child: ListTile(
                      leading: EntityThumbnail(photoPath: appointment.photoPath, icon: Icons.event),
                      title: Text(appointment.title),
                      subtitle: Text('${appointment.location}\n${_formatDateTime(appointment.dateTime)}'),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _delete(context, ref, appointment),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
