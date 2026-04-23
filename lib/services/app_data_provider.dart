import 'package:flutter/material.dart';
import 'package:pro_link/models/attendance_record.dart';
import 'package:pro_link/models/department.dart';
import 'package:pro_link/models/intern.dart';
import 'package:pro_link/models/mentor_profile.dart';
import 'package:pro_link/models/training_document.dart';
import 'package:pro_link/services/api_service.dart';

class AppDataProvider extends ChangeNotifier {
  AppDataProvider({required ApiService apiService}) : _apiService = apiService;

  final ApiService _apiService;

  bool _isInitialized = false;
  bool _isLoading = false;
  List<Intern> _interns = [];
  List<Department> _departments = [];
  List<MentorProfile> _mentors = [];
  List<TrainingDocument> _trainingDocuments = [];
  String? _officeTimetableFileName;
  String? _mentorTrainingFileName;

  bool get isLoading => _isLoading;
  String? get officeTimetableFileName => _officeTimetableFileName;
  String? get mentorTrainingFileName => _mentorTrainingFileName;
  List<Intern> get interns => List.unmodifiable(_interns);
  List<Department> get departments => List.unmodifiable(_departments);
  List<MentorProfile> get mentors => List.unmodifiable(_mentors);
  List<TrainingDocument> get trainingDocuments =>
      List.unmodifiable(_trainingDocuments);

  List<Intern> get approvedInterns =>
      _interns.where((intern) => !intern.registrationPending).toList();

  List<Intern> get pendingRegistrations =>
      _interns.where((intern) => intern.registrationPending).toList();

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    _departments = await _apiService.getDepartments();
    _mentors = await _apiService.getMentors();
    _trainingDocuments = await _apiService.getTrainingDocuments();
    _interns = List<Intern>.from(await _apiService.getInterns());

    _isInitialized = true;
    _isLoading = false;
    notifyListeners();
  }

  Intern? internByEmail(String email) {
    try {
      return _interns.firstWhere(
        (intern) => intern.email.toLowerCase() == email.toLowerCase(),
      );
    } catch (_) {
      return _interns.isNotEmpty ? _interns.first : null;
    }
  }

  List<Intern> internsForMentor(String mentorName) {
    return approvedInterns
        .where(
          (intern) =>
              intern.mentorName.toLowerCase() == mentorName.toLowerCase(),
        )
        .toList();
  }

  void assignIntern({
    required String internId,
    required String departmentId,
    required String mentorId,
  }) {
    final department = _departments.firstWhere(
      (item) => item.id == departmentId,
    );
    final mentor = _mentors.firstWhere((item) => item.id == mentorId);
    final index = _interns.indexWhere((intern) => intern.id == internId);

    if (index == -1) {
      return;
    }

    _interns[index] = _interns[index].copyWith(
      departmentId: department.id,
      departmentName: department.name,
      mentorId: mentor.id,
      mentorName: mentor.name,
    );
    notifyListeners();
  }

  void approveRegistration(String internId) {
    final index = _interns.indexWhere((intern) => intern.id == internId);
    if (index == -1) {
      return;
    }

    _interns[index] = _interns[index].copyWith(registrationPending: false);
    notifyListeners();
  }

  void rejectRegistration(String internId) {
    _interns.removeWhere((intern) => intern.id == internId);
    notifyListeners();
  }

  void setOfficeTimetableFileName(String fileName) {
    _officeTimetableFileName = fileName;
    notifyListeners();
  }

  void setMentorTrainingFileName(String fileName) {
    _mentorTrainingFileName = fileName;
    notifyListeners();
  }

  void savePerformanceMark({
    required String internId,
    required double score,
    required String comment,
  }) {
    final index = _interns.indexWhere((intern) => intern.id == internId);
    if (index == -1) {
      return;
    }

    _interns[index] = _interns[index].copyWith(
      performanceScore: score,
      performanceComment: comment,
    );
    notifyListeners();
  }

  void updateAttendance({
    required String internId,
    required String weekLabel,
    required bool isPresent,
  }) {
    final index = _interns.indexWhere((intern) => intern.id == internId);
    if (index == -1) {
      return;
    }

    final updatedAttendance = _interns[index].attendance
        .map(
          (record) => record.weekLabel == weekLabel
              ? record.copyWith(isPresent: isPresent)
              : record,
        )
        .toList();

    _interns[index] = _interns[index].copyWith(attendance: updatedAttendance);
    notifyListeners();
  }
}
