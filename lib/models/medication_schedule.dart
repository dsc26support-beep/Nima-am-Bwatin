import 'dart:convert';

import 'package:flutter/material.dart' show TimeOfDay;

enum FrequencyType { timesPerDay, specificTimes, everyXHours, specificWeekdays }

FrequencyType frequencyTypeFromName(String name) {
  return FrequencyType.values.firstWhere(
    (e) => e.name == name,
    orElse: () => FrequencyType.specificTimes,
  );
}

/// A medication's reminder schedule.
///
/// Regardless of [type], by the time a schedule reaches the notification
/// layer it is fully described by [times] (the concrete clock times to
/// remind at) and [weekdays] (which days those times apply to; empty means
/// every day). [timesPerDay] / [everyXHours] are kept only so the edit form
/// can regenerate sensible defaults if the user changes the count/interval.
class MedicationSchedule {
  const MedicationSchedule({
    required this.type,
    required this.times,
    this.weekdays = const [],
    this.timesPerDay,
    this.everyXHours,
  });

  final FrequencyType type;
  final List<TimeOfDay> times;

  /// ISO weekday numbers (1 = Monday .. 7 = Sunday). Empty = every day.
  final List<int> weekdays;

  final int? timesPerDay;
  final int? everyXHours;

  Map<String, dynamic> toMap() {
    return {
      'frequency_type': type.name,
      'times_per_day': timesPerDay,
      'every_x_hours': everyXHours,
      'weekdays': jsonEncode(weekdays),
      'times': jsonEncode(times.map((t) => '${t.hour}:${t.minute}').toList()),
    };
  }

  factory MedicationSchedule.fromMap(Map<String, dynamic> map) {
    final weekdaysList = (jsonDecode(map['weekdays'] as String) as List)
        .map((e) => e as int)
        .toList();
    final timesList = (jsonDecode(map['times'] as String) as List)
        .map((e) => e as String)
        .map((s) {
      final parts = s.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }).toList();

    return MedicationSchedule(
      type: frequencyTypeFromName(map['frequency_type'] as String),
      times: timesList,
      weekdays: weekdaysList,
      timesPerDay: map['times_per_day'] as int?,
      everyXHours: map['every_x_hours'] as int?,
    );
  }
}
