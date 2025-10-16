import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/services/supabase_service.dart';
import '../models/discovery_question_model.dart';

class DiscoveryRepository {
  // API endpoint
  static const String _baseUrl = 'https://9ef0f3990b51.ngrok-free.app';
  static const String _questionsEndpoint = '/wardrobe/questions';

  /// Fetches discovery questions from the API
  /// Gets the user ID from Supabase auth automatically
  Future<DiscoveryQuestionsResponse> fetchDiscoveryQuestions() async {
    try {
      // Get current user from Supabase
      final user = SupabaseService.client.auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Build the URL with user_id as query parameter
      final uri = Uri.parse(
        '$_baseUrl$_questionsEndpoint',
      ).replace(queryParameters: {'user_id': user.id});

      print('🌐 Fetching discovery questions for user: ${user.id}');
      print('📡 API URL: $uri');

      // Make the HTTP GET request
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true', // Required for ngrok-free.app
        },
      );

      print('📥 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return DiscoveryQuestionsResponse.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to load questions: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error in fetchDiscoveryQuestions: $e');
      throw Exception('Failed to fetch discovery questions: $e');
    }
  }
}
