import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/blood_sugar_reading.dart';
import '../../providers/blood_sugar_provider.dart';
import '../../widgets/band_badge.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import 'blood_sugar_advice_screen.dart';
import 'blood_sugar_entry_screen.dart';

class BloodSugarHistoryScreen extends ConsumerWidget {
  const BloodSugarHistoryScreen({super.key});

  String _formatTimestamp(DateTime dt) {
    final date = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    final time = TimeOfDay.fromDateTime(dt);
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$date, $hour:$minute $period';
  }

  String _unitLabel(WidgetRef ref, BloodSugarReading reading) {
    return reading.unit.name == 'mmolL' ? ref.t('unit_mmol') : ref.t('unit_mgdl');
  }

  String _typeLabel(WidgetRef ref, BloodSugarReading reading) {
    return reading.type.name == 'fbs' ? ref.t('reading_type_fbs') : ref.t('reading_type_rbs');
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, BloodSugarReading reading) async {
    final confirmed = await showConfirmDialog(
      context,
      message: ref.tImperative('blood_sugar_delete_confirm'),
      confirmLabel: ref.tImperative('common_delete'),
      cancelLabel: ref.tImperative('common_cancel'),
    );
    if (confirmed && reading.id != null) {
      await ref.read(bloodSugarProvider.notifier).delete(reading.id!);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readings = ref.watch(bloodSugarProvider);

    return Scaffold(
      appBar: AppBar(title: Text(ref.t('blood_sugar_title'))),
      body: SafeArea(
        child: readings.isEmpty
            ? EmptyState(message: ref.t('blood_sugar_empty'), icon: Icons.bloodtype_outlined)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: readings.length,
                itemBuilder: (context, index) {
                  final reading = readings[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.bloodtype, color: AppColors.coral),
                      title: Text('${_typeLabel(ref, reading)}: ${reading.value} ${_unitLabel(ref, reading)}'),
                      subtitle: Text(_formatTimestamp(reading.timestamp)),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => BloodSugarAdviceScreen(reading: reading)),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BandBadge(band: reading.band),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _delete(context, ref, reading),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BloodSugarEntryScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
