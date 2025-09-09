import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/splash_viewmodel.dart';
import '../../onboarding/view/onboarding_page.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  static const route = '/splash';

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _smokeController;
  late AnimationController _logoController;
  late Animation<double> _smokeAnimation;
  late Animation<double> _logoAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize smoke animation controller
    _smokeController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Initialize logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Create smoke fade-in animation
    _smokeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _smokeController, curve: Curves.easeInOut),
    );

    // Create logo scale and fade animation
    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));

    // Start animations in sequence
    _startAnimations();
  }

  void _startAnimations() async {
    // First: Complete smoke animation
    _smokeController.forward();

    // Wait for smoke to complete, then show logo
    await Future.delayed(const Duration(milliseconds: 2000));
    _logoController.forward();

    // Wait for logo animation to complete, then navigate
    await Future.delayed(const Duration(milliseconds: 1500));
    _navigateToOnboarding();
  }

  void _navigateToOnboarding() {
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(OnboardingPage.route);
    }
  }

  @override
  void dispose() {
    _smokeController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1A18),
      body: Stack(
        children: [
          // Smoke background animation
          AnimatedBuilder(
            animation: _smokeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _smokeAnimation.value.clamp(0.0, 1.0),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/smoke_bg.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),

          // Logo and text content - only show after smoke completes
          Center(
            child: AnimatedBuilder(
              animation: _logoAnimation,
              builder: (context, child) {
                final clampedValue = _logoAnimation.value.clamp(0.0, 1.0);
                return Opacity(
                  opacity: clampedValue,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo container - white rounded square with black shopping bag icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            16,
                          ), // Rounded corners like in image
                        ),
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.black, // Black icon as shown in image
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Primary text
                      const Text(
                        'Your AI Stylist',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Secondary text
                      const Text(
                        'Powered by Bonique',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
