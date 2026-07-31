import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/appointment_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/entity_thumbnail.dart';
import 'appointment_form_screen.dart';

class AppointmentListScreen extends ConsumerWidget {
  const AppointmentListScreen({super.key});

  String _formatDateTime(DateTime dt) {
    final date = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    final time = TimeOfDay.fromDateTime(dt);
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$date, $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointments = ref.watch(appointmentProvider);

    return Scaffold(
      appBar: AppBar(title: Text(ref.t('appointments_title'))),
      body: SafeArea(
        child: appointments.isEmpty
            ? EmptyState(message: ref.t('appointments_empty'), icon: Icons.event_note_outlined)
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
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AppointmentFormScreen(existing: appointment),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AppointmentFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
