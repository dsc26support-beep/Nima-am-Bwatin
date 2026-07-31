import 'dart:convert';

import 'medication_schedule.dart';

class Medication {
  const Medication({
    this.id,
    required this.name,
    required this.dosage,
    required this.schedule,
    this.notificationIds = const [],
    this.isActive = true,
  });

  final int? id;
  final String name;
  final String dosage;
  final MedicationSchedule schedule;
  final List<int> notificationIds;
  final bool isActive;

  Medication copyWith({
    int? id,
    String? name,
    String? dosage,
    MedicationSchedule? schedule,
    List<int>? notificationIds,
    bool? isActive,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      schedule: schedule ?? this.schedule,
      notificationIds: notificationIds ?? this.notificationIds,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'dosage': dosage,
      ...schedule.toMap(),
      'notification_ids': jsonEncode(notificationIds),
      'is_active': isActive ? 1 : 0,
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map['id'] as int?,
      name: map['name'] as String,
      dosage: map['dosage'] as String,
      schedule: MedicationSchedule.fromMap(map),
      notificationIds: (jsonDecode(map['notification_ids'] as String) as List)
          .map((e) => e as int)
          .toList(),
      isActive: (map['is_active'] as int) == 1,
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory Medication.fromJson(Map<String, dynamic> json) => Medication.fromMap(json);
}
