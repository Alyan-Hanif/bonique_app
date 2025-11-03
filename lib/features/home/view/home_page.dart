import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bonique/features/home/viewmodel/home_viewmodel.dart';
import 'package:bonique/features/auth/viewmodel/auth_viewmodel.dart';
import '../viewmodel/discovery_viewmodel.dart';
import 'wardrobe_page.dart';
import 'discovery_page.dart';
import 'try_on_page.dart';
import 'profile_page.dart';
import 'results_page.dart';
import 'add_item_page.dart';

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
    AddItemPage(), // Add AddItemPage at index 5
  ];

  void _navigateToAddItem() {
    // Navigate to AddItemPage using bottom navigation index
    ref.read(bottomNavigationIndexProvider.notifier).state = 5;
  }

  void _onTabTapped(int index) {
    // Update the current index
    ref.read(bottomNavigationIndexProvider.notifier).state = index;

    // Refetch data based on the selected tab
    switch (index) {
      case 0: // Wardrobe
        ref.refresh(wardrobeDataProvider);
        break;
      case 1: // Discover
        // Fetch new questions every time the Discovery tab is clicked
        ref.read(discoveryControllerProvider.notifier).fetchQuestions();
        break;
      case 2: // Try-On
        // Add try-on data provider refresh if needed
        break;
      case 3: // Profile
        // Don't refresh auth state - it can cause navigation issues
        // The profile page will get the current auth state automatically
        break;
      case 4: // Results
        ref.refresh(resultsDataProvider);
        break;
      case 5: // Add Item
        // Add item data provider refresh if needed
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavigationIndexProvider);

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _screens),

      // Floating Add Button (center docked)
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          onPressed: _navigateToAddItem,
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
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
              _buildNavItemWithSvg('assets/images/wardrobe.svg', 'Wardrobe', 0),
              _buildNavItemWithSvg('assets/images/discover.svg', 'Discover', 1),
              const SizedBox(width: 40), // gap for FAB
              _buildNavItemWithSvg('assets/images/try_on.svg', 'Try-On', 2),
              _buildNavItemWithSvg('assets/images/profile.svg', 'Profile', 3),
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
      onTap: () => _onTabTapped(index),
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItemWithSvg(String svgPath, String label, int index) {
    final currentIndex = ref.watch(bottomNavigationIndexProvider);
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              svgPath,
              width: 24,
              height: 24,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
