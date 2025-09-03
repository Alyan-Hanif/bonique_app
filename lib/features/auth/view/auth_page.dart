import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/auth_viewmodel.dart';
import 'login_page.dart';
import 'signup_page.dart';

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
