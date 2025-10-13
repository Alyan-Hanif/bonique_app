import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/onboarding_viewmodel.dart';

class OnboardingPageView extends ConsumerStatefulWidget {
  final List<Widget> pages;
  final Function(int) onPageChanged;

  const OnboardingPageView({
    super.key,
    required this.pages,
    required this.onPageChanged,
  });

  @override
  ConsumerState<OnboardingPageView> createState() => _OnboardingPageViewState();
}

class _OnboardingPageViewState extends ConsumerState<OnboardingPageView> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(onboardingControllerProvider);
    
    // Sync PageController with the state
    if (_currentPage != index) {
      _currentPage = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    return PageView.builder(
      controller: _pageController,
      onPageChanged: (page) {
        _currentPage = page;
        widget.onPageChanged(page);
        ref.read(onboardingControllerProvider.notifier).goToPage(page);
      },
      itemCount: widget.pages.length,
      itemBuilder: (context, index) {
        return widget.pages[index];
      },
    );
  }
}
