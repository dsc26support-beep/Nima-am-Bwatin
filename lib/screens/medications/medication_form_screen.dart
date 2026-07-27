import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/medication.dart';
import '../../models/medication_schedule.dart';
import '../../providers/medication_provider.dart';
import '../../repositories/medication_repository.dart';
import '../../services/scheduling_service.dart';

class MedicationFormScreen extends ConsumerStatefulWidget {
  const MedicationFormScreen({super.key, this.existing});

  final Medication? existing;

  @override
  ConsumerState<MedicationFormScreen> createState() => _MedicationFormScreenState();
}

class _MedicationFormScreenState extends ConsumerState<MedicationFormScreen> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();

  FrequencyType _type = FrequencyType.timesPerDay;
  int _timesPerDay = 2;
  int _everyXHours = 8;
  List<TimeOfDay> _times = [const TimeOfDay(hour: 8, minute: 0)];
  final Set<int> _weekdays = {1, 2, 3, 4, 5, 6, 7};

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _nameController.text = existing.name;
      _dosageController.text = existing.dosage;
      _type = existing.schedule.type;
      _timesPerDay = existing.schedule.timesPerDay ?? 2;
      _everyXHours = existing.schedule.everyXHours ?? 8;
      _times = List.of(existing.schedule.times);
      _weekdays
        ..clear()
        ..addAll(existing.schedule.weekdays.isEmpty ? {1, 2, 3, 4, 5, 6, 7} : existing.schedule.weekdays);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(int index) async {
    final picked = await showTimePicker(context: context, initialTime: _times[index]);
    if (picked != null) {
      setState(() => _times[index] = picked);
    }
  }

  Future<void> _addTime() async {
    final picked = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 12, minute: 0));
    if (picked != null) {
      setState(() => _times.add(picked));
    }
  }

  void _removeTime(int index) {
    if (_times.length <= 1) return;
    setState(() => _times.removeAt(index));
  }

  MedicationSchedule _buildSchedule() {
    switch (_type) {
      case FrequencyType.timesPerDay:
        return MedicationSchedule(
          type: _type,
          times: SchedulingService.generateEvenlySpacedTimes(_timesPerDay),
          timesPerDay: _timesPerDay,
        );
      case FrequencyType.everyXHours:
        return MedicationSchedule(
          type: _type,
          times: SchedulingService.generateEveryXHoursTimes(_everyXHours),
          everyXHours: _everyXHours,
        );
      case FrequencyType.specificTimes:
        return MedicationSchedule(type: _type, times: _times);
      case FrequencyType.specificWeekdays:
        return MedicationSchedule(
          type: _type,
          times: _times,
          weekdays: _weekdays.toList()..sort(),
        );
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final dosage = _dosageController.text.trim();
    if (name.isEmpty || dosage.isEmpty) return;

    setState(() => _saving = true);

    final schedule = _buildSchedule();
    final medication = (widget.existing ?? const Medication(name: '', dosage: '', schedule: MedicationSchedule(type: FrequencyType.timesPerDay, times: [])))
        .copyWith(name: name, dosage: dosage, schedule: schedule);

    try {
      if (widget.existing == null) {
        await ref.read(medicationProvider.notifier).add(medication);
      } else {
        await ref.read(medicationProvider.notifier).update(medication);
      }
      if (mounted) Navigator.of(context).pop();
    } on MedicationCapExceededException {
      if (mounted) {
        setState(() => _saving = false);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(ref.tImperative('medication_cap_reached_title')),
            content: Text(ref.tImperative('medication_cap_reached_body')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(ref.tImperative('common_ok')),
              ),
            ],
          ),
        );
      }
    }
  }

  String _weekdayKey(int weekday) {
    const keys = [
      'weekday_monday',
      'weekday_tuesday',
      'weekday_wednesday',
      'weekday_thursday',
      'weekday_friday',
      'weekday_saturday',
      'weekday_sunday',
    ];
    return keys[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(ref.t(isEditing ? 'medications_edit' : 'medications_add')),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: ref.t('medication_name'),
                hintText: ref.t('medication_name_hint'),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dosageController,
              decoration: InputDecoration(
                labelText: ref.t('medication_dosage'),
                hintText: ref.t('medication_dosage_hint'),
              ),
            ),
            const SizedBox(height: 24),
            Text(ref.t('medication_frequency'), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            SegmentedButton<FrequencyType>(
              segments: [
                ButtonSegment(value: FrequencyType.timesPerDay, label: Text(ref.t('frequency_times_per_day'))),
                ButtonSegment(value: FrequencyType.specificTimes, label: Text(ref.t('frequency_specific_times'))),
                ButtonSegment(value: FrequencyType.everyXHours, label: Text(ref.t('frequency_every_x_hours'))),
                ButtonSegment(value: FrequencyType.specificWeekdays, label: Text(ref.t('frequency_specific_weekdays'))),
              ],
              selected: {_type},
              onSelectionChanged: (selection) => setState(() => _type = selection.first),
              showSelectedIcon: false,
            ),
            const SizedBox(height: 16),
            ..._buildFrequencyFields(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _saving ? null : _save,
            child: Text(ref.t('medication_save')),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFrequencyFields() {
    switch (_type) {
      case FrequencyType.timesPerDay:
        return [
          Row(
            children: [
              Expanded(child: Text('${ref.t('frequency_times_per_day')}: $_timesPerDay')),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: _timesPerDay > 1 ? () => setState(() => _timesPerDay--) : null,
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: _timesPerDay < 6 ? () => setState(() => _timesPerDay++) : null,
              ),
            ],
          ),
        ];
      case FrequencyType.everyXHours:
        return [
          Row(
            children: [
              Expanded(child: Text('${ref.t('frequency_every_x_hours')}: $_everyXHours')),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: _everyXHours > 1 ? () => setState(() => _everyXHours--) : null,
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: _everyXHours < 24 ? () => setState(() => _everyXHours++) : null,
              ),
            ],
          ),
        ];
      case FrequencyType.specificTimes:
        return _buildTimesList();
      case FrequencyType.specificWeekdays:
        return [
          Wrap(
            spacing: 8,
            children: List.generate(7, (i) {
              final weekday = i + 1;
              final selected = _weekdays.contains(weekday);
              return FilterChip(
                label: Text(ref.t(_weekdayKey(weekday))),
                selected: selected,
                onSelected: (value) => setState(() {
                  if (value) {
                    _weekdays.add(weekday);
                  } else {
                    _weekdays.remove(weekday);
                  }
                }),
              );
            }),
          ),
          const SizedBox(height: 16),
          ..._buildTimesList(),
        ];
    }
  }

  List<Widget> _buildTimesList() {
    return [
      Text(ref.t('medication_times_label'), style: Theme.of(context).textTheme.titleLarge),
      for (var i = 0; i < _times.length; i++)
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(_times[i].format(context)),
          onTap: () => _pickTime(i),
          trailing: _times.length > 1
              ? IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _removeTime(i),
                )
              : null,
        ),
      TextButton.icon(
        onPressed: _addTime,
        icon: const Icon(Icons.add),
        label: Text(ref.t('medication_add_time')),
      ),
    ];
  }
}
