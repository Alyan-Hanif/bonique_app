import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../widgets/auth_widgets.dart';

class LoginPage extends ConsumerStatefulWidget {
  final VoidCallback onSwitchToSignup;

  const LoginPage({super.key, required this.onSwitchToSignup});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authViewModel = ref.read(authViewModelProvider.notifier);
      final success = await authViewModel.signIn(
        _emailController.text,
        _passwordController.text,
      );

      // Note: Navigation will be handled by the listener in AuthPage
      // No need to call widget.onSwitchToSignup() here
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
      body: AuthGradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: AuthCard(
                title: 'Welcome Back',
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email field
                        AuthFormField(
                          controller: _emailController,
                          hint: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          errorText: authState.emailError,
                          onChanged: _onEmailChanged,
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        AuthFormField(
                          controller: _passwordController,
                          hint: 'Password',
                          obscure: true,
                          errorText: authState.passwordError,
                          onChanged: _onPasswordChanged,
                        ),
                        const SizedBox(height: 24),

                        // Error message
                        if (authState.error != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Text(
                              authState.error!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),

                        // Login button
                        AuthCTAButton(
                          label: authState.isLoading
                              ? 'Signing In...'
                              : 'Sign In',
                          onPressed: authState.isLoading ? null : _handleLogin,
                        ),

                        const SizedBox(height: 24),

                        // Switch to signup
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account? "),
                            TextButton(
                              onPressed: widget.onSwitchToSignup,
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: kAuthAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
