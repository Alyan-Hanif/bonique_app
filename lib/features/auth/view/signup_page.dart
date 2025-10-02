import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../widgets/auth_widgets.dart';
import '../../../core/utils/snackbar_utils.dart';

class SignUpPage extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onSignIn;

  const SignUpPage({super.key, required this.onBack, required this.onSignIn});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    // _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      final authViewModel = ref.read(authViewModelProvider.notifier);
      final success = await authViewModel.signUp(
        _emailController.text,
        _passwordController.text,
        _nameController.text,
        // _confirmPasswordController.text,
      );

      if (mounted) {
        if (success) {
          SnackbarUtils.showSuccess(
            context,
            title: 'Account Created!',
            message: 'Please check your email to verify your account.',
          );
        } else {
          // Get the error from state
          final error = ref.read(authViewModelProvider).error;
          if (error != null) {
            SnackbarUtils.showError(
              context,
              title: 'Sign Up Failed',
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

  void _onNameChanged(String value) {
    final authViewModel = ref.read(authViewModelProvider.notifier);
    authViewModel.validateName(value);
  }

  void _onEmailChanged(String value) {
    final authViewModel = ref.read(authViewModelProvider.notifier);
    authViewModel.validateEmail(value);
  }

  void _onPasswordChanged(String value) {
    final authViewModel = ref.read(authViewModelProvider.notifier);
    authViewModel.validatePassword(value);
  }

  // void _onConfirmPasswordChanged(String value) {
  //   final authViewModel = ref.read(authViewModelProvider.notifier);
  //   authViewModel.validateConfirmPassword(_passwordController.text, value);
  // }

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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Back button and app logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // IconButton(
                      //   onPressed: widget.onBack,
                      //   icon: const Icon(Icons.arrow_back, color: kTextPrimary),
                      // ),
                      // const Spacer(),
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
                      'Create a new account!',
                      style: AuthTextStyles.h1,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Center(
                    child: Text(
                      'Enter information to create a new account.',
                      style: AuthTextStyles.stat1,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Name field
                  AuthInputField(
                    controller: _nameController,
                    label: 'Enter your full name',
                    placeholder: 'Raheema Ali',
                    prefixIcon: Icons.person_outline,
                    errorText: authState.nameError,
                    onChanged: _onNameChanged,
                  ),

                  const SizedBox(height: 24),

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

                  // const SizedBox(height: 24),
                  //
                  // // Confirm Password field
                  // AuthInputField(
                  //   controller: _confirmPasswordController,
                  //   label: 'Confirm your password',
                  //   placeholder: '*****',
                  //   prefixIcon: Icons.lock_outline,
                  //   suffixIcon: authState.isConfirmPasswordVisible
                  //       ? Icons.visibility_off
                  //       : Icons.visibility,
                  //   isPassword: true,
                  //   isPasswordVisible: authState.isConfirmPasswordVisible,
                  //   onSuffixIconPressed: () {
                  //     ref
                  //         .read(authViewModelProvider.notifier)
                  //         .toggleConfirmPasswordVisibility();
                  //   },
                  //   errorText: authState.confirmPasswordError,
                  //   onChanged: _onConfirmPasswordChanged,
                  // ),

                  // const SizedBox(height: 24),

                  // Terms checkbox
                  TermsCheckbox(
                    value: authState.agreeToTerms,
                    onChanged: (value) {
                      ref
                          .read(authViewModelProvider.notifier)
                          .toggleTermsAgreement();
                    },
                  ),

                  const SizedBox(height: 32),

                  // // Error message
                  // if (authState.error != null)
                  //   AuthErrorMessage(message: authState.error!),
                  //
                  // if (authState.error != null) const SizedBox(height: 16),

                  // Sign Up button
                  AuthPrimaryButton(
                    text: 'Sign Up',
                    onPressed: _handleSignUp,
                    isLoading: authState.isLoading,
                  ),

                  const SizedBox(height: 14),

                  // Divider
                  const AuthDivider(),

                  const SizedBox(height: 14),

                  // Google Sign In button
                  GoogleSignInButton(onPressed: _handleGoogleSignIn),

                  // const Spacer(),

                  // Sign In link
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: AuthTextStyles.stat2,
                        children: [
                          const TextSpan(text: 'Already have an account? '),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: widget.onSignIn,
                              child: Text(
                                'Sign In',
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
    );
  }
}
