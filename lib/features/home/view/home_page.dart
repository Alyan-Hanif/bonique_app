import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bonique/features/home/viewmodel/home_viewmodel.dart';
import 'wardrobe_page.dart';
import 'discovery_page.dart';
import 'try_on_page.dart';
import 'profile_page.dart';
import 'results_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  static const route = '/home';

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final List<Widget> _screens = const [
    WardrobePage(),
    DiscoveryPage(),
    TryOnPage(),
    ProfilePage(),
    ResultsPage(), // Add ResultsPage at index 4
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavigationIndexProvider);

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _screens),

      // Floating Add Button (center docked)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Add item functionality")),
          );
        },
        backgroundColor: const Color(0xFF1B1A18),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Custom Bottom Navigation
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(), // notch for FAB
        notchMargin: 8,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.checkroom, 'Wardrobe', 0),
              _buildNavItem(Icons.search, 'Discover', 1),
              const SizedBox(width: 40), // gap for FAB
              _buildNavItem(Icons.checkroom, 'Try-On', 2),
              _buildNavItem(Icons.person, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final currentIndex = ref.watch(bottomNavigationIndexProvider);
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        ref.read(bottomNavigationIndexProvider.notifier).state = index;
      },
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF1B1A18) : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? const Color(0xFF1B1A18) : Colors.grey,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
