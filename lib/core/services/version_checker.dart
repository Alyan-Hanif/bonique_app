import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'supabase_service.dart';

/// Service to check app version and handle logout on install/update
class VersionChecker {
  static const String _versionKey = 'last_app_version';
  static const String _buildNumberKey = 'last_build_number';

  /// Check if app version has changed and logout if needed
  /// Returns true if version changed (logout was performed)
  static Future<bool> checkVersionAndLogout() async {
    try {
      debugPrint('🔍 Checking app version...');

      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final currentBuildNumber = packageInfo.buildNumber;

      debugPrint('📱 Current version: $currentVersion+$currentBuildNumber');

      // Get stored version from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final storedVersion = prefs.getString(_versionKey);
      final storedBuildNumber = prefs.getString(_buildNumberKey);

      debugPrint('💾 Stored version: $storedVersion+$storedBuildNumber');

      // Check if this is a fresh install or an update
      final bool isVersionChanged =
          storedVersion != currentVersion ||
          storedBuildNumber != currentBuildNumber;

      if (isVersionChanged) {
        if (storedVersion == null) {
          debugPrint('🆕 Fresh install detected - logging out...');
        } else {
          debugPrint(
            '🔄 Version changed from $storedVersion+$storedBuildNumber to $currentVersion+$currentBuildNumber - logging out...',
          );
        }

        // Perform logout
        await _performLogout();

        // Store the new version
        await prefs.setString(_versionKey, currentVersion);
        await prefs.setString(_buildNumberKey, currentBuildNumber);

        debugPrint('✅ Version updated and user logged out');
        return true;
      } else {
        debugPrint('✅ Version unchanged - no logout needed');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error checking version: $e');
      // Don't throw error, just continue
      return false;
    }
  }

  /// Perform logout silently
  static Future<void> _performLogout() async {
    try {
      // Sign out from Supabase
      await SupabaseService.client.auth.signOut();
      debugPrint('🚪 User logged out successfully');
    } catch (e) {
      debugPrint('❌ Error during logout: $e');
      // Continue anyway - this is a safety measure
    }
  }

  /// Get current app version info
  static Future<Map<String, String>> getVersionInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return {
        'version': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
        'appName': packageInfo.appName,
        'packageName': packageInfo.packageName,
      };
    } catch (e) {
      debugPrint('❌ Error getting version info: $e');
      return {};
    }
  }

  /// Clear stored version (for testing purposes)
  static Future<void> clearStoredVersion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_versionKey);
      await prefs.remove(_buildNumberKey);
      debugPrint('🗑️ Stored version cleared');
    } catch (e) {
      debugPrint('❌ Error clearing stored version: $e');
    }
  }
}
