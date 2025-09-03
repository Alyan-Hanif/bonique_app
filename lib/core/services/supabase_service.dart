import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> init() async {
    await Supabase.initialize(
      url: "https://YOUR_PROJECT.supabase.co", // from Supabase dashboard
      anonKey: "YOUR_PUBLIC_ANON_KEY", // from Supabase dashboard
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
