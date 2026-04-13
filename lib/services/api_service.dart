import 'dart:async';

import 'package:pro_link/models/app_user.dart';

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
        name: 'Nadia Rahal',
        email: 'admin@prolink.edu',
        department: 'Career Services',
        role: UserRole.admin,
      );
    }

    if (normalizedEmail.contains('mentor')) {
      return const AppUser(
        name: 'Karim Benali',
        email: 'mentor@prolink.edu',
        department: 'Industry Partnerships',
        role: UserRole.mentor,
      );
    }

    return AppUser(
      name: 'Lina Boussaid',
      email: normalizedEmail,
      department: 'Software Engineering',
      role: UserRole.intern,
    );
  }
}
