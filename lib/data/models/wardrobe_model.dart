class WardrobeModel {
  final String id; // uuid from articles table
  final String userId;
  final String imageUrl; // Changed from imagePath to imageUrl
  final String? caption;
  final String? type;
  final String? color;
  final String? fabric;
  final String? pattern;
  final String? style;
  final String? season;
  final String? occasion;
  final DateTime createdAt;
  final DateTime? updatedAt;

  WardrobeModel({
    required this.id,
    required this.userId,
    required this.imageUrl,
    this.caption,
    this.type,
    this.color,
    this.fabric,
    this.pattern,
    this.style,
    this.season,
    this.occasion,
    required this.createdAt,
    this.updatedAt,
  });

  factory WardrobeModel.fromJson(Map<String, dynamic> json) {
    return WardrobeModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      imageUrl: json['image_url'] as String,
      caption: json['caption'] as String?,
      type: json['type_'] as String?,
      color: json['color'] as String?,
      fabric: json['fabric'] as String?,
      pattern: json['pattern'] as String?,
      style: json['style'] as String?,
      season: json['season'] as String?,
      occasion: json['occasion'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'image_url': imageUrl,
      'caption': caption,
      'type_': type,
      'color': color,
      'fabric': fabric,
      'pattern': pattern,
      'style': style,
      'season': season,
      'occasion': occasion,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Helper getter for backward compatibility with old code using imagePath
  String get imagePath => imageUrl;

  // Helper getter for backward compatibility with old code using category
  String? get category => type;

  // Helper getter for backward compatibility with old code using description
  String? get description => caption;
}
