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
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center vertically
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Center horizontally
                  children: [
                    const SizedBox(height: 80), // Increased top spacing
                    // App Logo
                    Container(
                      width: 250,
                      height: 250,

                      child: Image.asset('assets/images/bonique/bonique - Copy-08.png')
                    ),

                    // const SizedBox(height: 40), // Increased spacing after logo
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
                      height: 30,
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

                    const SizedBox(height: 16),

                    // Terms Text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'By Continuing, you agree to our terms of service and privacy policy',
                        style: AuthTextStyles.stat2.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 16,
                          height: 1.0,
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
