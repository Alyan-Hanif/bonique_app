import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';
import '../models/user_model.dart';

class UserRepository {
  final SupabaseClient _client = SupabaseService.client;
  static const String _tableName = 'users';

  // Create a new user in the users table
  Future<UserModel> createUser(UserModel user) async {
    try {
      final response = await _client
          .from(_tableName)
          .insert(user.toJson())
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return UserModel.fromJson(response);
    } catch (e) {
      print('Error getting user by ID: $e');
      rethrow;
    }
  }

  // Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('email', email)
          .maybeSingle();

      if (response == null) return null;
      return UserModel.fromJson(response);
    } catch (e) {
      print('Error getting user by email: $e');
      rethrow;
    }
  }

  // Update user data
  Future<UserModel> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      // Add updated_at timestamp
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from(_tableName)
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _client
          .from(_tableName)
          .delete()
          .eq('id', userId);
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

  // Check if user exists
  Future<bool> userExists(String userId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking if user exists: $e');
      return false;
    }
  }

  // Create or update user (upsert)
  Future<UserModel> upsertUser(UserModel user) async {
    try {
      final response = await _client
          .from(_tableName)
          .upsert(user.toJson())
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error upserting user: $e');
      rethrow;
    }
  }

  // Get all users (admin function)
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting all users: $e');
      rethrow;
    }
  }
}
