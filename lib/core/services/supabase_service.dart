import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> init() async {
    try {
      await Supabase.initialize(
        url:
            "https://yrrdneithyzxwzrzphbf.supabase.co", // from Supabase dashboard
        anonKey:
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlycmRuZWl0aHl6eHd6cnpwaGJmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0NjA2MTcsImV4cCI6MjA3MDAzNjYxN30.MvDf-WpE-qOusYNV8opEFb__76GvuNydw7xpXxc9StI", // from Supabase dashboard
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
      final response = await client
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
