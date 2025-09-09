import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/onboarding_viewmodel.dart';
import '../widgets/onboarding_dot_indicator.dart';
import '../../auth/view/auth_page.dart';

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  static const route = '/onboarding';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    final pagesData = [
      (
        image: 'assets/images/onboarding_1.png',
        title: 'Meet Bonique',
        subtitle:
            'Bonique is your personal AI-powered stylist - helping you explore your wardrobe, discover new outfit ideas, and try on looks virtually, so you can step out with confidence every day.',
      ),
      (
        image: 'assets/images/onboarding_2.png',
        title: 'Fashion, Made Effortless',
        subtitle:
            'Say goodbye to decision fatigue and hello to confidence. Bonique blends your wardrobe with endless AI-curated possibilities, so you always step out feeling polished, stylish, and authentically you.',
      ),
      (
        image: 'assets/images/onboarding_3.png',
        title: 'Discover Looks',
        subtitle:
            'Turn dressing into a seamless experience with intelligent, tailored outfit suggestions that adapt to your mood, align with your events, and evolve with the seasons - ensuring you always feel confident and effortlessly stylish.',
      ),
    ];

    final Color darkGray = const Color(0xFF2C2C2C);

    void goToAuth(BuildContext context) {
      Navigator.of(context).pushReplacementNamed(AuthPage.route);
    }

    return WillPopScope(
      onWillPop: () async {
        // Handle back button - go to previous page or exit onboarding
        if (index > 0) {
          controller.previousPage();
          return false; // Don't pop the route
        } else {
          // If on first page, go to auth page
          goToAuth(context);
          return false; // Don't pop the route
        }
      },
      child: Scaffold(
        backgroundColor: darkGray,
        body: SafeArea(
          child: Column(
            children: [
              // Fixed background with clipped circle
              Expanded(
                flex: 60,
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: ClipPath(
                    clipper: CircleClipper(),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: darkGray,
                      child: Center(
                        child: PageView.builder(
                          controller: controller.pageController,
                          itemCount: pagesData.length,
                          onPageChanged: (i) => controller.goToPage(i),
                          itemBuilder: (context, i) {
                            final data = pagesData[i];
                            return Image.asset(
                              data.image,
                              width: 300,
                              height: 300,
                              fit: BoxFit.contain,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Fixed content area with text and navigation
              Expanded(
                flex: 40,
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 20.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Dynamic text content - using AnimatedSwitcher instead of PageView
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              key: ValueKey(index),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Title
                                  Text(
                                    pagesData[index].title,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: darkGray,
                                          fontSize: 28,
                                        ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Description
                                  Text(
                                    pagesData[index].subtitle,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 15,
                                      height: 1.0,
                                      letterSpacing: 0.0,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Fixed navigation elements
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Skip button (left side)
                            SizedBox(
                              height: 32,
                              width: 100,
                              child: TextButton(
                                onPressed: () => goToAuth(context),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(83, 32),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Skip',
                                  style: TextStyle(
                                    color: Color(0xFF2C2C2C),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            // Dot indicator
                            OnboardingDots(
                              count: pagesData.length,
                              activeIndex: index,
                              activeColor: darkGray,
                              inactiveColor: darkGray.withOpacity(0.3),
                            ),

                            // Next button (right side)
                            SizedBox(
                              height: 32,
                              width: 100,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: darkGray,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(48),
                                  ),
                                  elevation: 0,
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(83, 32),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () {
                                  if (index < pagesData.length - 1) {
                                    controller.nextPage();
                                  } else {
                                    goToAuth(context);
                                  }
                                },
                                child: Text(
                                  index < pagesData.length - 1
                                      ? 'Next'
                                      : 'Get Started',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// CircleClipper class moved here since we're no longer using OnboardingPageContent
class CircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Create a circle that starts from above and extends down
    final centerX = size.width / 2;
    final centerY = size.height * 0.4; // Position circle higher up
    final radius =
        size.width * 0.7; // Make circle large enough to extend beyond bounds

    path.addOval(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
    );

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
