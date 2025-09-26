import 'package:bonique/features/home/view/try_on_page.dart';
import 'package:bonique/features/home/viewmodel/home_viewmodel.dart';
import 'package:bonique/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:bonique/data/repositories/wardrobe_repository.dart';
import 'package:bonique/data/models/wardrobe_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// State management for wardrobe filtering
final wardrobeFilterProvider = StateProvider<String>((ref) => 'All');

// Real wardrobe data provider that fetches from Supabase
final wardrobeDataProvider = FutureProvider<List<WardrobeModel>>((ref) async {
  final authState = ref.watch(authViewModelProvider);
  
  if (!authState.isLoggedIn || authState.currentUserModel == null) {
    return [];
  }
  
  try {
    final wardrobeItems = await WardrobeRepository.getWardrobeItems(
      authState.currentUserModel!.id
    );
    return wardrobeItems;
  } catch (e) {
    print('Error fetching wardrobe data: $e');
    return [];
  }
});

// Add this provider after the existing providers
final selectedWardrobeItemsProvider = StateProvider<Set<int>>((ref) => <int>{});

class WardrobePage extends ConsumerWidget {
  const WardrobePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(wardrobeFilterProvider);
    final wardrobeAsyncValue = ref.watch(wardrobeDataProvider);
    final selectedItems = ref.watch(selectedWardrobeItemsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom title bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: const Center(
                child: Text(
                  'My Wardrobe',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B1A18),
                  ),
                ),
              ),
            ),
            // Filter bar
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
            // Wardrobe grid
            Expanded(
              child: wardrobeAsyncValue.when(
                data: (wardrobeItems) {
                  // Filter items based on selected category
                  final filteredItems = selectedFilter == 'All'
                      ? wardrobeItems
                      : wardrobeItems
                            .where((item) => item.category == selectedFilter)
                            .toList();

                  if (filteredItems.isEmpty) {
                    return const Center(
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
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF1B1A18),
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
                          ref.refresh(wardrobeDataProvider);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B1A18),
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
                // Navigate to try-on page using bottom navigation
                ref.read(bottomNavigationIndexProvider.notifier).state = 2;
                // Clear selection after action
                ref.read(selectedWardrobeItemsProvider.notifier).state =
                    <int>{};
              },
              backgroundColor: const Color(0xFF1B1A18),
              label: Text(
                'Try On (${selectedItems.length})',
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
                  ? const Color(0xFF1B1A18)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              _getIconForLabel(label),
              size: 18,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected
                  ? const Color(0xFF1B1A18)
                  : Colors.grey.shade700,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'all':
        return Icons.checkroom;
      case 'dresses':
        return Icons.checkroom;
      case 'jeans':
        return Icons.checkroom;
      case 'shirts':
        return Icons.checkroom;
      case 'skirts':
        return Icons.checkroom;
      case 'hoodies':
        return Icons.checkroom;
      default:
        return Icons.checkroom;
    }
  }
}

class _WardrobeTile extends ConsumerStatefulWidget {
  final WardrobeModel item;

  const _WardrobeTile({required this.item});

  @override
  ConsumerState<_WardrobeTile> createState() => _WardrobeTileState();
}

class _WardrobeTileState extends ConsumerState<_WardrobeTile> {
  @override
  Widget build(BuildContext context) {
    final selectedItems = ref.watch(selectedWardrobeItemsProvider);
    final isSelected = selectedItems.contains(widget.item.id);

    return GestureDetector(
      onTap: () {
        final currentSelected = ref.read(selectedWardrobeItemsProvider);
        final newSelected = Set<int>.from(currentSelected);

        if (isSelected) {
          newSelected.remove(widget.item.id);
        } else {
          newSelected.add(widget.item.id);
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
              ? Border.all(color: const Color(0xFF1B1A18), width: 2.5)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF1B1A18).withOpacity(0.3),
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
                widget.item.imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(8.93),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF1B1A18),
                      ),
                    ),
                  );
                },
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
                  decoration: const BoxDecoration(
                    color: Color(0xFF1B1A18),
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
