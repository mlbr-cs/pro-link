class AttendanceRecord {
  const AttendanceRecord({required this.weekLabel, required this.isPresent});

  final String weekLabel;
  final bool isPresent;

  AttendanceRecord copyWith({String? weekLabel, bool? isPresent}) {
    return AttendanceRecord(
      weekLabel: weekLabel ?? this.weekLabel,
      isPresent: isPresent ?? this.isPresent,
    );
  }
}
