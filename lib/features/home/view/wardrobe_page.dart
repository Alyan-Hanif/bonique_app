import 'package:bonique/features/home/viewmodel/home_viewmodel.dart';
import 'package:bonique/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:bonique/data/repositories/wardrobe_repository.dart';
import 'package:bonique/data/models/wardrobe_model.dart';
import 'package:bonique/core/widgets/loading_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

// State management for wardrobe filtering
final wardrobeFilterProvider = StateProvider<String>((ref) => 'All');

// Real wardrobe data provider that fetches from Supabase and preloads images
final wardrobeDataProvider = FutureProvider<List<WardrobeModel>>((ref) async {
  print('🔄 WARDROBE DATA PROVIDER CALLED');
  final authState = ref.watch(authViewModelProvider);

  print(
    '🔐 AUTH STATE: isLoggedIn=${authState.isLoggedIn}, currentUserModel=${authState.currentUserModel?.id}',
  );

  if (!authState.isLoggedIn || authState.currentUserModel == null) {
    print('❌ USER NOT LOGGED IN OR NO USER MODEL - RETURNING EMPTY LIST');
    return [];
  }

  try {
    print('📡 FETCHING WARDROBE ITEMS FROM SUPABASE...');
    final wardrobeItems = await WardrobeRepository.getWardrobeItems(
      authState.currentUserModel!.id,
    );
    print('📦 WARDROBE DATA LOADED: ${wardrobeItems.length} items');

    if (wardrobeItems.isNotEmpty) {
      print('📋 WARDROBE ITEMS DETAILS:');
      for (var item in wardrobeItems) {
        print(
          '   - ID: ${item.id}, Category: ${item.category}, Image: ${item.imagePath}',
        );
      }
    } else {
      print('⚠️ NO WARDROBE ITEMS RETURNED FROM REPOSITORY');
    }

    return wardrobeItems;
  } catch (e) {
    print('❌ ERROR FETCHING WARDROBE DATA: $e');
    print('❌ STACK TRACE: ${StackTrace.current}');
    return [];
  }
});

// Add this provider after the existing providers
final selectedWardrobeItemsProvider = StateProvider<Set<String>>(
  (ref) => <String>{},
);

class WardrobePage extends ConsumerStatefulWidget {
  const WardrobePage({super.key});

  @override
  ConsumerState<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends ConsumerState<WardrobePage> {
  bool _imagesPreloaded = false;
  List<WardrobeModel>? _lastWardrobeItems;

  @override
  void initState() {
    super.initState();
    print('🎬 WARDROBE PAGE INIT STATE');
  }

  Future<void> _preloadImages(List<WardrobeModel> wardrobeItems) async {
    try {
      print('🚀 STARTING _preloadImages() with ${wardrobeItems.length} items');

      if (wardrobeItems.isNotEmpty) {
        print('🖼️ PRELOADING ${wardrobeItems.length} images...');
        for (var item in wardrobeItems) {
          print(
            '   - Item ID: ${item.id}, Category: ${item.category}, Image: ${item.imagePath}',
          );
        }

        await Future.wait(
          wardrobeItems.map(
            (item) => precacheImage(NetworkImage(item.imagePath), context),
          ),
        );
        print('✅ ALL IMAGES PRELOADED');
      } else {
        print('⚠️ NO WARDROBE ITEMS FOUND - EMPTY LIST');
      }

      if (mounted) {
        print('🔄 SETTING STATE: _imagesPreloaded=true');
        setState(() {
          _imagesPreloaded = true;
        });
        print('✅ STATE UPDATED SUCCESSFULLY');
      } else {
        print('⚠️ WIDGET NOT MOUNTED - SKIPPING STATE UPDATE');
      }
    } catch (e) {
      print('❌ ERROR in _preloadImages: $e');
      print('❌ STACK TRACE: ${StackTrace.current}');
      if (mounted) {
        setState(() {
          _imagesPreloaded = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedFilter = ref.watch(wardrobeFilterProvider);
    final selectedItems = ref.watch(selectedWardrobeItemsProvider);
    final wardrobeAsyncValue = ref.watch(wardrobeDataProvider);

    print('🏗️ BUILD CALLED: _imagesPreloaded=$_imagesPreloaded');
    print('🏗️ SELECTED FILTER: $selectedFilter');

    // Always show the UI structure, handle loading/error states in the grid area
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom title bar - always visible
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Center(
                child: Text(
                  'My Wardrobe',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            // Filter bar - always visible
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: const [
                    _WardrobeFilter(label: 'All'),
                    SizedBox(width: 16),
                    _WardrobeFilter(label: 'Dresses'),
                    SizedBox(width: 16),
                    _WardrobeFilter(label: 'Jeans'),
                    SizedBox(width: 16),
                    _WardrobeFilter(label: 'Shirts'),
                    SizedBox(width: 16),
                    _WardrobeFilter(label: 'Skirts'),
                    SizedBox(width: 16),
                    _WardrobeFilter(label: 'Hoodies'),
                  ],
                ),
              ),
            ),
            // Wardrobe grid - handle all states here
            Expanded(
              child: wardrobeAsyncValue.when(
                data: (wardrobeItems) {
                  print(
                    '📦 WARDROBE DATA RECEIVED: ${wardrobeItems.length} items',
                  );

                  // Check if we have new data or need to start preloading
                  final hasNewData =
                      _lastWardrobeItems == null ||
                      _lastWardrobeItems!.length != wardrobeItems.length ||
                      !_imagesPreloaded;

                  if (hasNewData) {
                    print('🔄 NEW DATA DETECTED OR PRELOADING NEEDED');
                    _lastWardrobeItems = wardrobeItems;
                    _imagesPreloaded = false; // Reset preloading state
                    print('🚀 STARTING PRELOADING...');
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _preloadImages(wardrobeItems);
                    });
                  }

                  // Filter items based on selected category
                  final filteredItems = selectedFilter == 'All'
                      ? wardrobeItems
                      : wardrobeItems
                            .where((item) => item.category == selectedFilter)
                            .toList();

                  print('🔍 FILTERING RESULTS:');
                  print('   - Total items: ${wardrobeItems.length}');
                  print('   - Selected filter: $selectedFilter');
                  print('   - Filtered items: ${filteredItems.length}');

                  if (wardrobeItems.isNotEmpty) {
                    print('   - All categories in wardrobe:');
                    final categories = wardrobeItems
                        .map((item) => item.category)
                        .toSet();
                    for (var category in categories) {
                      final count = wardrobeItems
                          .where((item) => item.category == category)
                          .length;
                      print('     * $category: $count items');
                    }
                  }

                  // Show loading in grid area while preloading
                  if (!_imagesPreloaded) {
                    return const Center(
                      child: LoadingAnimation(
                        message: 'Loading your wardrobe...',
                        width: 150,
                        height: 150,
                      ),
                    );
                  }

                  // Show content after preloading
                  return AnimatedOpacity(
                    opacity: _imagesPreloaded ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: filteredItems.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.checkroom_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No items found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Add some items to your wardrobe!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio:
                                      121.3831787109375 /
                                      170.4719696044922, // Exact ratio from dimensions
                                ),
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              return _WardrobeTile(item: filteredItems[index]);
                            },
                          ),
                  );
                },
                loading: () => const Center(
                  child: LoadingAnimation(
                    message: 'Loading your wardrobe...',
                    width: 150,
                    height: 150,
                  ),
                ),
                error: (error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Error loading wardrobe',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.invalidate(wardrobeDataProvider);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                        ),
                        child: const Text(
                          'Retry',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: selectedItems.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                // Get the full wardrobe items data
                final wardrobeAsyncValue = ref.read(wardrobeDataProvider);
                wardrobeAsyncValue.whenData((wardrobeItems) {
                  // Filter to get only selected items
                  final selectedWardrobeItems = wardrobeItems
                      .where((item) => selectedItems.contains(item.id))
                      .toList();

                  // Store selected items for try-on page
                  ref.read(tryOnItemsProvider.notifier).state =
                      selectedWardrobeItems;

                  print(
                    '🎯 Selected ${selectedWardrobeItems.length} items for try-on',
                  );
                  for (var item in selectedWardrobeItems) {
                    print('   - ${item.category}: ${item.imagePath}');
                  }
                });

                // Navigate to try-on page using bottom navigation
                ref.read(bottomNavigationIndexProvider.notifier).state = 2;

                // Clear selection after action
                ref.read(selectedWardrobeItemsProvider.notifier).state =
                    <String>{};
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              label: Text(
                'Try On ',
                style: const TextStyle(color: Colors.white),
              ),
            )
          : null,
      bottomNavigationBar: const SizedBox(height: 0),
    );
  }
}

class _WardrobeFilter extends ConsumerWidget {
  final String label;

  const _WardrobeFilter({required this.label});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(wardrobeFilterProvider);
    final isSelected = selectedFilter == label;

    return GestureDetector(
      onTap: () {
        ref.read(wardrobeFilterProvider.notifier).state = label;
      },
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: SvgPicture.asset(
                _getSvgPathForLabel(label),
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  isSelected ? Colors.white : Colors.grey.shade700,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade700,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getSvgPathForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'all':
        return 'assets/images/wardrobe.svg';
      case 'dresses':
        return 'assets/images/dresses.svg';
      case 'jeans':
        return 'assets/images/Pants.svg';
      case 'shirts':
        return 'assets/images/TShirt.svg';
      case 'skirts':
        return 'assets/images/skirts.svg';
      case 'hoodies':
        return 'assets/images/hoodies.svg';
      default:
        return 'assets/images/wardrobe.svg';
    }
  }
}

class _WardrobeTile extends ConsumerWidget {
  final WardrobeModel item;

  const _WardrobeTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedItems = ref.watch(selectedWardrobeItemsProvider);
    final isSelected = selectedItems.contains(item.id);

    return GestureDetector(
      onTap: () {
        final currentSelected = ref.read(selectedWardrobeItemsProvider);
        final newSelected = Set<String>.from(currentSelected);

        if (isSelected) {
          newSelected.remove(item.id);
        } else {
          newSelected.add(item.id);
        }

        ref.read(selectedWardrobeItemsProvider.notifier).state = newSelected;
      },
      child: Container(
        width: 120,
        height: 170,
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(8.93),
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2.5,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.93),
              child: Image.network(
                item.imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(8.93),
                    ),
                    child: const Center(
                      child: Icon(Icons.image, color: Colors.grey, size: 40),
                    ),
                  );
                },
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
