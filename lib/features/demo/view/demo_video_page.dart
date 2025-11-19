import 'package:flutter/material.dart';
import '../../auth/view/auth_page.dart';

class DemoVideoPage extends StatelessWidget {
  const DemoVideoPage({super.key});

  static const String route = '/demo-video';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,   // vertical center
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo at the top
                  Image.asset(
                    'assets/images/onboarding_logoo.png',
                    width: 156,
                    height: 57,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 32),

                  // Main content - Video placeholder
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Video thumbnail/placeholder
                      Container(
                        width: double.infinity,
                        height: 300,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(20),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/account_page.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Dark overlay
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ),

                            // Play button
                            Center(
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.play_arrow_rounded,
                                    size: 48,
                                    color: Color(0xFFB87C5C),
                                  ),
                                  onPressed: () {
                                    // TODO: Implement video playback
                                    // For now, show a snackbar
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Video playback will be implemented here',
                                        ),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Play Demo button
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
                        // TODO: Implement actual video playback
                        // For now, navigate to auth page after showing message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Demo video would play here'),
                            duration: Duration(seconds: 1),
                          ),
                        );

                        // Navigate to auth after a short delay
                        Future.delayed(const Duration(seconds: 1), () {
                          if (context.mounted) {
                            Navigator.of(
                              context,
                            ).pushReplacementNamed(AuthPage.route);
                          }
                        });
                      },
                      child: const Text(
                        'Play Demo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Next button (skip demo)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed(AuthPage.route);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        color: Color(0xFF2C2C2C),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
