import 'package:flutter/material.dart';
import 'dart:ui';
import '../widgets/auth_widgets.dart';

class AccountPage extends StatelessWidget {
  final VoidCallback onSignIn;
  final VoidCallback onCreateAccount;

  const AccountPage({
    super.key,
    required this.onSignIn,
    required this.onCreateAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/account_page.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 80), // Increased top spacing
                    // App Logo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),

                    const SizedBox(height: 60), // Increased spacing after logo
                    // Welcome Text
                    Text(
                      'Welcome to Bonique',
                      style: AuthTextStyles.h1.copyWith(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // Description Text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Style your outfits effortlessly with our AI stylist, no need for second opinions or endless scrolling.',
                        style: AuthTextStyles.stat1.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(
                      height: 60,
                    ), // Increased spacing before buttons
                    // Buttons Container
                    Column(
                      children: [
                        // Sign In Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: AuthPrimaryButton(
                            text: 'Sign In',
                            onPressed: onSignIn,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Create Account Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: AuthSecondaryButton(
                            text: 'Create Account',
                            onPressed: onCreateAccount,
                          ),
                        ),
                      ],
                    ),

                    // const Spacer(), // Push footer to bottom
                    // Terms Text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'By Continuing, you agree to our terms of service and privacy policy',
                        style: AuthTextStyles.stat2.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
