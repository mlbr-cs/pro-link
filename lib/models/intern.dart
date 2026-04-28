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
    required this.status,
    this.performanceId,
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
  final String status;
  final String? performanceId;
  final double? performanceScore;
  final String? performanceComment;
  final List<SkillEvaluation> skillEvaluations;
  final List<TimetableEntry> timetable;
  final List<AttendanceRecord> attendance;

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isRejected => status.toLowerCase() == 'rejected';

  factory Intern.fromJson(Map<String, dynamic> json) {
    final departmentValue = json['department'];
    final mentorValue = json['mentor'];
    final evaluationValue = json['performance_evaluation'] ?? json['evaluation'];
    final skillsValue = json['skill_evaluations'] ?? json['evaluations'];
    final attendanceValue = json['attendance'];
    final scheduleValue = json['schedule'] ?? json['timetable'];

    String departmentId = '';
    String departmentName = '';
    if (departmentValue is Map<String, dynamic>) {
      departmentId = (departmentValue['id'] ?? '').toString();
      departmentName = (departmentValue['name'] ?? '').toString();
    } else {
      departmentName = (departmentValue ?? '').toString();
    }

    String mentorId = '';
    String mentorName = '';
    if (mentorValue is Map<String, dynamic>) {
      mentorId = (mentorValue['id'] ?? '').toString();
      mentorName =
          (mentorValue['full_name'] ?? mentorValue['name'] ?? '').toString();
    } else {
      mentorName = (mentorValue ?? '').toString();
    }

    String? performanceId;
    double? performanceScore;
    String? performanceComment;
    if (evaluationValue is Map<String, dynamic>) {
      performanceId = evaluationValue['id']?.toString();
      performanceScore = double.tryParse(
        (evaluationValue['score'] ?? evaluationValue['mark'] ?? '').toString(),
      );
      performanceComment =
          (evaluationValue['comment'] ?? evaluationValue['feedback'] ?? '')
              .toString();
    } else {
      performanceScore = double.tryParse(
        (json['performance_score'] ?? json['score'] ?? '').toString(),
      );
      final rawComment =
          (json['performance_comment'] ?? json['comment'] ?? '').toString();
      performanceComment = rawComment.isEmpty ? null : rawComment;
    }

    return Intern(
      id: (json['id'] ?? '').toString(),
      name: (json['full_name'] ?? json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      universityId:
          (json['university_id'] ?? json['student_id'] ?? '').toString(),
      departmentId: departmentId,
      departmentName: departmentName,
      mentorId: mentorId,
      mentorName: mentorName,
      status: (json['status'] ?? '').toString(),
      performanceId: performanceId,
      performanceScore: performanceScore,
      performanceComment: performanceComment,
      skillEvaluations: skillsValue is List
          ? skillsValue
              .whereType<Map<String, dynamic>>()
              .map(SkillEvaluation.fromJson)
              .toList()
          : const [],
      timetable: scheduleValue is List
          ? scheduleValue
              .whereType<Map<String, dynamic>>()
              .map(TimetableEntry.fromJson)
              .toList()
          : const [],
      attendance: attendanceValue is List
          ? attendanceValue
              .whereType<Map<String, dynamic>>()
              .map(AttendanceRecord.fromJson)
              .toList()
          : const [],
    );
  }

  Intern copyWith({
    String? id,
    String? name,
    String? email,
    String? universityId,
    String? departmentId,
    String? departmentName,
    String? mentorId,
    String? mentorName,
    String? status,
    String? performanceId,
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
      status: status ?? this.status,
      performanceId: performanceId ?? this.performanceId,
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
