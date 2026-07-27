import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/appointment.dart';
import '../../providers/appointment_provider.dart';

class AppointmentFormScreen extends ConsumerStatefulWidget {
  const AppointmentFormScreen({super.key, this.existing});

  final Appointment? existing;

  @override
  ConsumerState<AppointmentFormScreen> createState() => _AppointmentFormScreenState();
}

class _AppointmentFormScreenState extends ConsumerState<AppointmentFormScreen> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  int _leadMinutes = 60;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _titleController.text = existing.title;
      _locationController.text = existing.location;
      _date = existing.dateTime;
      _time = TimeOfDay(hour: existing.dateTime.hour, minute: existing.dateTime.minute);
      _leadMinutes = existing.reminderLeadMinutes;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final location = _locationController.text.trim();
    if (title.isEmpty) return;

    setState(() => _saving = true);

    final dateTime = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
    final appointment = (widget.existing ??
            Appointment(title: '', location: '', dateTime: dateTime, reminderLeadMinutes: _leadMinutes))
        .copyWith(title: title, location: location, dateTime: dateTime, reminderLeadMinutes: _leadMinutes);

    if (widget.existing == null) {
      await ref.read(appointmentProvider.notifier).add(appointment);
    } else {
      await ref.read(appointmentProvider.notifier).update(appointment);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

    return Scaffold(
      appBar: AppBar(title: Text(ref.t(isEditing ? 'appointments_edit' : 'appointments_add'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: ref.t('appointment_title_label'),
                hintText: ref.t('appointment_title_hint'),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: ref.t('appointment_location'),
                hintText: ref.t('appointment_location_hint'),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(ref.t('appointment_date')),
              subtitle: Text('${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}'),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: _pickDate,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(ref.t('appointment_time')),
              subtitle: Text(_time.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: _pickTime,
            ),
            const SizedBox(height: 16),
            Text(ref.t('appointment_reminder_lead'), style: Theme.of(context).textTheme.titleLarge),
            RadioGroup<int>(
              groupValue: _leadMinutes,
              onChanged: (value) => setState(() => _leadMinutes = value ?? _leadMinutes),
              child: Column(
                children: [
                  for (final option in const [(15, 'lead_15_min'), (60, 'lead_1_hour'), (1440, 'lead_1_day')])
                    RadioListTile<int>(
                      value: option.$1,
                      title: Text(ref.t(option.$2)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _saving ? null : _save,
            child: Text(ref.t('appointment_save')),
          ),
        ),
      ),
    );
  }
}
