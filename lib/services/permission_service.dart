import 'package:permission_handler/permission_handler.dart';

/// Requests the Android permissions reminders depend on: posting
/// notifications (Android 13+) and scheduling exact alarms (Android 12+).
/// Without the exact-alarm permission, scheduled reminders can silently
/// degrade to inexact timing on some OEM builds.
class PermissionService {
  Future<void> requestAll() async {
    await Permission.notification.request();
    await Permission.scheduleExactAlarm.request();
  }
}
