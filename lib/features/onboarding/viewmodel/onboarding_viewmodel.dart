import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, int>((ref) {
  return OnboardingController();
});

class OnboardingController extends StateNotifier<int> {
  OnboardingController() : super(0);

  final PageController pageController = PageController();

  void goToPage(int index) {
    state = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void nextPage() {
    final next = state + 1;
    goToPage(next);
  }

  void previousPage() {
    final prev = state - 1;
    if (prev >= 0) {
      goToPage(prev);
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}