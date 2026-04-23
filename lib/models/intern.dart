import 'package:pro_link/models/attendance_record.dart';
import 'package:pro_link/models/skill_evaluation.dart';
import 'package:pro_link/models/timetable_entry.dart';

class Intern {
  const Intern({
    required this.id,
    required this.name,
    required this.email,
    required this.universityId,
    required this.departmentId,
    required this.departmentName,
    required this.mentorId,
    required this.mentorName,
    required this.registrationPending,
    required this.performanceScore,
    required this.performanceComment,
    required this.skillEvaluations,
    required this.timetable,
    required this.attendance,
  });

  final String id;
  final String name;
  final String email;
  final String universityId;
  final String departmentId;
  final String departmentName;
  final String mentorId;
  final String mentorName;
  final bool registrationPending;
  final double? performanceScore;
  final String? performanceComment;
  final List<SkillEvaluation> skillEvaluations;
  final List<TimetableEntry> timetable;
  final List<AttendanceRecord> attendance;

  Intern copyWith({
    String? id,
    String? name,
    String? email,
    String? universityId,
    String? departmentId,
    String? departmentName,
    String? mentorId,
    String? mentorName,
    bool? registrationPending,
    double? performanceScore,
    String? performanceComment,
    List<SkillEvaluation>? skillEvaluations,
    List<TimetableEntry>? timetable,
    List<AttendanceRecord>? attendance,
    bool clearPerformanceScore = false,
    bool clearPerformanceComment = false,
  }) {
    return Intern(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      universityId: universityId ?? this.universityId,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      mentorId: mentorId ?? this.mentorId,
      mentorName: mentorName ?? this.mentorName,
      registrationPending: registrationPending ?? this.registrationPending,
      performanceScore: clearPerformanceScore
          ? null
          : performanceScore ?? this.performanceScore,
      performanceComment: clearPerformanceComment
          ? null
          : performanceComment ?? this.performanceComment,
      skillEvaluations: skillEvaluations ?? this.skillEvaluations,
      timetable: timetable ?? this.timetable,
      attendance: attendance ?? this.attendance,
    );
  }
}
