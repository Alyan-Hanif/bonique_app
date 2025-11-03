import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/config/env_config.dart';
import '../models/wardrobe_model.dart';

class RecommendationsRepository {
  static String get _baseUrl => EnvConfig.boniqueAiUrl;

  /// Fetches product recommendations based on discovery answers
  /// [userId] - The user's ID
  /// [query] - Space-separated discovery answers (e.g., "summer dress work")
  /// [topK] - Number of top results to return (default 5, max 5)
  static Future<List<WardrobeModel>> fetchRecommendations({
    required String userId,
    required String query,
    int topK = 5,
  }) async {
    print('🌐 FETCHING RECOMMENDATIONS FROM API');
    print('👤 User ID: $userId');
    print('📝 Query: $query');
    print('🔢 Top K: $topK');

    try {
      // Build URL with query parameters (note: correct endpoint is 'recommendations' not 'recomendations')
      final url = Uri.parse('$_baseUrl/wardrobe/recommendations').replace(
        queryParameters: {
          'user_id': userId,
          'query': query,
          'top_k': topK.toString(),
        },
      );
      print('🔗 Full API URL with params: $url');
      print('🔗 Query Parameters: user_id=$userId, query=$query, top_k=$topK');

      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'ngrok-skip-browser-warning': 'true',
              'User-Agent': 'Bonique-Flutter-App',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              print('⏱️ REQUEST TIMED OUT AFTER 30 SECONDS');
              throw Exception(
                'Request timeout - server took too long to respond',
              );
            },
          );

      print('📡 API Response Status: ${response.statusCode}');
      print('📡 API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('✅ API Response parsed successfully');
        print('📦 Full Response: $jsonResponse');

        // Parse the recommendations from 'data' key
        if (jsonResponse.containsKey('data')) {
          final List<dynamic> recommendationsJson = jsonResponse['data'];
          print('📋 Recommendations count: ${recommendationsJson.length}');

          final recommendations = recommendationsJson.asMap().entries.map((
            entry,
          ) {
            final index = entry.key;
            final item = entry.value as Map<String, dynamic>;

            // Transform API response to match WardrobeModel structure
            final transformedItem = {
              'id':
                  'rec_${DateTime.now().millisecondsSinceEpoch}_$index', // Generate temporary ID
              'user_id': item['user_id'] ?? userId,
              'image_url': item['image_url'] as String,
              'caption': item['content'] as String?,
              'type_':
                  item['type']
                      as String?, // Note: WardrobeModel expects 'type_'
              'color': item['color'] as String?,
              'fabric': item['fabric'] as String?,
              'pattern': item['pattern'] as String?,
              'style': item['style'] as String?,
              'season': item['season'] as String?,
              'occasion': item['occasion'] as String?,
              'created_at': DateTime.now()
                  .toIso8601String(), // Use current time
              'updated_at': null,
            };

            return WardrobeModel.fromJson(transformedItem);
          }).toList();

          print(
            '✅ Successfully parsed ${recommendations.length} recommendations',
          );
          for (var item in recommendations) {
            print(
              '   - ID: ${item.id}, Category: ${item.category}, Image: ${item.imagePath}',
            );
          }

          return recommendations;
        } else {
          print('⚠️ No data key found in response');
          return [];
        }
      } else {
        print('❌ API Error: ${response.statusCode} - ${response.body}');
        throw Exception(
          'Failed to fetch recommendations: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ ERROR FETCHING RECOMMENDATIONS: $e');
      print('❌ STACK TRACE: ${StackTrace.current}');
      rethrow;
    }
  }
}
