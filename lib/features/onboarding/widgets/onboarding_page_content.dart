import 'package:flutter/material.dart';

class OnboardingPageContent extends StatelessWidget {
  const OnboardingPageContent({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    this.ctaText,
    this.onCtaPressed,
    this.onBack,
    this.onSkip,
    this.dots,
    this.showBackButton = false,
  });

  final String image;
  final String title;
  final String subtitle;
  final String? ctaText;
  final VoidCallback? onCtaPressed;
  final VoidCallback? onBack;
  final VoidCallback? onSkip;
  final Widget? dots;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final Color darkGray = const Color(0xFF1B1A18);

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Upper portion - 60% with white background and dark grey circle
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
                    child: Image.asset(
                      image,
                      width: 300,
                      height: 300,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Lower portion - 40% with white background
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
                    Column(
                      children: [
                        // Title
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: darkGray,
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Description
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                            height: 1.0, // line-height: 100%
                            letterSpacing: 0.0, // letter-spacing: 0%
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    // Navigation elements at bottom
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Skip button (left side)
                        SizedBox(
                          height: 32,
                          width: 100,
                          child: TextButton(
                            onPressed: onSkip,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(83, 32),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                        if (dots != null) ...[
                          dots!,
                          const SizedBox(height: 24),
                        ],

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
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: onCtaPressed,
                            child: Text(
                              ctaText ?? 'Next',
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
    );
  }
}

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
