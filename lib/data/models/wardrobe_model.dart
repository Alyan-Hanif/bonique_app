class WardrobeModel {
  final int id; // Changed from String to int
  final String userId;
  final String imagePath;
  final String? category;
  final String? description;
  final DateTime createdAt;

  WardrobeModel({
    required this.id,
    required this.userId,
    required this.imagePath,
    this.category,
    this.description,
    required this.createdAt,
  });

  factory WardrobeModel.fromJson(Map<String, dynamic> json) {
    return WardrobeModel(
      id: json['id'] as int, // Changed from String to int
      userId: json['user_id'] as String,
      imagePath: json['image_path'] as String,
      category: json['category'] as String?,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'image_path': imagePath,
      'category': category,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
