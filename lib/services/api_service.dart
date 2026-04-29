import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:pro_link/models/app_user.dart';
import 'package:pro_link/models/attendance_record.dart';
import 'package:pro_link/models/department.dart';
import 'package:pro_link/models/intern.dart';
import 'package:pro_link/models/mentor_profile.dart';
import 'package:pro_link/models/skill_evaluation.dart';
import 'package:pro_link/models/timetable_entry.dart';
import 'package:pro_link/models/training_document.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = 'http://10.0.2.2:8000';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiService {
  ApiService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
        ),
      );

  final Dio _dio;
  final http.Client _client = http.Client();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<void> _saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await _prefs;
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  Future<String?> _getToken() async {
    final prefs = await _prefs;
    return prefs.getString(_accessTokenKey);
  }

  Future<void> clearSession() async {
    final prefs = await _prefs;
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  Future<Map<String, String>> _headers({bool includeJson = true}) async {
    final headers = <String, String>{'Accept': 'application/json'};
    final token = await _getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    if (includeJson) {
      headers['Content-Type'] = 'application/json';
    }
    return headers;
  }

  Future<MultipartFile> _multipartFromPlatformFile(PlatformFile file) async {
    if (file.path != null) {
      return MultipartFile.fromFile(file.path!, filename: file.name);
    }
    if (file.bytes != null) {
      return MultipartFile.fromBytes(file.bytes!, filename: file.name);
    }
    throw ApiException('Selected file "${file.name}" could not be read.');
  }

  List<dynamic> _decodeListResponse(String body) {
    final decoded = jsonDecode(body);
    if (decoded is List) {
      return decoded;
    }
    if (decoded is Map<String, dynamic>) {
      final results = decoded['results'] ?? decoded['data'] ?? decoded['items'];
      if (results is List) {
        return results;
      }
    }
    return const [];
  }

  Map<String, dynamic> _decodeMapResponse(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      if (decoded['data'] is Map<String, dynamic>) {
        return decoded['data'] as Map<String, dynamic>;
      }
      return decoded;
    }
    return <String, dynamic>{};
  }

  Never _throwForDioException(DioException error, String fallbackMessage) {
    final response = error.response;
    var message = fallbackMessage;
    final data = response?.data;

    if (data is Map) {
      final detail = data['detail'] ?? data['message'] ?? data['error'];
      if (detail != null) {
        message = detail.toString();
      } else if (data.isNotEmpty) {
        message = data.entries
            .map((entry) {
              final value = entry.value;
              if (value is List) {
                return '${entry.key}: ${value.join(', ')}';
              }
              return '${entry.key}: $value';
            })
            .join('\n');
      }
    } else if (data is String && data.trim().isNotEmpty) {
      message = data.trim();
    }

    throw ApiException(message, statusCode: response?.statusCode);
  }

  Never _throwForResponse(http.Response response, String fallbackMessage) {
    String message = fallbackMessage;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        message =
            (decoded['detail'] ??
                    decoded['message'] ??
                    decoded['error'] ??
                    fallbackMessage)
                .toString();
      }
    } catch (_) {}

    switch (response.statusCode) {
      case 401:
        throw ApiException(
          'Unauthorized. Please sign in again.',
          statusCode: 401,
        );
      case 403:
        throw ApiException('Access denied for this action.', statusCode: 403);
      case 404:
        throw ApiException(
          'Requested resource was not found.',
          statusCode: 404,
        );
      default:
        throw ApiException(message, statusCode: response.statusCode);
    }
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/auth/login/'),
      headers: await _headers(),
      body: jsonEncode({'email': email.trim(), 'password': password}),
    );

    if (response.statusCode != 200) {
      _throwForResponse(response, 'Login failed.');
    }

    final json = _decodeMapResponse(response.body);
    final access = (json['access'] ?? '').toString();
    final refresh = (json['refresh'] ?? '').toString();
    if (access.isEmpty || refresh.isEmpty) {
      throw const ApiException('Missing authentication tokens from server.');
    }

    await _saveTokens(accessToken: access, refreshToken: refresh);

    final userData = json['user'];
    if (userData is Map<String, dynamic>) {
      return AppUser.fromJson(userData);
    }
    return getCurrentUser();
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
    String? universityId,
    PlatformFile? photo,
  }) async {
    final data = FormData.fromMap({
      'email': email.trim(),
      'password': password,
      'full_name': fullName.trim(),
      'role': role,
      if (universityId != null) 'university_id': universityId.trim(),
      if (photo != null) 'photo': await _multipartFromPlatformFile(photo),
    });

    final response = await _dio.post(
      '/api/auth/register/',
      data: data,
      options: Options(headers: {'Accept': 'application/json'}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    }

    throw const ApiException('Registration failed.');
  }

  Future<AppUser> getCurrentUser() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/auth/me/'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return AppUser.fromJson(_decodeMapResponse(response.body));
    }

    _throwForResponse(response, 'Failed to load current user.');
  }

  Future<List<Intern>> getInterns() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/interns/'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return _decodeListResponse(
        response.body,
      ).whereType<Map<String, dynamic>>().map(Intern.fromJson).toList();
    }

    _throwForResponse(response, 'Failed to load interns.');
  }

  Future<List<AppUser>> getPendingUsers() async {
    final url = '$baseUrl/api/pending-users/';
    print('Calling: $url');

    final response = await _client.get(
      Uri.parse(url),
      headers: await _headers(),
    );

    print('Status: ${response.statusCode}');
    print('Response: ${response.body}');

    if (response.statusCode == 200) {
      return _decodeListResponse(response.body)
          .whereType<Map<String, dynamic>>()
          .map(AppUser.fromJson)
          .toList();
    }

    _throwForResponse(response, 'Failed to load pending users.');
  }

  Future<AppUser> approveUser(String userId) async {
    final url = '$baseUrl/api/approve-user/$userId/';
    print('Calling: $url');

    final response = await _client.post(
      Uri.parse(url),
      headers: await _headers(),
    );

    print('Status: ${response.statusCode}');
    print('Response: ${response.body}');

    if (response.statusCode == 200) {
      return AppUser.fromJson(_decodeMapResponse(response.body));
    }

    _throwForResponse(response, 'Failed to approve user.');
  }

  Future<AppUser> rejectUser(String userId) async {
    final url = '$baseUrl/api/reject-user/$userId/';
    print('Calling: $url');

    final response = await _client.post(
      Uri.parse(url),
      headers: await _headers(),
    );

    print('Status: ${response.statusCode}');
    print('Response: ${response.body}');

    if (response.statusCode == 200) {
      return AppUser.fromJson(_decodeMapResponse(response.body));
    }

    _throwForResponse(response, 'Failed to reject user.');
  }

  Future<Intern> updateInternStatus({
    required String internId,
    required String status,
  }) async {
    final response = await _client.patch(
      Uri.parse('$baseUrl/api/interns/$internId/status/'),
      headers: await _headers(),
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode == 200 || response.statusCode == 202) {
      return Intern.fromJson(_decodeMapResponse(response.body));
    }

    _throwForResponse(response, 'Failed to update intern status.');
  }

  Future<Intern> assignIntern({
    required String internId,
    required String departmentId,
    required String mentorId,
  }) async {
    final response = await _client.patch(
      Uri.parse('$baseUrl/api/interns/$internId/assign/'),
      headers: await _headers(),
      body: jsonEncode({'department_id': departmentId, 'mentor_id': mentorId}),
    );

    if (response.statusCode == 200) {
      return Intern.fromJson(_decodeMapResponse(response.body));
    }

    _throwForResponse(response, 'Failed to assign intern.');
  }

  Future<String> uploadScheduleFile(PlatformFile file) async {
    final token = await _getToken();
    late final Response<dynamic> response;
    try {
      response = await _dio.post(
        '/api/schedules/',
        data: FormData.fromMap({
          'file': await _multipartFromPlatformFile(file),
        }),
        options: Options(
          headers: {
            'Accept': 'application/json',
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (error) {
      _throwForDioException(error, 'Failed to upload office timetable.');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return (data['file_name'] ?? data['name'] ?? file.name).toString();
      }
      if (data is Map) {
        return (data['file_name'] ?? data['name'] ?? file.name).toString();
      }
      return file.name;
    }

    throw const ApiException('Failed to upload office timetable.');
  }

  Future<List<String>> getScheduleFileNames() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/schedules/'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return _decodeListResponse(response.body)
          .map((item) {
            if (item is Map<String, dynamic>) {
              return (item['file_name'] ?? item['name'] ?? item['file'] ?? '')
                  .toString();
            }
            return item.toString();
          })
          .where((item) => item.isNotEmpty)
          .toList();
    }

    _throwForResponse(response, 'Failed to load schedules.');
  }

  Future<List<MentorProfile>> getMentors() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/mentors/'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return _decodeListResponse(
        response.body,
      ).whereType<Map<String, dynamic>>().map(MentorProfile.fromJson).toList();
    }

    _throwForResponse(response, 'Failed to load mentors.');
  }

  Future<List<Department>> getDepartments() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/departments/'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return _decodeListResponse(
        response.body,
      ).whereType<Map<String, dynamic>>().map(Department.fromJson).toList();
    }

    _throwForResponse(response, 'Failed to load departments.');
  }

  Future<List<Intern>> getMentorInterns() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/mentor/interns/'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return _decodeListResponse(
        response.body,
      ).whereType<Map<String, dynamic>>().map(Intern.fromJson).toList();
    }

    _throwForResponse(response, 'Failed to load mentor interns.');
  }

  Future<SkillEvaluation> createEvaluation({
    required String internId,
    required double score,
    required String comment,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/evaluations/'),
      headers: await _headers(),
      body: jsonEncode({
        'intern': internId,
        'score': score,
        'comment': comment,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return SkillEvaluation.fromJson(_decodeMapResponse(response.body));
    }

    _throwForResponse(response, 'Failed to submit evaluation.');
  }

  Future<SkillEvaluation> updateEvaluation({
    required String evaluationId,
    required double score,
    required String comment,
  }) async {
    final response = await _client.patch(
      Uri.parse('$baseUrl/api/evaluations/$evaluationId/'),
      headers: await _headers(),
      body: jsonEncode({'score': score, 'comment': comment}),
    );

    if (response.statusCode == 200) {
      return SkillEvaluation.fromJson(_decodeMapResponse(response.body));
    }

    _throwForResponse(response, 'Failed to update evaluation.');
  }

  Future<Map<String, List<AttendanceRecord>>> getAttendanceByIntern() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/attendance/'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      _throwForResponse(response, 'Failed to load attendance.');
    }

    final grouped = <String, List<AttendanceRecord>>{};
    for (final item in _decodeListResponse(response.body)) {
      if (item is! Map<String, dynamic>) {
        continue;
      }
      final record = AttendanceRecord.fromJson(item);
      final internId =
          (item['intern_id'] ?? item['intern'] ?? item['student'] ?? '')
              .toString();
      if (internId.isEmpty) {
        continue;
      }
      grouped.putIfAbsent(internId, () => <AttendanceRecord>[]).add(record);
    }
    return grouped;
  }

  Future<AttendanceRecord> submitAttendance({
    required String internId,
    required String weekLabel,
    required bool isPresent,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/attendance/'),
      headers: await _headers(),
      body: jsonEncode({
        'intern': internId,
        'week_label': weekLabel,
        'is_present': isPresent,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AttendanceRecord.fromJson(_decodeMapResponse(response.body));
    }

    _throwForResponse(response, 'Failed to save attendance.');
  }

  Future<TrainingDocument> uploadTrainingFile(PlatformFile file) async {
    final token = await _getToken();
    late final Response<dynamic> response;
    try {
      response = await _dio.post(
        '/api/training-files/',
        data: FormData.fromMap({
          'file': await _multipartFromPlatformFile(file),
        }),
        options: Options(
          headers: {
            'Accept': 'application/json',
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (error) {
      _throwForDioException(error, 'Failed to upload training file.');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return TrainingDocument.fromJson(data);
      }
      if (data is Map) {
        return TrainingDocument.fromJson(Map<String, dynamic>.from(data));
      }
      return TrainingDocument(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fileName: file.name,
        category: 'Training File',
      );
    }

    throw const ApiException('Failed to upload training file.');
  }

  Future<List<TrainingDocument>> getTrainingFiles() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/training-files/'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return _decodeListResponse(response.body)
          .whereType<Map<String, dynamic>>()
          .map(TrainingDocument.fromJson)
          .toList();
    }

    _throwForResponse(response, 'Failed to load training files.');
  }

  Future<Intern> getInternProfile() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/intern/profile/'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return Intern.fromJson(_decodeMapResponse(response.body));
    }

    _throwForResponse(response, 'Failed to load intern profile.');
  }

  Future<List<SkillEvaluation>> getInternEvaluations() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/intern/evaluations/'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return _decodeListResponse(response.body)
          .whereType<Map<String, dynamic>>()
          .map(SkillEvaluation.fromJson)
          .toList();
    }

    _throwForResponse(response, 'Failed to load evaluations.');
  }

  Future<List<TimetableEntry>> getInternSchedule() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/intern/schedule/'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return _decodeListResponse(
        response.body,
      ).whereType<Map<String, dynamic>>().map(TimetableEntry.fromJson).toList();
    }

    _throwForResponse(response, 'Failed to load intern schedule.');
  }

  Future<List<TrainingDocument>> getInternTrainingFiles() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/intern/training-files/'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return _decodeListResponse(response.body)
          .whereType<Map<String, dynamic>>()
          .map(TrainingDocument.fromJson)
          .toList();
    }

    _throwForResponse(response, 'Failed to load intern training files.');
  }
}
