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

class SignupPage extends ConsumerStatefulWidget {
  final VoidCallback onSwitchToLogin;

  const SignupPage({super.key, required this.onSwitchToLogin});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      final authViewModel = ref.read(authViewModelProvider.notifier);
      final success = await authViewModel.signUp(
        _emailController.text,
        _passwordController.text,
        _confirmPasswordController.text,
      );

      // Note: Navigation will be handled by the listener in AuthPage
      // No need to call widget.onSwitchToLogin() here
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

  void _onConfirmPasswordChanged(String value) {
    final authViewModel = ref.read(authViewModelProvider.notifier);
    authViewModel.validateConfirmPassword(_passwordController.text, value);
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
                title: 'Create Account',
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
                        const SizedBox(height: 16),

                        // Confirm Password field
                        AuthFormField(
                          controller: _confirmPasswordController,
                          hint: 'Confirm Password',
                          obscure: true,
                          errorText: authState.confirmPasswordError,
                          onChanged: _onConfirmPasswordChanged,
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

                        // Signup button
                        AuthCTAButton(
                          label: authState.isLoading
                              ? 'Creating Account...'
                              : 'Sign Up',
                          onPressed: authState.isLoading ? null : _handleSignup,
                        ),

                        const SizedBox(height: 24),

                        // Switch to login
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account? "),
                            TextButton(
                              onPressed: widget.onSwitchToLogin,
                              child: const Text(
                                'Sign In',
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

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  static const String route = '/auth';

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  bool _isLogin = true;

  @override
  void initState() {
    super.initState();
    // Check if user is already logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  void _checkAuthStatus() {
    final authViewModel = ref.read(authViewModelProvider.notifier);
    if (authViewModel.isUserLoggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for auth state changes
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });

    return Scaffold(
      body: _isLogin
          ? LoginPage(onSwitchToSignup: () => setState(() => _isLogin = false))
          : SignupPage(onSwitchToLogin: () => setState(() => _isLogin = true)),
    );
  }
}
