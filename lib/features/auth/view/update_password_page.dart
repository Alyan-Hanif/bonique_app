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
  String? _resetToken;
  String? _refreshToken;
  bool _sessionEstablished = false;

  // Password validation state
  String? _newPasswordError;
  String? _confirmPasswordError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get the reset token from route arguments (sent from deep link)
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      // Try 'token' first (from deep link), then 'code' for backward compatibility
      _resetToken = args['token'] as String? ?? args['code'] as String?;
      _refreshToken = args['refreshToken'] as String?;
      debugPrint(
        '🔐 Reset token received: ${_resetToken != null ? "Yes" : "No"}',
      );
      debugPrint(
        '🔐 Refresh token received: ${_refreshToken != null ? "Yes" : "No"}',
      );

      // Try to establish session if we have tokens
      if (_resetToken != null && !_sessionEstablished) {
        _establishSession();
      }
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _establishSession() async {
    try {
      debugPrint('🔐 Attempting to establish Supabase session...');

      // Check if session already exists
      final existingUser = SupabaseService.client.auth.currentUser;
      if (existingUser != null) {
        debugPrint('✅ Session already exists: ${existingUser.email}');
        _sessionEstablished = true;
        return;
      }

      // If we have both tokens, try to recover the session
      if (_resetToken != null && _refreshToken != null) {
        debugPrint('🔐 Recovering session with tokens...');

        // Try to recover the session
        final response = await SupabaseService.client.auth.recoverSession(
          'access_token=$_resetToken&refresh_token=$_refreshToken',
        );

        if (response.user != null) {
          debugPrint(
            '✅ Session recovered successfully: ${response.user!.email}',
          );
          _sessionEstablished = true;
        } else {
          debugPrint('❌ Failed to recover session');
        }
      }
    } catch (e) {
      debugPrint('❌ Error establishing session: $e');
    }
  }

  // Password validation methods
  bool _validateNewPassword(String password) {
    if (password.isEmpty) {
      setState(() {
        _newPasswordError = 'Password is required';
      });
      return false;
    }

    if (password.length < 8) {
      setState(() {
        _newPasswordError = 'Password must be at least 8 characters';
      });
      return false;
    }

    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      setState(() {
        _newPasswordError =
            'Password must contain at least one uppercase letter';
      });
      return false;
    }

    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      setState(() {
        _newPasswordError =
            'Password must contain at least one lowercase letter';
      });
      return false;
    }

    // Check for at least one number
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      setState(() {
        _newPasswordError = 'Password must contain at least one number';
      });
      return false;
    }

    // Check for at least one special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\\/~`]').hasMatch(password)) {
      setState(() {
        _newPasswordError =
            r'Password must contain at least one special character (!@#$%^&*...)';
      });
      return false;
    }

    setState(() {
      _newPasswordError = null;
    });
    return true;
  }

  bool _validateConfirmPassword(String confirmPassword) {
    if (confirmPassword.isEmpty) {
      setState(() {
        _confirmPasswordError = 'Please confirm your password';
      });
      return false;
    }

    if (confirmPassword != _newPasswordController.text) {
      setState(() {
        _confirmPasswordError = 'Passwords do not match';
      });
      return false;
    }

    setState(() {
      _confirmPasswordError = null;
    });
    return true;
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate passwords
    final isNewPasswordValid = _validateNewPassword(
      _newPasswordController.text,
    );
    final isConfirmPasswordValid = _validateConfirmPassword(
      _confirmPasswordController.text,
    );

    if (!isNewPasswordValid || !isConfirmPasswordValid) {
      return;
    }

    // Check if we have a valid session from the deep link
    // When user clicks the reset link, Supabase SDK automatically handles the session
    final currentUser = SupabaseService.client.auth.currentUser;

    if (currentUser == null) {
      // If no session, the link might be expired or invalid
      throw Exception('session_not_found');
    }

    debugPrint(
      '🔐 User session found, updating password for: ${currentUser.email}',
    );

    setState(() {
      _isLoading = true;
    });

    try {
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
                    AuthInputField(
                      controller: _newPasswordController,
                      label: 'New Password',
                      placeholder: 'Enter your new password',
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: _isNewPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      isPassword: true,
                      isPasswordVisible: _isNewPasswordVisible,
                      onSuffixIconPressed: () {
                        setState(() {
                          _isNewPasswordVisible = !_isNewPasswordVisible;
                        });
                      },
                      errorText: _newPasswordError,
                      onChanged: (value) {
                        _validateNewPassword(value);
                      },
                    ),

                    const SizedBox(height: 24),

                    // Confirm Password field
                    AuthInputField(
                      controller: _confirmPasswordController,
                      label: 'Confirm New Password',
                      placeholder: 'Re-enter your new password',
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: _isConfirmPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      isPassword: true,
                      isPasswordVisible: _isConfirmPasswordVisible,
                      onSuffixIconPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                      errorText: _confirmPasswordError,
                      onChanged: (value) {
                        _validateConfirmPassword(value);
                      },
                    ),

                    const SizedBox(height: 32),

                    // Password requirements info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Password Requirements:',
                            style: AuthTextStyles.h2.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildRequirementItem('At least 8 characters'),
                          _buildRequirementItem('One uppercase letter (A-Z)'),
                          _buildRequirementItem('One lowercase letter (a-z)'),
                          _buildRequirementItem('One number (0-9)'),
                          _buildRequirementItem(
                            'One special character (!@#\$%...)',
                          ),
                        ],
                      ),
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

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AuthTextStyles.stat3.copyWith(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}
