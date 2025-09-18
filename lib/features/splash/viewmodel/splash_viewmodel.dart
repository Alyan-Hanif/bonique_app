import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class SplashViewmodel extends StatelessWidget {
  const SplashViewmodel({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}


class SplashController extends StateNotifier<SplashState> {
  SplashController() : super(const SplashState());

  void startAnimation() {
    state = state.copyWith(isAnimating: true);
  }

  void completeAnimation() {
    state = state.copyWith(isAnimating: false, isCompleted: true);
  }

  void navigateToNext() {
    state = state.copyWith(shouldNavigate: true);
  }
}

class SplashState {
  final bool isAnimating;
  final bool isCompleted;
  final bool shouldNavigate;

  const SplashState({
    this.isAnimating = false,
    this.isCompleted = false,
    this.shouldNavigate = false,
  });

  SplashState copyWith({
    bool? isAnimating,
    bool? isCompleted,
    bool? shouldNavigate,
  }) {
    return SplashState(
      isAnimating: isAnimating ?? this.isAnimating,
      isCompleted: isCompleted ?? this.isCompleted,
      shouldNavigate: shouldNavigate ?? this.shouldNavigate,
    );
  }
}

final splashControllerProvider =
    StateNotifierProvider<SplashController, SplashState>(
      (ref) => SplashController(),
    );
