class PostModel {
  final String id;
  final String title;
  final String description;
  final String category; // documents, electronics, pets
  final String status; // lost | found
  final String imageUrl;
  final DateTime seenAt;
  final DateTime uploadedAt;
  final DateTime? reunitedAt;

  PostModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.imageUrl,
    required this.seenAt,
    required this.uploadedAt,
    this.reunitedAt,
  });
}
