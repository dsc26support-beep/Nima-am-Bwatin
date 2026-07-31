import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/medication_log_entry.dart';
import '../repositories/medication_log_repository.dart';
import '../screens/settings/alert_caregiver_screen.dart';
import 'database_service.dart';

const String pillsTakenActionId = 'pills_taken';
const String alertCaregiverActionId = 'alert_caregiver';

/// Handles the "Pills taken" action when the user taps it while the app is
/// not in the foreground. flutter_local_notifications runs this in a
/// separate background Flutter engine, so it opens its own DB connection
/// rather than relying on any state from the main isolate.
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  _handlePillsTaken(response);
}

Future<void> _handlePillsTaken(NotificationResponse response) async {
  if (response.actionId != pillsTakenActionId || response.payload == null) return;
  try {
    final data = jsonDecode(response.payload!) as Map<String, dynamic>;
    final name = data['medicationName'] as String? ?? 'Medication';
    await MedicationLogRepository(DatabaseService.instance)
        .add(MedicationLogEntry(medicationName: name, takenAt: DateTime.now()));
  } catch (_) {
    // Best-effort logging only -- never let a logging failure surface to
    // the user or crash the background isolate.
  }
}

/// Thin wrapper around flutter_local_notifications: channel setup,
/// permission requests, and scheduling/cancelling by notification id.
/// Medication/appointment-specific logic (which ids to use, how a
/// frequency maps to concrete times) lives in scheduling_service.dart.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  /// Wired into MaterialApp so a tap on the "Alert caregiver" notification
  /// action can navigate there even though NotificationService itself has
  /// no BuildContext of its own.
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const medicationChannelId = 'medication_reminders';
  static const appointmentChannelId = 'appointment_reminders';

  /// Android's Notification.FLAG_INSISTENT -- repeats the sound/vibration
  /// continuously until the notification is cancelled, rather than playing
  /// once. Combined with `ongoing`/`autoCancel: false`, this is what makes a
  /// medication reminder behave like a real alarm instead of a normal
  /// dismissible notification.
  static final Int32List _insistentFlag = Int32List.fromList([4]);

  Future<void> init() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();
    try {
      final localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Pacific/Tarawa'));
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.actionId == alertCaregiverActionId) {
          _navigateToAlertCaregiver(response.payload);
        } else {
          _handlePillsTaken(response);
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    final androidPlugin = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        medicationChannelId,
        'Medication reminders',
        importance: Importance.max,
      ),
    );
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        appointmentChannelId,
        'Appointment reminders',
        importance: Importance.max,
      ),
    );

    _initialized = true;
  }

  /// Handles the case where the app was fully closed and got launched by
  /// tapping "Alert caregiver" (rather than the callback above firing into
  /// an already-running app). Call once, after the first frame, from the
  /// startup screen.
  Future<void> handleLaunchFromNotification() async {
    final details = await plugin.getNotificationAppLaunchDetails();
    final response = details?.notificationResponse;
    if (details?.didNotificationLaunchApp == true &&
        response != null &&
        response.actionId == alertCaregiverActionId) {
      _navigateToAlertCaregiver(response.payload);
    }
  }

  static void _navigateToAlertCaregiver(String? payload) {
    String? medicationName;
    if (payload != null) {
      try {
        final data = jsonDecode(payload) as Map<String, dynamic>;
        medicationName = data['medicationName'] as String?;
      } catch (_) {
        // Ignore -- fall back to the generic (no medication name) message.
      }
    }
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => AlertCaregiverScreen(medicationName: medicationName)),
    );
  }

  Future<void> requestPermissions() async {
    final androidPlugin = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  /// Whether exact-time alarms are currently permitted on this device. When
  /// not granted (the user hasn't toggled "Alarms & reminders" for this app
  /// in system settings), reminders must still fire -- just less precisely
  /// -- rather than silently never firing at all.
  Future<AndroidScheduleMode> _scheduleMode() async {
    try {
      final granted = await Permission.scheduleExactAlarm.isGranted;
      return granted ? AndroidScheduleMode.exactAllowWhileIdle : AndroidScheduleMode.inexactAllowWhileIdle;
    } catch (_) {
      return AndroidScheduleMode.inexactAllowWhileIdle;
    }
  }

  /// Medication reminders are ongoing/insistent "alarms": they can't be
  /// swiped away, they repeat their sound/vibration until acted on, and the
  /// only way to stop one is the "Pills taken" action (which cancels it).
  /// "Alert caregiver" is a second, non-cancelling action that opens the
  /// app to a screen for messaging a saved caregiver -- the alarm keeps
  /// ringing since the medication still hasn't been taken.
  NotificationDetails _medicationDetails(String pillsTakenLabel, String alertCaregiverLabel) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        medicationChannelId,
        'Medication reminders',
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.alarm,
        fullScreenIntent: true,
        ongoing: true,
        autoCancel: false,
        playSound: true,
        enableVibration: true,
        additionalFlags: _insistentFlag,
        actions: [
          AndroidNotificationAction(pillsTakenActionId, pillsTakenLabel, cancelNotification: true),
          AndroidNotificationAction(
            alertCaregiverActionId,
            alertCaregiverLabel,
            showsUserInterface: true,
            cancelNotification: false,
          ),
        ],
      ),
    );
  }

  NotificationDetails _appointmentDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        appointmentChannelId,
        'Appointment reminders',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  tz.TZDateTime _nextInstanceOfTimeAndWeekday(TimeOfDay time, int weekday) {
    var scheduled = _nextInstanceOfTime(time);
    while (scheduled.weekday != weekday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> scheduleDaily(
    int id,
    String title,
    String body,
    TimeOfDay time, {
    required String pillsTakenLabel,
    required String alertCaregiverLabel,
    required String payload,
  }) async {
    await plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(time),
      _medicationDetails(pillsTakenLabel, alertCaregiverLabel),
      androidScheduleMode: await _scheduleMode(),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  Future<void> scheduleWeekly(
    int id,
    String title,
    String body,
    TimeOfDay time,
    int weekday, {
    required String pillsTakenLabel,
    required String alertCaregiverLabel,
    required String payload,
  }) async {
    await plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTimeAndWeekday(time, weekday),
      _medicationDetails(pillsTakenLabel, alertCaregiverLabel),
      androidScheduleMode: await _scheduleMode(),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: payload,
    );
  }

  Future<void> scheduleOneShot(int id, String title, String body, DateTime dateTime) async {
    final tzTime = tz.TZDateTime.from(dateTime, tz.local);
    await plugin.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      _appointmentDetails(),
      androidScheduleMode: await _scheduleMode(),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancel(int id) => plugin.cancel(id);

  Future<void> cancelRange(int startId, int count) async {
    for (var i = 0; i < count; i++) {
      await plugin.cancel(startId + i);
    }
  }
}
