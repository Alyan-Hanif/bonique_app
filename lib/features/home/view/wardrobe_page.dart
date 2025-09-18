import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WardrobePage extends ConsumerWidget {
  const WardrobePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    _WardrobeFilter(label: 'All', selected: true),
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
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  return _WardrobeTile(index: index);
                },
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: const Color(0xFF1B1A18),
      //   onPressed: () {},
      //   child: const Icon(Icons.add, color: Colors.white),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const SizedBox(height: 0),
    );
  }
}

class _WardrobeFilter extends StatelessWidget {
  final String label;
  final bool selected;

  const _WardrobeFilter({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF1B1A18) : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            _getIconForLabel(label),
            size: 18,
            color: selected ? Colors.white : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? const Color(0xFF1B1A18) : Colors.grey.shade700,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
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

class _WardrobeTile extends StatelessWidget {
  final int index;

  const _WardrobeTile({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: const Center(
                child: Icon(Icons.image, color: Colors.grey, size: 40),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Item ${index + 1}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B1A18),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Last worn: 2d ago',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
