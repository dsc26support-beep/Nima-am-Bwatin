import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/caregiver.dart';
import '../../providers/caregiver_provider.dart';

class CaregiverFormScreen extends ConsumerStatefulWidget {
  const CaregiverFormScreen({super.key, this.existing});

  final Caregiver? existing;

  @override
  ConsumerState<CaregiverFormScreen> createState() => _CaregiverFormScreenState();
}

class _CaregiverFormScreenState extends ConsumerState<CaregiverFormScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _messengerController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _nameController.text = existing.name;
      _emailController.text = existing.email ?? '';
      _whatsappController.text = existing.whatsappNumber ?? '';
      _messengerController.text = existing.messengerUsername ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _whatsappController.dispose();
    _messengerController.dispose();
    super.dispose();
  }

  String? _orNull(String text) => text.trim().isEmpty ? null : text.trim();

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _saving = true);

    final caregiver = Caregiver(
      id: widget.existing?.id,
      name: name,
      email: _orNull(_emailController.text),
      whatsappNumber: _orNull(_whatsappController.text),
      messengerUsername: _orNull(_messengerController.text),
    );

    if (widget.existing == null) {
      await ref.read(caregiverProvider.notifier).add(caregiver);
    } else {
      await ref.read(caregiverProvider.notifier).update(caregiver);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

    return Scaffold(
      appBar: AppBar(title: Text(ref.t(isEditing ? 'caregiver_edit' : 'caregiver_add'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: ref.t('caregiver_name')),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: ref.t('caregiver_email'),
                hintText: ref.t('caregiver_email_hint'),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _whatsappController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: ref.t('caregiver_whatsapp'),
                hintText: ref.t('caregiver_whatsapp_hint'),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _messengerController,
              decoration: InputDecoration(
                labelText: ref.t('caregiver_messenger'),
                hintText: ref.t('caregiver_messenger_hint'),
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
            child: Text(ref.t('common_save')),
          ),
        ),
      ),
    );
  }
}
