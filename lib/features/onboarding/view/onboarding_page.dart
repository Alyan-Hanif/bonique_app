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
        image: const Icon(Icons.auto_awesome, size: 140, color: Color(0xFF2C2C2C)),
        title: 'Meet Bonique',
        subtitle: 'Your AI stylist that keeps outfits easy and fun.'
      ),
      (
        image: const Icon(Icons.color_lens, size: 140, color: Color(0xFF2C2C2C)),
        title: 'Set Your Vibe',
        subtitle: 'Pick colors and moods. We tailor looks to you.'
      ),
      (
        image: const Icon(Icons.tune, size: 140, color: Color(0xFF2C2C2C)),
        title: 'Instant Picks',
        subtitle: 'Get quick suggestions for work, weekends, and more.'
      ),
      (
        image: const Icon(Icons.check_circle, size: 140, color: Color(0xFF2C2C2C)),
        title: 'Ready To Go',
        subtitle: 'Save favorites and shop the look when you’re set.'
      ),
    ];

    final Color bgPeach = const Color(0xFFFFE7D7);
    final Color accent = const Color(0xFFFF6B2C);

    void goToAuth(BuildContext context) {
      Navigator.of(context).pushReplacementNamed(AuthPage.route);
    }

    return Scaffold(
      backgroundColor: bgPeach,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: controller.pageController,
                  itemCount: pagesData.length,
                  onPageChanged: (i) => controller.goToPage(i),
                  itemBuilder: (context, i) {
                    final data = pagesData[i];
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                        child: OnboardingPageContent(
                          image: data.image,
                          title: data.title,
                          subtitle: data.subtitle,
                          ctaText: i < pagesData.length - 1 ? 'Next' : 'Get Started',
                          onCtaPressed: () {
                            if (index < pagesData.length - 1) {
                              controller.nextPage();
                            } else {
                              goToAuth(context);
                            }
                          },
                          onSkip: () => goToAuth(context),
                          dots: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: OnboardingDots(
                              count: pagesData.length,
                              activeIndex: index,
                              activeColor: accent,
                              inactiveColor: Colors.black12,
                            ),
                          ),
                        ),
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