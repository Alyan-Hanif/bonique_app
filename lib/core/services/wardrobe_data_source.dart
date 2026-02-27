import '../../data/models/wardrobe_model.dart';
import '../../data/repositories/wardrobe_repository.dart';
import '../utils/connectivity_utils.dart';
import 'wardrobe_cache_service.dart';

/// Result of loading wardrobe: list of items and whether they came from cache (offline).
class WardrobeDataResult {
  const WardrobeDataResult({required this.items, required this.fromCache});
  final List<WardrobeModel> items;
  final bool fromCache;
}

/// Offline-first data source for wardrobe items:
/// - If online: fetch from API (Supabase), save to Hive, return API data.
/// - If offline: load from Hive and return cached data.
class WardrobeDataSource {
  /// Get wardrobe items: check internet → fetch & cache or load from cache.
  /// [fromCache] is true when data was loaded from Hive (offline or API fallback).
  static Future<WardrobeDataResult> getWardrobeItems(String userId) async {
    final isOnline = await ConnectivityUtils.hasInternetConnection();

    if (isOnline) {
      try {
        print('🌐 Online: fetching wardrobe from API...');
        final items = await WardrobeRepository.getWardrobeItems(userId);
        await WardrobeCacheService.save(userId, items);
        print('✅ API data fetched and cached: ${items.length} items');
        return WardrobeDataResult(items: items, fromCache: false);
      } catch (e) {
        print('⚠️ API fetch failed, falling back to cache: $e');
        final cached = WardrobeCacheService.load(userId);
        if (cached.isNotEmpty) {
          print('📦 Showing ${cached.length} cached items');
          return WardrobeDataResult(items: cached, fromCache: true);
        }
        rethrow;
      }
    } else {
      print('📵 Offline: loading wardrobe from Hive cache...');
      final cached = WardrobeCacheService.load(userId);
      print(
        cached.isEmpty
            ? '📦 No cached wardrobe for user'
            : '📦 Loaded ${cached.length} cached items',
      );
      return WardrobeDataResult(items: cached, fromCache: true);
    }
  }
}
