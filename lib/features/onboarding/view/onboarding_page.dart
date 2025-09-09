import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/onboarding_viewmodel.dart';
import '../widgets/onboarding_dot_indicator.dart';
import '../widgets/onboarding_page_content.dart';
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
              Expanded(
                child: PageView.builder(
                  controller: controller.pageController,
                  itemCount: pagesData.length,
                  onPageChanged: (i) => controller.goToPage(i),
                  itemBuilder: (context, i) {
                    final data = pagesData[i];
                    return OnboardingPageContent(
                      image: data.image,
                      title: data.title,
                      subtitle: data.subtitle,
                      ctaText: i < pagesData.length - 1
                          ? 'Next'
                          : 'Get Started',
                      showBackButton: i > 0,
                      onCtaPressed: () {
                        if (index < pagesData.length - 1) {
                          controller.nextPage();
                        } else {
                          goToAuth(context);
                        }
                      },
                      onBack: i > 0 ? () => controller.previousPage() : null,
                      onSkip: () => goToAuth(context),
                      dots: OnboardingDots(
                        count: pagesData.length,
                        activeIndex: index,
                        activeColor: darkGray,
                        inactiveColor: darkGray.withOpacity(0.3),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
