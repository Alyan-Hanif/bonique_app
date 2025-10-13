import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, int>((ref) {
      return OnboardingController();
    });

class OnboardingController extends StateNotifier<int> {
  OnboardingController() : super(0);

  void goToPage(int index) {
    if (index >= 0 && index < 3) {
      // Assuming 3 pages
      state = index;
    }
  }

  void nextPage() {
    final next = state + 1;
    if (next < 3) {
      // Assuming 3 pages
      state = next;
    }
  }

  void previousPage() {
    final prev = state - 1;
    if (prev >= 0) {
      state = prev;
    }
  }

  void handleScroll(DragUpdateDetails details) {
    // Detect horizontal scroll direction
    if (details.delta.dx > 10) {
      // Swipe right - go to previous page
      previousPage();
    } else if (details.delta.dx < -10) {
      // Swipe left - go to next page
      nextPage();
    }
  }
}
