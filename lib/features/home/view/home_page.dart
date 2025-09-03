import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'wardrobe_page.dart';
import 'discovery_page.dart';
import 'try_on_page.dart';
import 'profile_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const route = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PersistentTabView(
      context,
      controller: PersistentTabController(initialIndex: 0),
      screens: const [
        WardrobePage(),
        DiscoveryPage(),
        TryOnPage(),
        ProfilePage(),
      ],
      items: [
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.inventory_2_outlined),
          title: "Wardrobe",
          activeColorPrimary: const Color(0xFFFF6B2C),
          inactiveColorPrimary: Colors.grey,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.explore),
          title: "Discovery",
          activeColorPrimary: const Color(0xFFFF6B2C),
          inactiveColorPrimary: Colors.grey,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.camera_alt),
          title: "Try On",
          activeColorPrimary: const Color(0xFFFF6B2C),
          inactiveColorPrimary: Colors.grey,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.person),
          title: "Profile",
          activeColorPrimary: const Color(0xFFFF6B2C),
          inactiveColorPrimary: Colors.grey,
        ),
      ],
      // confineInSafeArea: true,
      backgroundColor: Colors.white,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      // hideNavigationBarWhenKeyboardShows: true,
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      // popAllScreensOnTapOfSelectedTab: true,
      // popActionScreens: PopActionScreensType.all,
      // itemAnimationProperties: const ItemAnimationProperties(
      //   duration: Duration(milliseconds: 200),
      //   curve: Curves.ease,
      // ),
      // screenTransitionAnimation: const ScreenTransitionAnimation(
      //   animateTabTransition: true,
      //   curve: Curves.ease,
      //   duration: Duration(milliseconds: 200),
      // ),
      navBarStyle: NavBarStyle.style6,
    );
  }
}
