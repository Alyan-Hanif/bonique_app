import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/env_config.dart';
import '../models/wardrobe_model.dart';
import '../../core/services/supabase_service.dart';

class WardrobeRepository {
  static const String _bucketName = 'wardrobe';
  static const String _tableName = 'articles'; // Changed to articles table
  static String get _baseUrl => EnvConfig.boniqueAiUrl;

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

  // Call backend API with image and save the processed article to database
  static Future<WardrobeModel> processImageWithAPI(
    File imageFile,
    String userId,
  ) async {
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
        final jsonResponse = json.decode(response.body);
        print('✅ API processing successful!');
        print('📦 Full API Response: $jsonResponse');

        // Extract data from the response
        final data = jsonResponse['data'];
        final captionData = data['caption'];
        final imageUrl = data['image_url'] as String;

        print('📝 Caption Data: $captionData');
        print('🖼️ Image URL: $imageUrl');

        // Save article to database with AI-generated metadata
        final article = await saveWardrobeItem(
          userId: userId,
          imagePath: imageUrl,
          category: captionData['type_'] as String?,
          description: captionData['caption'] as String?,
          color: captionData['color'] as String?,
          fabric: captionData['fabric'] as String?,
          pattern: captionData['pattern'] as String?,
          style: captionData['style'] as String?,
          season: captionData['season'] as String?,
          occasion: captionData['occasion'] as String?,
        );

        print('✅ Article saved to database with AI metadata');
        return article;
      } else {
        print(
          '❌ API processing failed: ${response.statusCode} - ${response.body}',
        );
        throw Exception(
          'API processing failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to process image with API: $e');
    }
  }

  // Save wardrobe item to database (articles table)
  static Future<WardrobeModel> saveWardrobeItem({
    required String userId,
    required String imagePath,
    String? category,
    String? description,
    String? color,
    String? fabric,
    String? pattern,
    String? style,
    String? season,
    String? occasion,
  }) async {
    try {
      print('💾 Saving article to database...');
      final response = await SupabaseService.client
          .from(_tableName)
          .insert({
            'user_id': userId,
            'image_url': imagePath,
            'caption': description ?? '',
            'type_': category ?? 'Uncategorized',
            'color': color,
            'fabric': fabric,
            'pattern': pattern,
            'style': style,
            'season': season,
            'occasion': occasion,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      print('✅ Article saved successfully: $response');
      return WardrobeModel.fromJson(response);
    } catch (e) {
      print('❌ Database save failed: $e');
      throw Exception('Failed to save article: $e');
    }
  }

  // Get wardrobe items for a user from articles table
  static Future<List<WardrobeModel>> getWardrobeItems(String userId) async {
    try {
      print('📡 Fetching articles from database for user: $userId');
      final response = await SupabaseService.client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      print('✅ Fetched ${(response as List).length} articles');
      return (response as List)
          .map((item) => WardrobeModel.fromJson(item))
          .toList();
    } catch (e) {
      print('❌ Failed to get articles: $e');
      throw Exception('Failed to get wardrobe items: $e');
    }
  }

  // Delete wardrobe item from articles table
  static Future<void> deleteWardrobeItem(String itemId) async {
    try {
      print('🗑️ Deleting article: $itemId');
      await SupabaseService.client.from(_tableName).delete().eq('id', itemId);
      print('✅ Article deleted successfully');
    } catch (e) {
      print('❌ Failed to delete article: $e');
      throw Exception('Failed to delete wardrobe item: $e');
    }
  }

  // Try-on API call
  static Future<String> tryOnClothing({
    required String clothingPath,
    required String personPath,
  }) async {
    try {
      print('👗 Starting try-on API call...');
      print('👕 Clothing path: $clothingPath');
      print('👤 Person path: $personPath');

      // Build URL with query parameters as expected by the API
      final url = Uri.parse('$_baseUrl/images/try-on').replace(
        queryParameters: {
          'clothing_path': clothingPath,
          'person_path': personPath,
        },
      );
      print('🔗 API URL: $url');

      final response = await http.post(
        url,
        headers: {
          'accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      print('📡 Try-on API Response Status: ${response.statusCode}');
      print('📡 Try-on API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('✅ Try-on API call successful!');
        print('📦 Full API Response: $jsonResponse');

        // For now, just log the response and return a placeholder
        // TODO: Extract actual result image URL when API response structure is confirmed
        print(
          '🖼️ API Response received - structure: ${jsonResponse.runtimeType}',
        );
        print(
          '🖼️ Response keys: ${jsonResponse is Map ? jsonResponse.keys.toList() : 'Not a Map'}',
        );

        // Return a placeholder for now
        return 'https://via.placeholder.com/400x600/FF6B2C/FFFFFF?text=Try-On+Result';
      } else {
        print(
          '❌ Try-on API call failed: ${response.statusCode} - ${response.body}',
        );
        throw Exception(
          'Try-on API call failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Try-on API call error: $e');
      throw Exception('Failed to process try-on: $e');
    }
  }
}
