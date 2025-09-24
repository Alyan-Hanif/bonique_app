import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env_config.dart';

class SupabaseService {
  static Future<void> init() async {
    try {
      await Supabase.initialize(
        url: EnvConfig.supabaseUrl,
        anonKey: EnvConfig.supabaseAnonKey,
      );
      print('Supabase initialized successfully');
    } catch (e) {
      print('Supabase initialization error: $e');
      rethrow;
    }
  }

  static SupabaseClient get client => Supabase.instance.client;

  // Test method to verify connection
  static Future<bool> testConnection() async {
    try {
      await client
          .from('_test_connection')
          .select('*')
          .limit(1);
      return true;
    } catch (e) {
      print('Supabase connection test failed: $e');
      return false;
    }
  }
}
