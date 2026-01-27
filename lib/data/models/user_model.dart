import 'package:supabase_flutter/supabase_flutter.dart';

class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final bool hasUploadedBodyPic;
  final String? bodyPicUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.hasUploadedBodyPic = false,
    this.bodyPicUrl,
    this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  // Factory constructor to create UserModel from Supabase User
  factory UserModel.fromSupabaseUser(User user) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'] as String?,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
      hasUploadedBodyPic:
          user.userMetadata?['has_uploaded_body_pic'] as bool? ?? false,
      bodyPicUrl: user.userMetadata?['body_pic_url'] as String?,
      createdAt: DateTime.tryParse(user.createdAt),
      updatedAt: user.updatedAt != null
          ? DateTime.tryParse(user.updatedAt!)
          : null,
      metadata: user.userMetadata,
    );
  }

  // Factory constructor to create UserModel from database row
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      hasUploadedBodyPic: json['has_uploaded_body_pic'] as bool? ?? false,
      bodyPicUrl: json['body_pic_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  // Convert UserModel to JSON for database insertion
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'has_uploaded_body_pic': hasUploadedBodyPic,
      'body_pic_url': bodyPicUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  // Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    bool? hasUploadedBodyPic,
    String? bodyPicUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      hasUploadedBodyPic: hasUploadedBodyPic ?? this.hasUploadedBodyPic,
      bodyPicUrl: bodyPicUrl ?? this.bodyPicUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullName: $fullName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
