import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/language_toggle.dart';
import '../../widgets/update_check_tile.dart';
import '../export_import/export_screen.dart';
import '../export_import/import_screen.dart';
import 'feedback_screen.dart';
import 'manage_appointments_screen.dart';
import 'manage_medications_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(ref.t('settings_title'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(ref.t('settings_language'), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const LanguageToggle(),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const Icon(Icons.medication_outlined),
                title: Text(ref.t('settings_manage_medications')),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ManageMedicationsScreen()),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.event_note_outlined),
                title: Text(ref.t('settings_manage_appointments')),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ManageAppointmentsScreen()),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.upload_file_outlined),
                title: Text(ref.t('settings_export_data')),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ExportScreen()),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.download_outlined),
                title: Text(ref.t('settings_import_data')),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ImportScreen()),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.feedback_outlined),
                title: Text(ref.t('settings_feedback')),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FeedbackScreen()),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const UpdateCheckTile(),
            Card(
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(ref.t('settings_about')),
                subtitle: FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    final version = snapshot.data?.version ?? '';
                    return Text('Nima-am-Bwatin v$version');
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
