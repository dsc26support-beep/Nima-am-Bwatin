import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Must happen on every app start, not just during onboarding -- otherwise
  // returning users (who skip onboarding and land straight on HomeScreen)
  // never get the notification plugin/channels initialized in this process,
  // and every reminder silently fails to schedule.
  await NotificationService.instance.init();
  runApp(const ProviderScope(child: App()));
}
