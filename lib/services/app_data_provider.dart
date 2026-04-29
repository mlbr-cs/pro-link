import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pro_link/models/app_user.dart';
import 'package:pro_link/models/department.dart';
import 'package:pro_link/models/intern.dart';
import 'package:pro_link/models/mentor_profile.dart';
import 'package:pro_link/models/training_document.dart';
import 'package:pro_link/services/api_service.dart';

class AppDataProvider extends ChangeNotifier {
  AppDataProvider({required ApiService apiService}) : _apiService = apiService;

  final ApiService _apiService;

  bool _isLoading = false;
  String? _errorMessage;
  List<Intern> _interns = [];
  List<Department> _departments = [];
  List<MentorProfile> _mentors = [];
  List<TrainingDocument> _trainingDocuments = [];
  List<String> _scheduleFiles = [];
  String? _officeTimetableFileName;
  String? _mentorTrainingFileName;
  List<AppUser> _pendingUsers = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get officeTimetableFileName => _officeTimetableFileName;
  String? get mentorTrainingFileName => _mentorTrainingFileName;
  List<Intern> get interns => List.unmodifiable(_interns);
  List<Department> get departments => List.unmodifiable(_departments);
  List<MentorProfile> get mentors => List.unmodifiable(_mentors);
  List<TrainingDocument> get trainingDocuments =>
      List.unmodifiable(_trainingDocuments);
  List<String> get scheduleFiles => List.unmodifiable(_scheduleFiles);
  List<AppUser> get pendingUsers => List.unmodifiable(_pendingUsers);

  List<Intern> get approvedInterns =>
      _interns.where((intern) => intern.isApproved).toList();

  List<AppUser> get pendingRegistrations => pendingUsers;

  Future<void> initialize() async {}

  Future<void> loadForRole(UserRole role) async {
    switch (role) {
      case UserRole.admin:
        await loadAdminData();
        break;
      case UserRole.mentor:
        await loadMentorData();
        break;
      case UserRole.intern:
        await loadInternData();
        break;
    }
  }

  Future<void> _perform(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
    } on Exception catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAdminData() async {
    await _perform(() async {
      _interns = await _apiService.getInterns();
      _departments = await _apiService.getDepartments();
      _mentors = await _apiService.getMentors();
      _scheduleFiles = await _apiService.getScheduleFileNames();
      _pendingUsers = await _apiService.getPendingUsers();
    });
  }

  Future<void> loadMentorData() async {
    await _perform(() async {
      final mentorInterns = await _apiService.getMentorInterns();
      final attendanceByIntern = await _apiService.getAttendanceByIntern();
      _interns = mentorInterns
          .map(
            (intern) => intern.copyWith(
              attendance: attendanceByIntern[intern.id] ?? intern.attendance,
            ),
          )
          .toList();
      _trainingDocuments = await _apiService.getTrainingFiles();
      _departments = [];
      _mentors = [];
      _scheduleFiles = [];
    });
  }

  Future<void> loadInternData() async {
    await _perform(() async {
      final profile = await _apiService.getInternProfile();
      final evaluations = await _apiService.getInternEvaluations();
      final schedule = await _apiService.getInternSchedule();
      _scheduleFiles = await _apiService.getScheduleFileNames();
      _trainingDocuments = await _apiService.getInternTrainingFiles();
      _interns = [
        profile.copyWith(skillEvaluations: evaluations, timetable: schedule),
      ];
      _departments = [];
      _mentors = [];
    });
  }

  void clear() {
    _interns = [];
    _departments = [];
    _mentors = [];
    _trainingDocuments = [];
    _scheduleFiles = [];
    _officeTimetableFileName = null;
    _mentorTrainingFileName = null;
    _pendingUsers = [];
    _errorMessage = null;
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
    return _interns.where((intern) {
      final currentMentorName = intern.mentorName.trim().toLowerCase();
      final expectedMentorName = mentorName.trim().toLowerCase();
      return currentMentorName.isEmpty ||
          currentMentorName == expectedMentorName;
    }).toList();
  }

  Future<void> assignIntern({
    required String internId,
    required String departmentId,
    required String mentorId,
  }) async {
    await _perform(() async {
      final updated = await _apiService.assignIntern(
        internId: internId,
        departmentId: departmentId,
        mentorId: mentorId,
      );
      final index = _interns.indexWhere((intern) => intern.id == internId);
      if (index != -1) {
        _interns[index] = updated;
      }
    });
  }

  Future<void> approveRegistration(String userId) async {
    await _perform(() async {
      await _apiService.approveUser(userId);
      _pendingUsers.removeWhere((user) => user.id == userId);
      // Refresh interns list so "Interns" and "Assign" reflect approvals.
      _interns = await _apiService.getInterns();
    });
  }

  Future<void> rejectRegistration(String userId) async {
    await _perform(() async {
      await _apiService.rejectUser(userId);
      _pendingUsers.removeWhere((user) => user.id == userId);
      _interns = await _apiService.getInterns();
    });
  }

  Future<void> uploadOfficeTimetable(PlatformFile file) async {
    await _perform(() async {
      final fileName = await _apiService.uploadScheduleFile(file);
      _officeTimetableFileName = fileName;
      _scheduleFiles = [
        fileName,
        ..._scheduleFiles.where((item) => item != fileName),
      ];
    });
  }

  Future<void> uploadMentorTrainingFile(PlatformFile file) async {
    await _perform(() async {
      final uploaded = await _apiService.uploadTrainingFile(file);
      _mentorTrainingFileName = uploaded.fileName;
      _trainingDocuments = [
        uploaded,
        ..._trainingDocuments.where((item) => item.id != uploaded.id),
      ];
    });
  }

  Future<void> savePerformanceMark({
    required String internId,
    required double score,
    required String comment,
  }) async {
    await _perform(() async {
      final index = _interns.indexWhere((intern) => intern.id == internId);
      if (index == -1) {
        return;
      }

      final currentIntern = _interns[index];
      final evaluation = currentIntern.performanceId == null
          ? await _apiService.createEvaluation(
              internId: internId,
              score: score,
              comment: comment,
            )
          : await _apiService.updateEvaluation(
              evaluationId: currentIntern.performanceId!,
              score: score,
              comment: comment,
            );

      _interns[index] = currentIntern.copyWith(
        performanceId: evaluation.id,
        performanceScore: evaluation.score,
        performanceComment: evaluation.feedback,
      );
    });
  }

  Future<void> updateAttendance({
    required String internId,
    required String weekLabel,
    required bool isPresent,
  }) async {
    await _perform(() async {
      final savedRecord = await _apiService.submitAttendance(
        internId: internId,
        weekLabel: weekLabel,
        isPresent: isPresent,
      );
      final index = _interns.indexWhere((intern) => intern.id == internId);
      if (index == -1) {
        return;
      }

      final currentAttendance = [..._interns[index].attendance];
      final recordIndex = currentAttendance.indexWhere(
        (record) => record.weekLabel == weekLabel,
      );
      if (recordIndex == -1) {
        currentAttendance.add(savedRecord);
      } else {
        currentAttendance[recordIndex] = savedRecord;
      }

      _interns[index] = _interns[index].copyWith(attendance: currentAttendance);
    });
  }
}
