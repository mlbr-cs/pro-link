class AttendanceRecord {
  const AttendanceRecord({
    this.id,
    required this.weekLabel,
    required this.isPresent,
  });

  final String? id;
  final String weekLabel;
  final bool isPresent;

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id']?.toString(),
      weekLabel:
          (json['week_label'] ?? json['week'] ?? json['label'] ?? '').toString(),
      isPresent: json['is_present'] as bool? ??
          json['present'] as bool? ??
          false,
    );
  }

  AttendanceRecord copyWith({String? weekLabel, bool? isPresent}) {
    return AttendanceRecord(
      id: id,
      weekLabel: weekLabel ?? this.weekLabel,
      isPresent: isPresent ?? this.isPresent,
    );
  }
}
