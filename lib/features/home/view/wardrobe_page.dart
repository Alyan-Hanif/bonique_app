import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WardrobePage extends ConsumerWidget {
  const WardrobePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wardrobe'),
        backgroundColor: const Color(0xFFFF6B2C),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _WardrobeFilter(label: 'All', selected: true),
                _WardrobeFilter(label: 'Dresses'),
                _WardrobeFilter(label: 'Jeans'),
                _WardrobeFilter(label: 'Shirts'),
                _WardrobeFilter(label: 'Skirts'),
                _WardrobeFilter(label: 'Hoodies'),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF6B2C),
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
        CircleAvatar(
          radius: 18,
          backgroundColor: selected
              ? const Color(0xFFFFE3D6)
              : Colors.grey.shade200,
          child: Icon(
            Icons.checkroom,
            size: 18,
            color: selected ? const Color(0xFFFF6B2C) : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? const Color(0xFFFF6B2C) : Colors.grey.shade700,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Last worn: 2d ago',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
