class MedicationLogEntry {
  const MedicationLogEntry({
    this.id,
    required this.medicationName,
    required this.takenAt,
  });

  final int? id;
  final String medicationName;
  final DateTime takenAt;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'medication_name': medicationName,
      'taken_at': takenAt.toIso8601String(),
    };
  }

  factory MedicationLogEntry.fromMap(Map<String, dynamic> map) {
    return MedicationLogEntry(
      id: map['id'] as int?,
      medicationName: map['medication_name'] as String,
      takenAt: DateTime.parse(map['taken_at'] as String),
    );
  }
}
