import 'package:flutter/material.dart';
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
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2C2C2C), Color(0xFF404040), Color(0xFF1A1A1A)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // App Logo
                const SizedBox(height: 60),
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

                const Spacer(),

                // Welcome Text
                Text(
                  'Welcome to Bonique',
                  style: AuthTextStyles.h1.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                Text(
                  'Style your outfits effortlessly with our AI stylist, no need for second opinions or endless scrolling.',
                  style: AuthTextStyles.stat1.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Sign In Button
                AuthPrimaryButton(text: 'Sign In', onPressed: onSignIn),

                const SizedBox(height: 16),

                // Create Account Button
                AuthSecondaryButton(
                  text: 'Create Account',
                  onPressed: onCreateAccount,
                ),

                const SizedBox(height: 32),

                // Terms Text
                Text(
                  'By Continuing, you agree to our terms of service and privacy policy',
                  style: AuthTextStyles.stat2.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
