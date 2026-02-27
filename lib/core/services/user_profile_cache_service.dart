import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/user_model.dart';

/// Caches the current user profile so we can stay "logged in" when offline.
/// Written when we fetch user from API; read when API fails (e.g. network error).
class UserProfileCacheService {
  static const String _boxName = 'user_profile_cache';
  static const String _keyPrefix = 'user_';

  static Box<dynamic>? _box;

  /// Call once at app startup after Hive.initFlutter().
  static Future<void> init() async {
    if (_box != null && _box!.isOpen) return;
    _box = await Hive.openBox(_boxName);
  }

  static String _key(String userId) => '$_keyPrefix$userId';

  static Box<dynamic>? get _boxOrNull {
    final b = _box;
    if (b == null || !b.isOpen) return null;
    return b;
  }

  /// Save user profile (call after successfully fetching from API).
  static Future<void> save(UserModel user) async {
    final box = _boxOrNull;
    if (box == null) return;
    await box.put(_key(user.id), user.toJson());
  }

  /// Load cached profile for [userId]. Returns null if not found or error.
  static UserModel? load(String userId) {
    final box = _boxOrNull;
    if (box == null) return null;
    try {
      final raw = box.get(_key(userId));
      if (raw == null) return null;
      return UserModel.fromJson(Map<String, dynamic>.from(raw as Map));
    } catch (e) {
      return null;
    }
  }

  /// Clear cache for a user (e.g. on sign out).
  static Future<void> clear(String userId) async {
    final box = _boxOrNull;
    if (box == null) return;
    await box.delete(_key(userId));
  }
}
