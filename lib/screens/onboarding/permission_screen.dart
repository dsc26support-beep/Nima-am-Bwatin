import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';
import '../../l10n/app_localizations.dart';
import '../../services/notification_service.dart';
import '../../services/permission_service.dart';
import '../home/home_screen.dart';

/// A plain-language, bilingual explainer shown once before the system
/// notification/exact-alarm permission prompts, so the user understands why
/// the app is asking before Android's own dialog appears.
class PermissionScreen extends ConsumerWidget {
  const PermissionScreen({super.key});

  Future<void> _continue(BuildContext context) async {
    await NotificationService.instance.init();
    await PermissionService().requestAll();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefsKeyOnboardingComplete, true);

    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.notifications_active_outlined, size: 72),
              const SizedBox(height: 24),
              Text(
                ref.t('permission_notifications_title'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                ref.t('permission_notifications_body'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                ref.t('permission_exact_alarm_title'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                ref.t('permission_exact_alarm_body'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => _continue(context),
                child: Text(ref.t('common_confirm')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
