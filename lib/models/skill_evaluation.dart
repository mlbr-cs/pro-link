class SkillEvaluation {
  const SkillEvaluation({
    this.id,
    required this.title,
    required this.score,
    required this.feedback,
  });

  final String? id;
  final String title;
  final double score;
  final String feedback;

  factory SkillEvaluation.fromJson(Map<String, dynamic> json) {
    return SkillEvaluation(
      id: json['id']?.toString(),
      title: (json['title'] ?? json['skill'] ?? json['name'] ?? '').toString(),
      score: double.tryParse((json['score'] ?? json['mark'] ?? 0).toString()) ??
          0,
      feedback:
          (json['feedback'] ?? json['comment'] ?? json['description'] ?? '')
              .toString(),
    );
  }
}
