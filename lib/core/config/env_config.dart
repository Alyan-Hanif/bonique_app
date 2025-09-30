import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static Future<void> init() async {
    await dotenv.load(fileName: ".env");
  }

  // Supabase Configuration
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // Google Services Configuration
  static String get googleProjectId => dotenv.env['GOOGLE_PROJECT_ID'] ?? '';
  static String get googleProjectNumber =>
      dotenv.env['GOOGLE_PROJECT_NUMBER'] ?? '';
  static String get googleApiKey => dotenv.env['GOOGLE_API_KEY'] ?? '';
  static String get googleOAuthClientId =>
      dotenv.env['GOOGLE_OAUTH_CLIENT_ID'] ?? '';

  // App Configuration
  static String get appPackageName => dotenv.env['APP_PACKAGE_NAME'] ?? '';
  static String get appName => dotenv.env['APP_NAME'] ?? '';

  // Validation method to ensure all required environment variables are set
  static bool validateConfig() {
    final requiredVars = [
      supabaseUrl,
      supabaseAnonKey,
      googleProjectId,
      googleProjectNumber,
      googleApiKey,
      googleOAuthClientId,
      appPackageName,
      appName,
    ];

    for (final variable in requiredVars) {
      if (variable.isEmpty) {
        return false;
      }
    }
    return true;
  }
}
