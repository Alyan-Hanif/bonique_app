import 'package:flutter/material.dart';

class OnboardingPageContent extends StatelessWidget {
  const OnboardingPageContent({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    this.ctaText,
    this.onCtaPressed,
    this.onSkip,
    this.dots,
  });

  final Widget image;
  final String title;
  final String subtitle;
  final String? ctaText;
  final VoidCallback? onCtaPressed;
  final VoidCallback? onSkip;
  final Widget? dots;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final Color ctaColor = const Color(0xFFFF6B2C); // warm orange like reference

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: onSkip,
                      child: const Text('Skip'),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Center(child: image),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(color: Colors.black54, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  if (dots != null) dots!,
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ctaColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: onCtaPressed,
                      child: Text(ctaText ?? 'Next'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 