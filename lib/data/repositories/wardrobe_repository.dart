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

      // Add headers including API key
      request.headers.addAll({
        'ngrok-skip-browser-warning': 'true',
        'X-API-Key': EnvConfig.boniqueApiKey,
      });

      // Add the image file with proper filename and content type
      final filePath = imageFile.path;
      final originalFileName = filePath.split('/').last;

      // Ensure filename has proper extension for API detection
      String fileName = originalFileName;
      if (!fileName.contains('.')) {
        // If no extension, add .jpg as default
        fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      } else {
        // Sanitize filename by replacing spaces and special characters with underscores
        // Extract extension first
        final parts = fileName.split('.');
        final extension = parts.length > 1 ? '.${parts.last}' : '';
        final nameWithoutExt = parts.sublist(0, parts.length - 1).join('.');

        // Replace spaces and special characters with underscores
        final sanitizedName = nameWithoutExt
            .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')
            .replaceAll(
              RegExp(r'_+'),
              '_',
            ); // Replace multiple underscores with single

        fileName = '${sanitizedName}${extension}';
      }

      // Create multipart file - fromPath auto-detects content type from file
      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        filePath,
        filename: fileName,
      );

      request.files.add(multipartFile);

      print('📤 Sending to API...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📡 API Response Status: ${response.statusCode}');
      print('📡 API Response Body: ${response.body}');

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        print('✅ API processing successful!');
        print('📦 Full API Response: $jsonResponse');

        // Extract data from the response
        final data = jsonResponse['data'];
        final captionData = data['caption'];
        final imageUrl = data['image_url'] as String;

        print('📝 Caption Data: $captionData');
        print('🖼️ Image URL: $imageUrl');

        // TODO: COMMENTED OUT - AI backend already saves to database
        // This was causing duplicate entries in the articles table
        // Save article to database with AI-generated metadata
        // final article = await saveWardrobeItem(
        //   userId: userId,
        //   imagePath: imageUrl,
        //   category: captionData['type_'] as String?,
        //   description: captionData['caption'] as String?,
        //   color: captionData['color'] as String?,
        //   fabric: captionData['fabric'] as String?,
        //   pattern: captionData['pattern'] as String?,
        //   style: captionData['style'] as String?,
        //   season: captionData['season'] as String?,
        //   occasion: captionData['occasion'] as String?,
        // );

        // print('✅ Article saved to database with AI metadata');
        // return article;

        // Instead, return a WardrobeModel from the API response data
        print('✅ AI backend already saved article to database');
        return WardrobeModel(
          id: data['id'] ?? '', // Assuming backend returns the article ID
          userId: userId,
          imageUrl: imageUrl,
          type: captionData['type_'] as String? ?? 'Uncategorized',
          caption: captionData['caption'] as String? ?? '',
          color: captionData['color'] as String?,
          fabric: captionData['fabric'] as String?,
          pattern: captionData['pattern'] as String?,
          style: captionData['style'] as String?,
          season: captionData['season'] as String?,
          occasion: captionData['occasion'] as String?,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
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
            'color': color ?? 'Unknown', // Default color if not provided
            'fabric': fabric ?? 'Unknown', // Default fabric if not provided
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

  // Upload person image to Supabase storage
  static Future<String> uploadPersonImage(File imageFile, String userId) async {
    try {
      print('📤 Starting person image upload to Supabase for user: $userId');
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '$userId/$fileName';

      print('📁 Uploading to path: personImages/$filePath');
      final bytes = await imageFile.readAsBytes();
      print('📏 Image size: ${bytes.length} bytes');

      await SupabaseService.client.storage
          .from('personImages')
          .uploadBinary(filePath, bytes);

      // Get public URL
      final publicUrl = SupabaseService.client.storage
          .from('personImages')
          .getPublicUrl(filePath);

      print('✅ Person image upload successful! Public URL: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ Person image upload failed: $e');
      throw Exception('Failed to upload person image to Supabase: $e');
    }
  }

  // Try-on API call
  static Future<String> tryOnClothing({
    required String clothingPath,
    required String personPath,
  }) async {
    try {
      // --- Clean the clothing path ---
      String trimmedClothingPath = clothingPath
          .split('productimages/')
          .last
          .trim();
      if (trimmedClothingPath.endsWith('?')) {
        trimmedClothingPath = trimmedClothingPath.substring(
          0,
          trimmedClothingPath.length - 1,
        );
      }

      // --- Clean the person path ---
      String trimmedPersonPath = personPath.split('personImages/').last.trim();
      if (trimmedPersonPath.endsWith('?')) {
        trimmedPersonPath = trimmedPersonPath.substring(
          0,
          trimmedPersonPath.length - 1,
        );
      }

      // Extract user_id from person path (format: {user_id}/{image_name})
      final userId = trimmedPersonPath.split('/').first;

      print('👗 Starting try-on API call...');
      print('👕 Clothing path: $clothingPath → $trimmedClothingPath');
      print('👤 Person path: $personPath → $trimmedPersonPath');
      print('👤 User ID: $userId');

      // --- Build URL with parameters ---
      final url = Uri.parse('$_baseUrl/images/try-on').replace(
        queryParameters: {
          'clothing_path': trimmedClothingPath,
          'person_path': trimmedPersonPath,
          'user_id': userId,
        },
      );

      print('🔗 API URL: $url');

      // --- Send request ---
      final response = await http.post(
        url,
        headers: {
          'accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'X-API-Key': EnvConfig.boniqueApiKey,
        },
      );

      print('📡 Try-on API Response Status: ${response.statusCode}');
      print('📡 Try-on API Response Body: ${response.body}');

      // --- Handle successful response ---
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('✅ Try-on API call successful!');
        print('📦 Full API Response: $jsonResponse');

        // ✅ Extract the try-on image URL
        final data = jsonResponse['data'];
        String? tryOnImageUrl = data?['try_on_image_url'];

        // --- Clean up image URL if needed ---
        if (tryOnImageUrl != null) {
          tryOnImageUrl = tryOnImageUrl.split('?').first; // remove trailing '?'
          print('🖼️ Final Try-on Image URL: $tryOnImageUrl');
          return tryOnImageUrl;
        } else {
          print('⚠️ No try_on_image_url found in response.');
          return 'https://via.placeholder.com/400x600/FF6B2C/FFFFFF?text=No+Try-On+Image';
        }
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

  // Get try-on history for a user
  static Future<Map<String, dynamic>> getTryOnHistory(String userId) async {
    try {
      print('📜 Fetching try-on history for user: $userId');

      // --- Build URL with user_id parameter ---
      final url = Uri.parse(
        '$_baseUrl/images/try-on/history',
      ).replace(queryParameters: {'user_id': userId});

      print('🔗 API URL: $url');

      // --- Send request ---
      final response = await http.get(
        url,
        headers: {
          'accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'X-API-Key': EnvConfig.boniqueApiKey,
        },
      );

      print('📡 Try-on History API Response Status: ${response.statusCode}');
      print('📡 Try-on History API Response Body: ${response.body}');

      // --- Handle successful response ---
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('✅ Try-on history API call successful!');
        print('📦 Full API Response: $jsonResponse');
        return jsonResponse;
      } else {
        print(
          '❌ Try-on history API call failed: ${response.statusCode} - ${response.body}',
        );
        throw Exception(
          'Try-on history API call failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Try-on history API call error: $e');
      throw Exception('Failed to fetch try-on history: $e');
    }
  }
}
