import 'dart:async';
import 'dart:convert';

import 'package:pro_link/models/app_user.dart';
import 'package:pro_link/models/department.dart';
import 'package:pro_link/models/intern.dart';
import 'package:pro_link/models/mentor_profile.dart';
import 'package:pro_link/models/training_document.dart';
import 'package:pro_link/services/fake_data.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:8000/api';

  String? _accessToken;
  String? _refreshToken;

  Map<String, String> get _jsonHeaders {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login/'),
      headers: _jsonHeaders,
      body: jsonEncode({'email': email.trim(), 'password': password}),
    );

    if (response.statusCode != 200) {
      throw Exception('Login failed. (${response.statusCode})');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    _accessToken = json['access'] as String?;
    _refreshToken = json['refresh'] as String?;

    final user = json['user'] as Map<String, dynamic>;
    final roleString = (user['role'] as String?) ?? 'intern';
    final role = switch (roleString) {
      'admin' => UserRole.admin,
      'mentor' => UserRole.mentor,
      _ => UserRole.intern,
    };

    return AppUser(
      name: (user['full_name'] as String?) ?? '',
      email: (user['email'] as String?) ?? email.trim(),
      department: '',
      role: role,
    );
  }

  Future<List<Intern>> getInterns() async {
    return fakeInterns;
  }

  Future<List<Department>> getDepartments() async {
    return fakeDepartments;
  }

  Future<List<MentorProfile>> getMentors() async {
    return fakeMentors;
  }

  Future<List<Intern>> getPendingRegistrations() async {
    return fakeInterns.where((intern) => intern.registrationPending).toList();
  }

  Future<List<TrainingDocument>> getTrainingDocuments() async {
    return fakeTrainingDocuments;
  }
}
