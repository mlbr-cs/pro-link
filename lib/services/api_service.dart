import 'dart:async';

import 'package:pro_link/models/app_user.dart';
import 'package:pro_link/models/department.dart';
import 'package:pro_link/models/intern.dart';
import 'package:pro_link/models/mentor_profile.dart';
import 'package:pro_link/models/training_document.dart';
import 'package:pro_link/services/fake_data.dart';

class ApiService {
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty || password.trim().isEmpty) {
      throw Exception('Email and password are required.');
    }

    if (normalizedEmail.contains('admin')) {
      return const AppUser(
        name: 'Jon Khaled',
        email: 'admin@prolink.edu',
        department: 'Career Services',
        role: UserRole.admin,
      );
    }

    if (normalizedEmail.contains('mentor')) {
      return const AppUser(
        name: 'Lucas Abdo',
        email: 'mentor@prolink.edu',
        department: 'Engineering',
        role: UserRole.mentor,
      );
    }

    return AppUser(
      name: 'Mohamed Lamine',
      email: normalizedEmail,
      department: 'Engineering',
      role: UserRole.intern,
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
