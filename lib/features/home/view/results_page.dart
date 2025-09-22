import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/home_viewmodel.dart'; // Add this import

// Sample results data
final resultsDataProvider = Provider<List<ResultItem>>((ref) {
  return [
    ResultItem(
      id: 1,
      name: 'Dark Green T-Shirt',
      category: 'Shirts',
      imagePath: 'assets/images/tshirt.png',
      price: '\$29.99',
    ),
    ResultItem(
      id: 2,
      name: 'Pink Dress with Turtleneck',
      category: 'Dresses',
      imagePath: 'assets/images/tshirt.png',
      price: '\$89.99',
    ),
    ResultItem(
      id: 3,
      name: 'Teal Dress',
      category: 'Dresses',
      imagePath: 'assets/images/tshirt.png',
      price: '\$79.99',
    ),
    ResultItem(
      id: 4,
      name: 'Blue Jeans',
      category: 'Jeans',
      imagePath: 'assets/images/tshirt.png',
      price: '\$59.99',
    ),
    ResultItem(
      id: 5,
      name: 'Floral Sundress',
      category: 'Dresses',
      imagePath: 'assets/images/tshirt.png',
      price: '\$69.99',
    ),
    ResultItem(
      id: 6,
      name: 'Denim Jacket',
      category: 'Jackets',
      imagePath: 'assets/images/tshirt.png',
      price: '\$99.99',
    ),
  ];
});

// Selected items for try-on
final selectedResultItemsProvider = StateProvider<Set<int>>((ref) => <int>{});

class ResultItem {
  final int id;
  final String name;
  final String category;
  final String imagePath;
  final String price;

  ResultItem({
    required this.id,
    required this.name,
    required this.category,
    required this.imagePath,
    required this.price,
  });
}

class ResultsPage extends ConsumerWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsItems = ref.watch(resultsDataProvider);
    final selectedItems = ref.watch(selectedResultItemsProvider);

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
                  'Results',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B1A18),
                  ),
                ),
              ),
            ),
            // Results grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: resultsItems.length,
                itemBuilder: (context, index) {
                  return _ResultTile(item: resultsItems[index]);
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
                ref.read(selectedResultItemsProvider.notifier).state = <int>{};
              },
              backgroundColor: const Color(0xFF1B1A18),
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

class _ResultTile extends ConsumerStatefulWidget {
  final ResultItem item;

  const _ResultTile({required this.item});

  @override
  ConsumerState<_ResultTile> createState() => _ResultTileState();
}

class _ResultTileState extends ConsumerState<_ResultTile> {
  @override
  Widget build(BuildContext context) {
    final selectedItems = ref.watch(selectedResultItemsProvider);
    final isSelected = selectedItems.contains(widget.item.id);

    return GestureDetector(
      onTap: () {
        final currentSelected = ref.read(selectedResultItemsProvider);
        final newSelected = Set<int>.from(currentSelected);

        if (isSelected) {
          newSelected.remove(widget.item.id);
        } else {
          newSelected.add(widget.item.id);
        }

        ref.read(selectedResultItemsProvider.notifier).state = newSelected;
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: const Color(0xFF1B1A18), width: 2)
              : Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.asset(
                      widget.item.imagePath,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9D9D9),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.image,
                              color: Colors.grey,
                              size: 40,
                            ),
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
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.item.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B1A18),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.item.price,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
