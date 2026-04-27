class MentorProfile {
  const MentorProfile({
    required this.id,
    required this.name,
    required this.department,
    required this.email,
  });

  final String id;
  final String name;
  final String department;
  final String email;

  factory MentorProfile.fromJson(Map<String, dynamic> json) {
    final departmentValue = json['department'];
    return MentorProfile(
      id: (json['id'] ?? '').toString(),
      name: (json['full_name'] ?? json['name'] ?? '').toString(),
      department: departmentValue is Map<String, dynamic>
          ? (departmentValue['name'] ?? '').toString()
          : (departmentValue ?? '').toString(),
      email: (json['email'] ?? '').toString(),
    );
  }
}
