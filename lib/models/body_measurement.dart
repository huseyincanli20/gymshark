import 'dart:convert';

class BodyMeasurement {
  final String id;
  final DateTime date;
  final double weightKg;
  final double chestCm;
  final double armCm;
  final double waistCm;
  final double hipsCm;
  final double thighCm;
  final double shouldersCm;
  final String note;
  final String? photoBase64;

  BodyMeasurement({
    required this.id,
    required this.date,
    required this.weightKg,
    this.chestCm = 0.0,
    this.armCm = 0.0,
    this.waistCm = 0.0,
    this.hipsCm = 0.0,
    this.thighCm = 0.0,
    this.shouldersCm = 0.0,
    this.note = '',
    this.photoBase64,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'weightKg': weightKg,
      'chestCm': chestCm,
      'armCm': armCm,
      'waistCm': waistCm,
      'hipsCm': hipsCm,
      'thighCm': thighCm,
      'shouldersCm': shouldersCm,
      'note': note,
      'photoBase64': photoBase64,
    };
  }

  factory BodyMeasurement.fromMap(Map<String, dynamic> map) {
    return BodyMeasurement(
      id: map['id'] ?? '',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 70.0,
      chestCm: (map['chestCm'] as num?)?.toDouble() ?? 0.0,
      armCm: (map['armCm'] as num?)?.toDouble() ?? 0.0,
      waistCm: (map['waistCm'] as num?)?.toDouble() ?? 0.0,
      hipsCm: (map['hipsCm'] as num?)?.toDouble() ?? 0.0,
      thighCm: (map['thighCm'] as num?)?.toDouble() ?? 0.0,
      shouldersCm: (map['shouldersCm'] as num?)?.toDouble() ?? 0.0,
      note: map['note'] ?? '',
      photoBase64: map['photoBase64'],
    );
  }

  String toJson() => jsonEncode(toMap());
  factory BodyMeasurement.fromJson(String source) => BodyMeasurement.fromMap(jsonDecode(source));
}
