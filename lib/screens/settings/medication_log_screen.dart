import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/medication_log_entry.dart';
import '../../providers/core_providers.dart';
import '../../widgets/empty_state.dart';

/// Shows every time a medication reminder alarm was stopped via its
/// "Pills taken" action. Written from a background isolate (the plugin's
/// notification-response handler), so this screen always re-fetches fresh
/// from the database rather than watching in-memory Riverpod state.
class MedicationLogScreen extends ConsumerWidget {
  const MedicationLogScreen({super.key});

  String _formatTimestamp(DateTime dt) {
    final date = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    final time = TimeOfDay.fromDateTime(dt);
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$date, $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(ref.t('medication_log_title'))),
      body: SafeArea(
        child: FutureBuilder<List<MedicationLogEntry>>(
          future: ref.read(medicationLogRepositoryProvider).getAll(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final entries = snapshot.data!;
            if (entries.isEmpty) {
              return EmptyState(message: ref.t('medication_log_empty'), icon: Icons.checklist_outlined);
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.check_circle_outline, color: AppColors.coral),
                    title: Text(entry.medicationName),
                    subtitle: Text(_formatTimestamp(entry.takenAt)),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
