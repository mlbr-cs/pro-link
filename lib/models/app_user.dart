enum UserRole { admin, mentor, intern }

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.role,
    this.photoUrl,
  });

  final String id;
  final String name;
  final String email;
  final String department;
  final UserRole role;
  final String? photoUrl;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: (json['id'] ?? '').toString(),
      name: (json['full_name'] ?? json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      department: (json['department'] ?? '').toString(),
      role: _roleFromString((json['role'] ?? '').toString()),
      photoUrl: json['photo']?.toString(),
    );
  }

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

UserRole _roleFromString(String role) {
  switch (role.toLowerCase()) {
    case 'admin':
      return UserRole.admin;
    case 'mentor':
      return UserRole.mentor;
    default:
      return UserRole.intern;
  }
}
