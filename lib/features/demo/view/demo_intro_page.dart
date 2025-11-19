import 'package:flutter/material.dart';
import 'demo_video_page.dart';
import '../../auth/view/auth_page.dart';

class DemoIntroPage extends StatelessWidget {
  const DemoIntroPage({super.key});

  static const String route = '/demo-intro';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,   // vertical center
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Logo at the top
                Image.asset(
                  'assets/images/onboarding_logoo.png',
                  width: 156,
                  height: 57,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 40),

                // Main content
                Container(
                  constraints: const BoxConstraints(minHeight: 300),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Main heading
                          const Text(
                            'Hey, I\'m Bonique — your AI-powered style bestie. Here\'s how we\'ll upgrade your wardrobe:',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2C2C2C),
                              height: 1.3,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Feature list
                          _buildFeatureItem(
                            icon: 'assets/images/demo_1.png',
                            title: 'Try it on:',
                            description:
                                'Browse AI-curated outfits tailored to your style and see how each looks on you.',
                          ),

                          const SizedBox(height: 20),

                          _buildFeatureItem(
                            icon: 'assets/images/demo_2.png',
                            title: 'Personalized styling:',
                            description:
                                'Tell me your preferences, get suggestions that actually match your vibe.',
                          ),

                          const SizedBox(height: 20),

                          _buildFeatureItem(
                            icon: 'assets/images/demo_3.png',
                            title: 'Ask away:',
                            description:
                                'Got a shirt you love? Ask me what to pair it with. I\'ll suggest the perfect match.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Watch Demo button
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB87C5C),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const DemoVideoPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Watch Demo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Skip button
                    TextButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pushReplacementNamed(AuthPage.route);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Color(0xFF2C2C2C),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required String icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF5F0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Image.asset(
              icon,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Text content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Color(0xFF2C2C2C),
                  ),
                  children: [
                    TextSpan(
                      text: title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(
                      text: ' $description',
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
