import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../widgets/auth_widgets.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const ResetPasswordPage({super.key, required this.onBack});

  static const route = '/reset-password';

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authViewModel = ref.read(authViewModelProvider.notifier);
      final success = await authViewModel.resetPassword(
        _emailController.text.trim(),
      );

      if (success && mounted) {
        setState(() {
          _emailSent = true;
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send reset email. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: _emailSent ? _buildSuccessView() : _buildResetForm(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResetForm() {
    final authState = ref.watch(authViewModelProvider);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Back button and app logo
          Row(
            children: [
              IconButton(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back, color: kPrimaryColor),
              ),
              const Spacer(),
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white,
                  size: 39,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 48), // Balance the back button
            ],
          ),

          const SizedBox(height: 32),

          // Forgot password icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_reset, color: kPrimaryColor, size: 40),
          ),

          const SizedBox(height: 24),

          // Title
          Text(
            'Forgot Password?',
            style: AuthTextStyles.h1,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Enter your email address and we\'ll send you a link to reset your password.',
              style: AuthTextStyles.stat1,
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 32),

          // Email field
          AuthInputField(
            controller: _emailController,
            label: 'Enter your email address',
            placeholder: 'example@gmail.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            errorText: authState.emailError,
            onChanged: (value) {
              ref.read(authViewModelProvider.notifier).validateEmail(value);
            },
          ),

          const SizedBox(height: 32),

          // Error message
          if (authState.error != null)
            AuthErrorMessage(message: authState.error!),

          if (authState.error != null) const SizedBox(height: 16),

          // Send Reset Link button
          AuthPrimaryButton(
            text: 'Send Reset Link',
            onPressed: _handleResetPassword,
            isLoading: _isLoading,
          ),

          const SizedBox(height: 24),

          // Back to Sign In link
          Center(
            child: GestureDetector(
              onTap: widget.onBack,
              child: RichText(
                text: TextSpan(
                  style: AuthTextStyles.stat2,
                  children: [
                    const TextSpan(text: 'Remember your password? '),
                    TextSpan(
                      text: 'Sign In',
                      style: AuthTextStyles.stat2.copyWith(
                        color: kPrimaryColor,
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
    );
  }

  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Success icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 60,
          ),
        ),

        const SizedBox(height: 32),

        // Success title
        Text(
          'Email Sent!',
          style: AuthTextStyles.h1,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        // Success message
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'We\'ve sent a password reset link to\n${_emailController.text.trim()}',
            style: AuthTextStyles.stat1,
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Please check your email and follow the instructions to reset your password.',
            style: AuthTextStyles.stat2.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 40),

        // Resend email button
        TextButton.icon(
          onPressed: () {
            setState(() {
              _emailSent = false;
            });
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Send Again'),
          style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
        ),

        const SizedBox(height: 16),

        // Back to Sign In button
        AuthPrimaryButton(text: 'Back to Sign In', onPressed: widget.onBack),
      ],
    );
  }
}
