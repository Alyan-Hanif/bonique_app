import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/config/env_config.dart';
import '../models/wardrobe_model.dart';

class RecommendationsRepository {
  static String get _baseUrl => EnvConfig.boniqueAiUrl;

  /// Fetches product recommendations based on discovery answers
  /// [userId] - The user's ID
  /// [query] - Space-separated discovery answers (e.g., "summer dress work")
  /// [topK] - Number of top results to return (default 20, max 20)
  static Future<List<WardrobeModel>> fetchRecommendations({
    required String userId,
    required String query,
    int topK = 20,
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

        // Parse the recommendations
        if (jsonResponse.containsKey('recommendations')) {
          final List<dynamic> recommendationsJson =
              jsonResponse['recommendations'];
          print('📋 Recommendations count: ${recommendationsJson.length}');

          final recommendations = recommendationsJson.map((item) {
            return WardrobeModel.fromJson(item as Map<String, dynamic>);
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
          print('⚠️ No recommendations key found in response');
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
