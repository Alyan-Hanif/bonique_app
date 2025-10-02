import 'package:bonique/core/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../widgets/auth_widgets.dart';

class SignInPage extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onSignUp;
  final VoidCallback onForgotPassword;

  const SignInPage({
    super.key,
    required this.onBack,
    required this.onSignUp,
    required this.onForgotPassword,
  });

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() async {
    if (_formKey.currentState!.validate()) {
      final authViewModel = ref.read(authViewModelProvider.notifier);
      final success = await authViewModel.signIn(
        _emailController.text,
        _passwordController.text,
      );

      if (mounted) {
        if (success) {
          SnackbarUtils.showSuccess(
            context,
            title: 'Welcome Back!',
            message: 'You have successfully signed in.',
          );
        } else {
          // Get the error from state
          final error = ref.read(authViewModelProvider).error;
          if (error != null) {
            SnackbarUtils.showError(
              context,
              title: 'Sign In Failed',
              message: error,
            );
          }
        }
      }
    }
  }

  void _handleGoogleSignIn() async {
    final authViewModel = ref.read(authViewModelProvider.notifier);
    final success = await authViewModel.signInWithGoogle();

    if (mounted) {
      if (success) {
        SnackbarUtils.showSuccess(
          context,
          title: 'Welcome!',
          message: 'Google sign-in successful!',
        );
      } else {
        // Get the error from state
        final error = ref.read(authViewModelProvider).error;
        if (error != null) {
          SnackbarUtils.showError(
            context,
            title: 'Google Sign In Failed',
            message: error,
          );
        }
      }
    }
  }

  void _onEmailChanged(String value) {
    final authViewModel = ref.read(authViewModelProvider.notifier);
    authViewModel.validateEmail(value);
  }

  void _onPasswordChanged(String value) {
    final authViewModel = ref.read(authViewModelProvider.notifier);
    authViewModel.validatePassword(value);
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
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Back button and app logo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 150,
                          height: 150,
                          child: Image.asset(
                            'assets/images/bonique/bonique - Copy-06.png',
                            width: 150,
                            height: 150,
                          ),
                        ),
                      ],
                    ),

                    // const SizedBox(height: 32),

                    // Title
                    Center(
                      child: Text(
                        'Sign-In to your account!',
                        style: AuthTextStyles.h1,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Center(
                      child: Text(
                        'Enter information to Sign In to your account.',
                        style: AuthTextStyles.stat1,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Email field
                    AuthInputField(
                      controller: _emailController,
                      label: 'Enter your email address',
                      placeholder: 'raheema@gmail.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      errorText: authState.emailError,
                      onChanged: _onEmailChanged,
                    ),

                    const SizedBox(height: 24),

                    // Password field
                    AuthInputField(
                      controller: _passwordController,
                      label: 'Enter your password',
                      placeholder: '*****',
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: authState.isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      isPassword: true,
                      isPasswordVisible: authState.isPasswordVisible,
                      onSuffixIconPressed: () {
                        ref
                            .read(authViewModelProvider.notifier)
                            .togglePasswordVisibility();
                      },
                      errorText: authState.passwordError,
                      onChanged: _onPasswordChanged,
                    ),

                    // Forgot password link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: widget.onForgotPassword,
                        child: Text(
                          'Forgot Password?',
                          style: AuthTextStyles.stat2.copyWith(
                            color: kPrimaryColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // // Error message
                    // if (authState.error != null)
                    //   AuthErrorMessage(message: authState.error!),
                    //
                    // if (authState.error != null) const SizedBox(height: 16),

                    // Sign In button
                    AuthPrimaryButton(
                      text: 'Sign In',
                      onPressed: _handleSignIn,
                      isLoading: authState.isLoading,
                    ),

                    const SizedBox(height: 14),

                    // Divider
                    const AuthDivider(),

                    const SizedBox(height: 14),

                    // Google Sign In button
                    GoogleSignInButton(onPressed: _handleGoogleSignIn),

                    const SizedBox(height: 20),

                    // Sign Up link
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: AuthTextStyles.stat2,
                          children: [
                            const TextSpan(text: "Don't have an account? "),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: widget.onSignUp,
                                child: Text(
                                  'Sign Up',
                                  style: AuthTextStyles.stat2.copyWith(
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
