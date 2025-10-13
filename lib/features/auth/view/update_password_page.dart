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
  String? _resetCode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get the reset code from route arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> && args['code'] != null) {
      _resetCode = args['code'] as String;
      debugPrint('🔐 Reset code received: $_resetCode');
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

    if (_resetCode == null) {
      SnackbarUtils.showError(
        context,
        title: 'Invalid Link',
        message: 'Reset code not found. Please request a new password reset.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Use Supabase to update password with the reset code
      final response = await SupabaseService.client.auth.verifyOTP(
        type: OtpType.recovery,
        token: _resetCode!,
        email: '', // Not needed for recovery
      );

      if (response.user != null) {
        // Update the password
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

          // Navigate to sign in page after a delay
          Future.delayed(const Duration(milliseconds: 2000), () {
            if (mounted) {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/auth', (route) => false);
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        SnackbarUtils.showError(
          context,
          title: 'Update Failed',
          message: 'Failed to update password: ${e.toString()}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
                        'assets/images/bonique/bonique - Copy-01.png',
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
    );
  }
}
