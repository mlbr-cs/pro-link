enum UserRole { admin, mentor, intern }

class AppUser {
  const AppUser({
    required this.name,
    required this.email,
    required this.department,
    required this.role,
  });

  final String name;
  final String email;
  final String department;
  final UserRole role;

  String get roleLabel {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.mentor:
        return 'Mentor';
      case UserRole.intern:
        return 'Intern';
    }
  }
}
