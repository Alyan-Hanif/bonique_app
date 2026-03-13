import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../widgets/auth_widgets.dart';
import '../../../core/utils/snackbar_utils.dart';

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
  String? _deepLinkError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check if there's an error from deep link
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> && args['error'] != null) {
      _deepLinkError = args['error'] as String;

      // Show error in awesome SnackBar once
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _deepLinkError != null) {
          SnackbarUtils.showError(
            context,
            title: 'Link Expired!',
            message: _deepLinkError!,
          );
        }
      });
    }
  }

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
        SnackbarUtils.showError(
          context,
          title: 'Failed!',
          message: 'Failed to send reset email. Please try again.',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        SnackbarUtils.showError(
          context,
          title: 'Error!',
          message: e.toString(),
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
              child: _emailSent ? _buildSuccessView() : _buildResetForm(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResetForm() {
    final authState = ref.watch(authViewModelProvider);
    final primary = Theme.of(context).colorScheme.primary;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Back button and app logo row
          Row(
            children: [
              IconButton(
                onPressed: widget.onBack,
                icon: Icon(Icons.arrow_back, color: primary),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              ),
              Expanded(
                child: Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/bonique/logo.JPG',
                        fit: BoxFit.cover,
                        width: 80,
                        height: 80,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),

          const SizedBox(height: 28),

          // Forgot password icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.lock_reset, color: primary, size: 40),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Forgot Password?',
            style: AuthTextStyles.h1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Enter your email address and we\'ll send you a link to reset your password.',
              style: AuthTextStyles.stat1,
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 28),

          AuthInputField(
            controller: _emailController,
            label: 'Email address',
            placeholder: 'example@gmail.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            errorText: authState.emailError,
            onChanged: (value) {
              ref.read(authViewModelProvider.notifier).validateEmail(value);
            },
          ),

          if (_deepLinkError != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _deepLinkError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (authState.error != null) ...[
            const SizedBox(height: 16),
            AuthErrorMessage(message: authState.error!),
          ],

          const SizedBox(height: 28),

          Center(
            child: AuthPrimaryButton(
              text: 'Send Reset Link',
              onPressed: _handleResetPassword,
              isLoading: _isLoading,
            ),
          ),

          const SizedBox(height: 24),

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
                        color: primary,
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
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 56,
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Email Sent!',
          style: AuthTextStyles.h1,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'We\'ve sent a password reset link to\n${_emailController.text.trim()}',
            style: AuthTextStyles.stat1,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Please check your email and follow the instructions to reset your password.',
            style: AuthTextStyles.stat2.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 32),
        Center(
          child: TextButton.icon(
            onPressed: () => setState(() => _emailSent = false),
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text('Send Again'),
            style: TextButton.styleFrom(foregroundColor: primary),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: AuthPrimaryButton(
            text: 'Back to Sign In',
            onPressed: widget.onBack,
          ),
        ),
      ],
    );
  }
}
