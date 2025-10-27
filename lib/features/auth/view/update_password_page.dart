import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/auth_widgets.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/snackbar_utils.dart';

class UpdatePasswordPage extends ConsumerStatefulWidget {
  const UpdatePasswordPage({super.key});

  static const route = '/update-password';

  @override
  ConsumerState<UpdatePasswordPage> createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends ConsumerState<UpdatePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _isVerified = false;
  String? _userEmail;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get arguments from route (sent from deep link service after OTP verification)
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _isVerified = args['verified'] as bool? ?? false;
      _userEmail = args['email'] as String?;

      debugPrint('🔐 Update password page loaded');
      debugPrint('   Verified: $_isVerified');
      debugPrint('   Email: $_userEmail');

      // Verify session exists
      final currentUser = SupabaseService.client.auth.currentUser;
      if (currentUser != null) {
        debugPrint('✅ Session confirmed for: ${currentUser.email}');
      } else {
        debugPrint('⚠️ Warning: No session found');
      }
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if new passwords match
    if (_newPasswordController.text != _confirmPasswordController.text) {
      SnackbarUtils.showError(
        context,
        title: 'Password Mismatch',
        message: 'New passwords do not match',
      );
      return;
    }

    // Check password length
    if (_newPasswordController.text.length < 6) {
      SnackbarUtils.showError(
        context,
        title: 'Invalid Password',
        message: 'Password must be at least 6 characters long',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Verify we have a valid session
      final currentUser = SupabaseService.client.auth.currentUser;

      if (currentUser == null) {
        throw Exception('session_not_found');
      }

      debugPrint('🔐 Updating password for: ${currentUser.email}');

      // Update the password using the established session
      await SupabaseService.client.auth.updateUser(
        UserAttributes(password: _newPasswordController.text),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        SnackbarUtils.showSuccess(
          context,
          title: 'Password Updated!',
          message: 'Your password has been updated successfully.',
        );

        // Sign out the user to ensure they use the new password
        await SupabaseService.client.auth.signOut();

        // Navigate to sign in page after a delay
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/auth', (route) => false);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        String errorMessage = 'Failed to update password';
        if (e.toString().contains('session_not_found') ||
            e.toString().contains('invalid_grant') ||
            e.toString().contains('No session')) {
          errorMessage =
              'Password reset link has expired or is invalid. Please request a new one.';
        } else if (e.toString().contains('same_password')) {
          errorMessage =
              'New password must be different from your current password.';
        } else if (e.toString().contains('Password should be at least')) {
          errorMessage = 'Password must be at least 6 characters long.';
        }

        SnackbarUtils.showError(
          context,
          title: 'Update Failed',
          message: errorMessage,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App logo
                      Container(
                        width: 150,
                        height: 150,
                        child: Image.asset(
                          'assets/images/bonique/auth-logo.png',
                          width: 150,
                          height: 150,
                        ),
                      ),
        
                      const SizedBox(height: 32),
        
                      // Title
                      Text(
                        'Set New Password',
                        style: AuthTextStyles.h1,
                        textAlign: TextAlign.center,
                      ),
        
                      const SizedBox(height: 8),
        
                      // Subtitle
                      Text(
                        'Enter your new password below',
                        style: AuthTextStyles.stat1,
                        textAlign: TextAlign.center,
                      ),
        
                      const SizedBox(height: 32),
        
                      // New Password field
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: !_isNewPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          hintText: 'Enter your new password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isNewPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isNewPasswordVisible = !_isNewPasswordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a new password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
        
                      const SizedBox(height: 24),
        
                      // Confirm Password field
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: !_isConfirmPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Confirm New Password',
                          hintText: 'Re-enter your new password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your new password';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
        
                      const SizedBox(height: 32),
        
                      // Update Password button
                      AuthPrimaryButton(
                        text: 'Update Password',
                        onPressed: _updatePassword,
                        isLoading: _isLoading,
                      ),
        
                      const SizedBox(height: 24),
        
                      // Back to Sign In link
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pushNamedAndRemoveUntil('/auth', (route) => false);
                          },
                          child: RichText(
                            text: TextSpan(
                              style: AuthTextStyles.stat2,
                              children: [
                                const TextSpan(text: 'Remember your password? '),
                                TextSpan(
                                  text: 'Sign In',
                                  style: AuthTextStyles.stat2.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
