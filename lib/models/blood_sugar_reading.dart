import 'blood_sugar_band.dart';

class BloodSugarReading {
  const BloodSugarReading({
    this.id,
    required this.type,
    required this.value,
    required this.unit,
    required this.timestamp,
  });

  final int? id;
  final GlucoseTestType type;
  final double value;
  final GlucoseUnit unit;
  final DateTime timestamp;

  GlucoseBand get band => BandClassifier.classify(type, value, unit);

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'type': type.name,
      'value': value,
      'unit': unit.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory BloodSugarReading.fromMap(Map<String, dynamic> map) {
    return BloodSugarReading(
      id: map['id'] as int?,
      type: GlucoseTestType.values.firstWhere((e) => e.name == map['type']),
      value: (map['value'] as num).toDouble(),
      unit: GlucoseUnit.values.firstWhere((e) => e.name == map['unit']),
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory BloodSugarReading.fromJson(Map<String, dynamic> json) => BloodSugarReading.fromMap(json);
}
