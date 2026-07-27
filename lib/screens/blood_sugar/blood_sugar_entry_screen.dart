import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/blood_sugar_band.dart';
import '../../models/blood_sugar_reading.dart';
import '../../providers/blood_sugar_provider.dart';
import 'blood_sugar_advice_screen.dart';

class BloodSugarEntryScreen extends ConsumerStatefulWidget {
  const BloodSugarEntryScreen({super.key});

  @override
  ConsumerState<BloodSugarEntryScreen> createState() => _BloodSugarEntryScreenState();
}

class _BloodSugarEntryScreenState extends ConsumerState<BloodSugarEntryScreen> {
  final _valueController = TextEditingController();
  GlucoseTestType _type = GlucoseTestType.fbs;
  GlucoseUnit _unit = GlucoseUnit.mmolL;
  bool _saving = false;

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = double.tryParse(_valueController.text.trim());
    if (value == null) return;

    setState(() => _saving = true);

    final reading = BloodSugarReading(
      type: _type,
      value: value,
      unit: _unit,
      timestamp: DateTime.now(),
    );

    await ref.read(bloodSugarProvider.notifier).add(reading);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => BloodSugarAdviceScreen(reading: reading)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(ref.t('blood_sugar_add'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(ref.t('reading_type'), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            SegmentedButton<GlucoseTestType>(
              segments: [
                ButtonSegment(value: GlucoseTestType.fbs, label: Text(ref.t('reading_type_fbs'))),
                ButtonSegment(value: GlucoseTestType.rbs, label: Text(ref.t('reading_type_rbs'))),
              ],
              selected: {_type},
              onSelectionChanged: (selection) => setState(() => _type = selection.first),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _valueController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: ref.t('reading_value')),
            ),
            const SizedBox(height: 16),
            Text(ref.t('reading_unit'), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            SegmentedButton<GlucoseUnit>(
              segments: [
                ButtonSegment(value: GlucoseUnit.mmolL, label: Text(ref.t('unit_mmol'))),
                ButtonSegment(value: GlucoseUnit.mgdL, label: Text(ref.t('unit_mgdl'))),
              ],
              selected: {_unit},
              onSelectionChanged: (selection) => setState(() => _unit = selection.first),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _saving ? null : _save,
            child: Text(ref.t('reading_save')),
          ),
        ),
      ),
    );
  }
}
