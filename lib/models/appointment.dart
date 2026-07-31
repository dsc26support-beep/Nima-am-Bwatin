class Appointment {
  const Appointment({
    this.id,
    required this.title,
    required this.location,
    required this.dateTime,
    required this.reminderLeadMinutes,
    this.notificationId,
  });

  final int? id;
  final String title;
  final String location;
  final DateTime dateTime;

  /// How long before [dateTime] the reminder notification should fire.
  final int reminderLeadMinutes;

  final int? notificationId;

  Appointment copyWith({
    int? id,
    String? title,
    String? location,
    DateTime? dateTime,
    int? reminderLeadMinutes,
    int? notificationId,
  }) {
    return Appointment(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      dateTime: dateTime ?? this.dateTime,
      reminderLeadMinutes: reminderLeadMinutes ?? this.reminderLeadMinutes,
      notificationId: notificationId ?? this.notificationId,
    );
  }

  DateTime get reminderTime => dateTime.subtract(Duration(minutes: reminderLeadMinutes));

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'location': location,
      'date_time': dateTime.toIso8601String(),
      'reminder_lead_minutes': reminderLeadMinutes,
      'notification_id': notificationId,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] as int?,
      title: map['title'] as String,
      location: map['location'] as String,
      dateTime: DateTime.parse(map['date_time'] as String),
      reminderLeadMinutes: map['reminder_lead_minutes'] as int,
      notificationId: map['notification_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment.fromMap(json);
}
