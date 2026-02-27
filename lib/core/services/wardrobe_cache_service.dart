import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/wardrobe_model.dart';

/// Local cache for wardrobe items per user. Used when offline.
class WardrobeCacheService {
  static const String _boxName = 'wardrobe_cache';
  static const String _keyPrefix = 'wardrobe_';

  static Box<dynamic>? _box;

  /// Initialize Hive box for wardrobe cache. Call once at app startup after Hive.initFlutter().
  static Future<void> init() async {
    if (_box != null && _box!.isOpen) return;
    _box = await Hive.openBox(_boxName);
  }

  static String _key(String userId) => '$_keyPrefix$userId';

  /// Save wardrobe items for a user (e.g. after fetching from API).
  static Future<void> save(String userId, List<WardrobeModel> items) async {
    final box = _box;
    if (box == null || !box.isOpen) return;
    final list = items.map((e) => e.toJson()).toList();
    await box.put(_key(userId), list);
    print('💾 Wardrobe cache saved: ${items.length} items for user $userId');
  }

  /// Load cached wardrobe items for a user. Returns empty list if none or error.
  static List<WardrobeModel> load(String userId) {
    final box = _box;
    if (box == null || !box.isOpen) return [];
    try {
      final raw = box.get(_key(userId));
      if (raw == null) return [];
      final list = raw as List<dynamic>;
      return list
          .map(
            (e) => WardrobeModel.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    } catch (e) {
      print('❌ Wardrobe cache load error: $e');
      return [];
    }
  }

  /// Clear cache for a user (e.g. on logout).
  static Future<void> clear(String userId) async {
    final box = _box;
    if (box == null || !box.isOpen) return;
    await box.delete(_key(userId));
  }
}
