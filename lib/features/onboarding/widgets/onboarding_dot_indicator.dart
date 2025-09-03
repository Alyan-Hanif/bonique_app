import 'package:flutter/material.dart';

class OnboardingDots extends StatelessWidget {
  const OnboardingDots({
    super.key,
    required this.count,
    required this.activeIndex,
    this.activeColor,
    this.inactiveColor,
  });

  final int count;
  final int activeIndex;
  final Color? activeColor;
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    final Color active = activeColor ?? Theme.of(context).colorScheme.primary;
    final Color inactive = inactiveColor ?? Colors.black12;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final bool isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 6,
          width: isActive ? 16 : 6,
          decoration: BoxDecoration(
            color: isActive ? active : inactive,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
} 