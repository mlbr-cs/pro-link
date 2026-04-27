class TimetableEntry {
  const TimetableEntry({
    required this.day,
    required this.morning,
    required this.afternoon,
  });

  final String day;
  final String morning;
  final String afternoon;

  factory TimetableEntry.fromJson(Map<String, dynamic> json) {
    return TimetableEntry(
      day: (json['day'] ?? '').toString(),
      morning: (json['morning'] ?? json['start_slot'] ?? '').toString(),
      afternoon: (json['afternoon'] ?? json['end_slot'] ?? '').toString(),
    );
  }
}
