class TrainingDocument {
  const TrainingDocument({
    required this.id,
    required this.fileName,
    required this.category,
    this.downloadUrl,
  });

  final String id;
  final String fileName;
  final String category;
  final String? downloadUrl;

  factory TrainingDocument.fromJson(Map<String, dynamic> json) {
    return TrainingDocument(
      id: (json['id'] ?? '').toString(),
      fileName: (json['file_name'] ?? json['name'] ?? json['file'] ?? '')
          .toString(),
      category: (json['category'] ?? json['type'] ?? 'Document').toString(),
      downloadUrl:
          json['download_url']?.toString() ?? json['file_url']?.toString(),
    );
  }
}
