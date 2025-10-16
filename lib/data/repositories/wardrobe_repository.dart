import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/wardrobe_model.dart';
import '../../core/services/supabase_service.dart';

class WardrobeRepository {
  static const String _bucketName = 'wardrobe';
  static const String _tableName = 'wardrobe';
  static const String _baseUrl = 'https://9ef0f3990b51.ngrok-free.app';

  // Upload image to Supabase storage
  static Future<String> uploadImage(File imageFile, String userId) async {
    try {
      print('📤 Starting image upload to Supabase for user: $userId');
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '$userId/$fileName';

      print('📁 Uploading to path: $filePath');
      final bytes = await imageFile.readAsBytes();
      print('📏 Image size: ${bytes.length} bytes');

      await SupabaseService.client.storage
          .from(_bucketName)
          .uploadBinary(filePath, bytes);

      // Get public URL
      final publicUrl = SupabaseService.client.storage
          .from(_bucketName)
          .getPublicUrl(filePath);

      print('✅ Supabase upload successful! Public URL: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ Supabase upload failed: $e');
      throw Exception('Failed to upload image to Supabase: $e');
    }
  }

  // Call backend API with image (additional processing)
  static Future<void> processImageWithAPI(File imageFile, String userId) async {
    try {
      print('🌐 Sending image to backend API for processing...');
      print('👤 User ID: $userId');
      print('📁 Image path: ${imageFile.path}');

      // Build URL with user_id query parameter
      final url = Uri.parse(
        '$_baseUrl/images/upload',
      ).replace(queryParameters: {'user_id': userId});
      print('🔗 API URL: $url');

      // Create multipart request
      final request = http.MultipartRequest('POST', url);

      // Add headers
      request.headers.addAll({'ngrok-skip-browser-warning': 'true'});

      // Add the image file
      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      );
      request.files.add(multipartFile);

      print('📤 Sending to API...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📡 API Response Status: ${response.statusCode}');
      print('📡 API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ API processing successful!');
      } else {
        print(
          '⚠️ API processing failed: ${response.statusCode} - ${response.body}',
        );
        // Don't throw error - we still want to save to database even if API fails
      }
    } catch (e) {
      print('⚠️ API processing error: $e');
      // Don't throw error - we still want to save to database even if API fails
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
