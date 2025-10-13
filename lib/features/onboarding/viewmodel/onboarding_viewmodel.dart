import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, int>((ref) {
      return OnboardingController();
    });

class OnboardingController extends StateNotifier<int> {
  OnboardingController() : super(0);

  // Track swipe state to prevent multiple rapid page changes
  double _totalSwipeDistance = 0.0;
  bool _hasSwiped = false;
  static const double _swipeThreshold = 50.0; // Minimum distance for a valid swipe

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
    // Accumulate the swipe distance
    _totalSwipeDistance += details.delta.dx;
  }

  void handleScrollEnd(DragEndDetails details) {
    // Only process swipe if we haven't already swiped in this gesture
    if (_hasSwiped) {
      _resetSwipeState();
      return;
    }

    // Check if the total swipe distance meets the threshold
    if (_totalSwipeDistance.abs() >= _swipeThreshold) {
      if (_totalSwipeDistance > 0) {
        // Swipe right - go to previous page
        previousPage();
      } else {
        // Swipe left - go to next page
        nextPage();
      }
      _hasSwiped = true;
    }

    // Reset for next gesture
    _resetSwipeState();
  }

  void _resetSwipeState() {
    _totalSwipeDistance = 0.0;
    _hasSwiped = false;
  }

  // Legacy method for backward compatibility
  @Deprecated('Use handleScroll and handleScrollEnd instead')
  void handleScrollLegacy(DragUpdateDetails details) {
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
