class Department {
  const Department({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? json['title'] ?? '').toString(),
    );
  }
}
