import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/onboarding_viewmodel.dart';
import '../widgets/onboarding_dot_indicator.dart';
import '../../demo/view/demo_intro_page.dart';
import '../../auth/view/account_page.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  static const route = '/onboarding';

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final index = ref.read(onboardingControllerProvider);
      final controller = ref.read(onboardingControllerProvider.notifier);

      if (index < 2) {
        controller.nextPage();
      } else {
        // On the last page, navigate to demo
        timer.cancel();
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const DemoIntroPage()),
          );
        }
      }
    });
  }

  void _resetAutoScroll() {
    _startAutoScroll();
  }

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    final pagesData = [
      (
        image: 'assets/images/onboarding_prototype_1.png',
        title: 'Discover Looks from Your Own Closet',
        subtitle:
            'Upload your wardrobe and let Bonique create endless outfit combinations from the clothes you already own.',
      ),
      (
        image: 'assets/images/onboarding_prototype_2.png',
        title: 'Loved by 500+ People Around the World',
        subtitle:
            'Join thousands of fashion lovers who trust Bonique for their daily outfit inspiration and styling needs.',
      ),
      (
        image: 'assets/images/onboarding_prototype_3.png',
        title: 'See yourself in every style, effortlessly',
        subtitle:
            'Try on any outfit virtually with AI-powered visualization. See how you look before you step out.',
      ),
    ];

    void goToDemo(BuildContext context) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DemoIntroPage()),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        // Handle back button - go to previous page or exit onboarding
        if (index > 0) {
          controller.previousPage();
          _resetAutoScroll(); // Reset timer on manual navigation
          return false; // Don't pop the route
        } else {
          // If on first page, go to demo page
          goToDemo(context);
          return false; // Don't pop the route
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: GestureDetector(
            onPanUpdate: (details) {
              controller.handleScroll(details);
            },
            onPanEnd: (details) {
              controller.handleScrollEnd(details);
              _resetAutoScroll(); // Reset timer after swipe
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: Column(
                children: [
                  // Logo at the top
                  Image.asset(
                    'assets/images/onboarding_logoo.png',
                    height: 60,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 24),

                  // Main content area
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Main image
                        Expanded(
                          flex: 5,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 600),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position:
                                          Tween<Offset>(
                                            begin: const Offset(0.3, 0.0),
                                            end: Offset.zero,
                                          ).animate(
                                            CurvedAnimation(
                                              parent: animation,
                                              curve: Curves.easeOutCubic,
                                            ),
                                          ),
                                      child: child,
                                    ),
                                  );
                                },
                            child: Image.asset(
                              pagesData[index].image,
                              key: ValueKey(index),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Title
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 600),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                          child: Text(
                            pagesData[index].title,
                            key: ValueKey('title_$index'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2C2C2C),
                              fontSize: 20,
                              height: 1.2,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Dot indicators (no animation)
                        OnboardingDots(
                          count: pagesData.length,
                          activeIndex: index,
                          activeColor: const Color(0xFFB87C5C),
                          inactiveColor: const Color(
                            0xFFB87C5C,
                          ).withOpacity(0.3),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),

                  // Get Started button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB87C5C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        _autoScrollTimer
                            ?.cancel(); // Cancel timer before navigating
                        goToDemo(context);
                      },
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Log In link
                  TextButton(
                    onPressed: () {
                      _autoScrollTimer
                          ?.cancel(); // Cancel timer before navigating
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => AccountPage(
                            onSignIn: () {},
                            onCreateAccount: () {},
                          ),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text(
                      'Log In',
                      style: TextStyle(
                        color: Color(0xFF2C2C2C),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
