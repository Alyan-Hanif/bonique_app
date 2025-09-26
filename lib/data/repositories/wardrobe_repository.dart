import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wardrobe_model.dart';
import '../../core/services/supabase_service.dart';

class WardrobeRepository {
  static const String _bucketName = 'wardrobe';
  static const String _tableName = 'wardrobe';

  // Upload image to Supabase storage
  static Future<String> uploadImage(File imageFile, String userId) async {
    try {
      print('Starting image upload for user: $userId');
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '$userId/$fileName';

      print('Uploading to path: $filePath');
      final bytes = await imageFile.readAsBytes();
      print('Image size: ${bytes.length} bytes');

      await SupabaseService.client.storage
          .from(_bucketName)
          .uploadBinary(filePath, bytes);

      // Get public URL
      final publicUrl = SupabaseService.client.storage
          .from(_bucketName)
          .getPublicUrl(filePath);

      print('Upload successful, public URL: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('Upload failed: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  // Save wardrobe item to database
  static Future<WardrobeModel> saveWardrobeItem({
    required String userId,
    required String imagePath,
    String? category,
    String? description,
  }) async {
    try {
      print('Saving wardrobe item to database');
      final response = await SupabaseService.client
          .from(_tableName)
          .insert({
            'user_id': userId,
            'image_path': imagePath,
            'category': category ?? 'Uncategorized',
            'description': description ?? '',
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      print('Database save successful: $response');
      return WardrobeModel.fromJson(response);
    } catch (e) {
      print('Database save failed: $e');
      throw Exception('Failed to save wardrobe item: $e');
    }
  }

  // Get wardrobe items for a user
  static Future<List<WardrobeModel>> getWardrobeItems(String userId) async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => WardrobeModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to get wardrobe items: $e');
    }
  }

  // Delete wardrobe item
  static Future<void> deleteWardrobeItem(String itemId) async {
    try {
      await SupabaseService.client.from(_tableName).delete().eq('id', itemId);
    } catch (e) {
      throw Exception('Failed to delete wardrobe item: $e');
    }
  }
}
