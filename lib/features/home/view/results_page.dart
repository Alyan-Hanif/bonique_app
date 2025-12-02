import 'package:bonique/features/home/viewmodel/home_viewmodel.dart';
import 'package:bonique/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:bonique/data/models/wardrobe_model.dart';
import 'package:bonique/data/repositories/recommendations_repository.dart';
import 'package:bonique/core/widgets/loading_animation.dart';
import 'package:bonique/core/utils/clothing_category_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:photo_view/photo_view.dart';

// Provider to store discovery answers
final discoveryAnswersProvider = StateProvider<String>((ref) => '');

// State management for results filtering
final resultsFilterProvider = StateProvider<String>((ref) => 'All');

// Results data provider that fetches recommendations from API
final resultsDataProvider = FutureProvider<List<WardrobeModel>>((ref) async {
  print('🔄 RESULTS DATA PROVIDER CALLED');

  // Get auth state to retrieve user ID
  final authState = ref.watch(authViewModelProvider);
  print(
    '🔐 AUTH STATE: isLoggedIn=${authState.isLoggedIn}, currentUserModel=${authState.currentUserModel?.id}',
  );

  if (!authState.isLoggedIn || authState.currentUserModel == null) {
    print('❌ USER NOT LOGGED IN OR NO USER MODEL - RETURNING EMPTY LIST');
    return [];
  }

  // Get discovery answers
  final discoveryAnswers = ref.watch(discoveryAnswersProvider);
  print('📝 Discovery Answers from Provider: "$discoveryAnswers"');

  // If no answers, return empty list
  if (discoveryAnswers.isEmpty) {
    print('⚠️ NO DISCOVERY ANSWERS - RETURNING EMPTY LIST');
    return [];
  }

  try {
    // Fetch recommendations from API using repository
    final recommendations =
        await RecommendationsRepository.fetchRecommendations(
          userId: authState.currentUserModel!.id,
          query: discoveryAnswers,
        );

    return recommendations;
  } catch (e) {
    print('❌ ERROR IN RESULTS DATA PROVIDER: $e');
    // Return empty list on error instead of throwing
    return [];
  }
});

// Provider for single item selection (changed from Set to single String)
final selectedResultItemProvider = StateProvider<String?>((ref) => null);

class ResultsPage extends ConsumerStatefulWidget {
  const ResultsPage({super.key});

  @override
  ConsumerState<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends ConsumerState<ResultsPage> {
  bool _imagesPreloaded = false;
  List<WardrobeModel>? _lastResultsItems;

  @override
  void initState() {
    super.initState();
    print('🎬 RESULTS PAGE INIT STATE');
  }

  Future<void> _preloadImages(List<WardrobeModel> resultsItems) async {
    try {
      print('🚀 STARTING _preloadImages() with ${resultsItems.length} items');

      if (resultsItems.isNotEmpty) {
        print('🖼️ PRELOADING ${resultsItems.length} images...');
        for (var item in resultsItems) {
          print(
            '   - Item ID: ${item.id}, Category: ${item.category}, Image: ${item.imagePath}',
          );
        }

        await Future.wait(
          resultsItems.map(
            (item) => precacheImage(NetworkImage(item.imagePath), context),
          ),
        );
        print('✅ ALL IMAGES PRELOADED');
      } else {
        print('⚠️ NO RESULTS ITEMS FOUND - EMPTY LIST');
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
    final selectedFilter = ref.watch(resultsFilterProvider);
    final selectedItemId = ref.watch(selectedResultItemProvider);
    final resultsAsyncValue = ref.watch(resultsDataProvider);

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
                  'Results',
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
                    _ResultsFilter(label: 'All'),
                    SizedBox(width: 16),
                    _ResultsFilter(label: 'Dresses'),
                    SizedBox(width: 16),
                    _ResultsFilter(label: 'Jeans'),
                    SizedBox(width: 16),
                    _ResultsFilter(label: 'Shirts'),
                    SizedBox(width: 16),
                    _ResultsFilter(label: 'Skirts'),
                    SizedBox(width: 16),
                    _ResultsFilter(label: 'Hoodies'),
                  ],
                ),
              ),
            ),
            // Results grid - handle all states here
            Expanded(
              child: resultsAsyncValue.when(
                data: (resultsItems) {
                  print(
                    '📦 RESULTS DATA RECEIVED: ${resultsItems.length} items',
                  );

                  // Check if we have new data or need to start preloading
                  final hasNewData =
                      _lastResultsItems == null ||
                      _lastResultsItems!.length != resultsItems.length ||
                      !_imagesPreloaded;

                  if (hasNewData) {
                    print('🔄 NEW DATA DETECTED OR PRELOADING NEEDED');
                    _lastResultsItems = resultsItems;
                    _imagesPreloaded = false; // Reset preloading state
                    print('🚀 STARTING PRELOADING...');
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _preloadImages(resultsItems);
                    });
                  }

                  // Filter items based on selected category using the category mapper
                  final filteredItems = resultsItems
                      .where(
                        (item) => ClothingCategoryMapper.belongsToCategory(
                          item.type,
                          selectedFilter,
                        ),
                      )
                      .toList();

                  print('🔍 FILTERING RESULTS:');
                  print('   - Total items: ${resultsItems.length}');
                  print('   - Selected filter: $selectedFilter');
                  print('   - Filtered items: ${filteredItems.length}');

                  if (resultsItems.isNotEmpty) {
                    print('   - AI types mapped to categories:');
                    for (var item in resultsItems) {
                      final mappedCategory =
                          ClothingCategoryMapper.mapToCategory(item.type);
                      print(
                        '     * AI: "${item.type}" → Mapped: "${mappedCategory ?? "Uncategorized"}"',
                      );
                    }

                    print('   - Category distribution:');
                    final categoryGroups = <String, int>{};
                    for (var item in resultsItems) {
                      final mapped =
                          ClothingCategoryMapper.mapToCategory(item.type) ??
                          'Uncategorized';
                      categoryGroups[mapped] =
                          (categoryGroups[mapped] ?? 0) + 1;
                    }
                    categoryGroups.forEach((category, count) {
                      print('     * $category: $count items');
                    });
                  }

                  // Show loading in grid area while preloading
                  if (!_imagesPreloaded) {
                    return const Center(
                      child: LoadingAnimation(
                        message: 'Loading your results...',
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
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No results found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Try adjusting your search criteria!',
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
                                      170.4719696044922, // Exact ratio from wardrobe page
                                ),
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              return _ResultTile(item: filteredItems[index]);
                            },
                          ),
                  );
                },
                loading: () => const Center(
                  child: LoadingAnimation(
                    message: 'Loading your results...',
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
                        'Error loading results',
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
                          ref.invalidate(resultsDataProvider);
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
      floatingActionButton: selectedItemId != null
          ? FloatingActionButton.extended(
              onPressed: () {
                // Get the full results items data
                final resultsAsyncValue = ref.read(resultsDataProvider);
                resultsAsyncValue.whenData((resultsItems) {
                  // Find the selected item
                  final selectedItem = resultsItems.firstWhere(
                    (item) => item.id == selectedItemId,
                    orElse: () => resultsItems.first,
                  );

                  // Store selected item for try-on page (as a single-item list)
                  ref.read(tryOnItemsProvider.notifier).state = [selectedItem];

                  print('🎯 Selected item for try-on:');
                  print(
                    '   - ${selectedItem.category}: ${selectedItem.imagePath}',
                  );
                });

                // Navigate to try-on page using bottom navigation
                ref.read(bottomNavigationIndexProvider.notifier).state = 2;

                // Clear selection after action
                ref.read(selectedResultItemProvider.notifier).state = null;
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              label: const Text(
                'Try On',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
      bottomNavigationBar: const SizedBox(height: 0),
    );
  }
}

class _ResultsFilter extends ConsumerWidget {
  final String label;

  const _ResultsFilter({required this.label});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(resultsFilterProvider);
    final isSelected = selectedFilter == label;

    return GestureDetector(
      onTap: () {
        ref.read(resultsFilterProvider.notifier).state = label;
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

class _ResultTile extends ConsumerWidget {
  final WardrobeModel item;

  const _ResultTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedItemId = ref.watch(selectedResultItemProvider);
    final isSelected = selectedItemId == item.id;

    return GestureDetector(
      onTap: () {
        // Toggle selection - if already selected, deselect; otherwise select this item
        if (isSelected) {
          ref.read(selectedResultItemProvider.notifier).state = null;
        } else {
          ref.read(selectedResultItemProvider.notifier).state = item.id;
        }
      },
      onLongPress: () {
        // Long press to view image in full screen with zoom
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => _ResultImageViewer(item: item),
          ),
        );
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

class _ResultImageViewer extends StatelessWidget {
  final WardrobeModel item;

  const _ResultImageViewer({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          item.type ?? 'Recommended Item',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () => _showInfoBottomSheet(context),
          ),
        ],
      ),
      body: PhotoView(
        imageProvider: NetworkImage(item.imagePath),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3,
        initialScale: PhotoViewComputedScale.contained,
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        loadingBuilder: (context, event) => Center(
          child: CircularProgressIndicator(
            value: event == null
                ? 0
                : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
            color: Colors.white,
          ),
        ),
        errorBuilder: (context, error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.broken_image, size: 60, color: Colors.white54),
              const SizedBox(height: 16),
              Text(
                'Failed to load image',
                style: TextStyle(color: Colors.white54),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Text(
            item.caption ?? 'No description available',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  void _showInfoBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            const Text(
              'Item Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),

            // Details
            if (item.type != null)
              _buildInfoRow(Icons.category, 'Type', item.type!),
            if (item.caption != null && item.caption!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(Icons.description, 'Description', item.caption!),
            ],
            if (item.color != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(Icons.palette, 'Color', item.color!),
            ],
            if (item.fabric != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(Icons.texture, 'Fabric', item.fabric!),
            ],
            if (item.pattern != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(Icons.pattern, 'Pattern', item.pattern!),
            ],
            if (item.style != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(Icons.style, 'Style', item.style!),
            ],
            if (item.season != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(Icons.wb_sunny, 'Season', item.season!),
            ],
            if (item.occasion != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(Icons.event, 'Occasion', item.occasion!),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
