import 'package:bonique/features/home/view/try_on_page.dart';
import 'package:bonique/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// State management for wardrobe filtering
final wardrobeFilterProvider = StateProvider<String>((ref) => 'All');

// Sample wardrobe data with dress information
final wardrobeDataProvider = Provider<List<WardrobeItem>>((ref) {
  return [
    WardrobeItem(
      id: 1,
      name: 'Black T-Shirt',
      category: 'Shirts',
      imagePath: 'assets/images/tshirt.png', // Using available image
      lastWorn: DateTime.now().subtract(const Duration(days: 2)),
    ),
    WardrobeItem(
      id: 2,
      name: 'Pink Dress',
      category: 'Dresses',
      imagePath: 'assets/images/tshirt.png',
      lastWorn: DateTime.now().subtract(const Duration(days: 5)),
    ),
    WardrobeItem(
      id: 3,
      name: 'Blue Jeans',
      category: 'Jeans',
      imagePath: 'assets/images/tshirt.png',
      lastWorn: DateTime.now().subtract(const Duration(days: 1)),
    ),
    WardrobeItem(
      id: 4,
      name: 'Elegant Dress',
      category: 'Dresses',
      imagePath: 'assets/images/tshirt.png',
      lastWorn: DateTime.now().subtract(const Duration(days: 3)),
    ),
    WardrobeItem(
      id: 5,
      name: 'White Shirt',
      category: 'Shirts',
      imagePath: 'assets/images/tshirt.png',
      lastWorn: DateTime.now().subtract(const Duration(days: 7)),
    ),
    WardrobeItem(
      id: 6,
      name: 'Denim Skirt',
      category: 'Skirts',
      imagePath: 'assets/images/tshirt.png',
      lastWorn: DateTime.now().subtract(const Duration(days: 4)),
    ),
    WardrobeItem(
      id: 7,
      name: 'Casual Hoodie',
      category: 'Hoodies',
      imagePath: 'assets/images/tshirt.png',
      lastWorn: DateTime.now().subtract(const Duration(days: 6)),
    ),
    WardrobeItem(
      id: 8,
      name: 'Summer Dress',
      category: 'Dresses',
      imagePath: 'assets/images/tshirt.png',
      lastWorn: DateTime.now().subtract(const Duration(days: 8)),
    ),
  ];
});

// Wardrobe item model
class WardrobeItem {
  final int id;
  final String name;
  final String category;
  final String imagePath;
  final DateTime lastWorn;

  WardrobeItem({
    required this.id,
    required this.name,
    required this.category,
    required this.imagePath,
    required this.lastWorn,
  });
}

// Add this provider after the existing providers
final selectedWardrobeItemsProvider = StateProvider<Set<int>>((ref) => <int>{});

class WardrobePage extends ConsumerWidget {
  const WardrobePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(wardrobeFilterProvider);
    final wardrobeItems = ref.watch(wardrobeDataProvider);
    final selectedItems = ref.watch(selectedWardrobeItemsProvider);

    // Filter items based on selected category
    final filteredItems = selectedFilter == 'All'
        ? wardrobeItems
        : wardrobeItems
              .where((item) => item.category == selectedFilter)
              .toList();

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
              child: GridView.builder(
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
              // icon: const Icon(Icons.check, color: Colors.white),
              label: Text(
                'Try On',
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
  final WardrobeItem item;

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
              child: Image.asset(
                widget.item.imagePath,
                fit: BoxFit.cover,
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
