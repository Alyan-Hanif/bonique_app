import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../widgets/auth_widgets.dart';

class SignInPage extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onSignUp;

  const SignInPage({super.key, required this.onBack, required this.onSignUp});

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
      await authViewModel.signIn(
        _emailController.text,
        _passwordController.text,
      );
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button and app logo
                Row(
                  children: [
                    IconButton(
                      onPressed: widget.onBack,
                      icon: const Icon(Icons.arrow_back, color: kTextPrimary),
                    ),
                    const Spacer(),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Title
                Text('Sign-In to your account!', style: AuthTextStyles.h3),

                const SizedBox(height: 8),

                Text(
                  'Enter information to Sign In to your account.',
                  style: AuthTextStyles.stat1,
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

                const SizedBox(height: 16),

                // Forgot password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement forgot password
                    },
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

                // Error message
                if (authState.error != null)
                  AuthErrorMessage(message: authState.error!),

                if (authState.error != null) const SizedBox(height: 16),

                // Sign In button
                AuthPrimaryButton(
                  text: 'Sign In',
                  onPressed: _handleSignIn,
                  isLoading: authState.isLoading,
                ),

                const Spacer(),

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
    );
  }
}
