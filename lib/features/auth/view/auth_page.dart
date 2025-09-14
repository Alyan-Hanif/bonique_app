import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/auth_viewmodel.dart';
import 'account_page.dart';
import 'signin_page.dart';
import 'signup_page.dart';

enum AuthScreen { account, signIn, signUp }

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  static const String route = '/auth';

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  AuthScreen _currentScreen = AuthScreen.account;

  @override
  void initState() {
    super.initState();
    // Remove automatic auth check - let users manually sign in
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _checkAuthStatus();
    // });
  }

  // Remove or comment out the _checkAuthStatus method
  // void _checkAuthStatus() {
  //   final authViewModel = ref.read(authViewModelProvider.notifier);
  //   if (authViewModel.isUserLoggedIn) {
  //     Navigator.pushReplacementNamed(context, '/home');
  //   }
  // }

  void _navigateToSignIn() {
    setState(() {
      _currentScreen = AuthScreen.signIn;
    });
  }

  void _navigateToSignUp() {
    setState(() {
      _currentScreen = AuthScreen.signUp;
    });
  }

  void _navigateBack() {
    setState(() {
      _currentScreen = AuthScreen.account;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen for auth state changes
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });

    return Scaffold(body: _buildCurrentScreen());
  }

  Widget _buildCurrentScreen() {
    switch (_currentScreen) {
      case AuthScreen.account:
        return AccountPage(
          onSignIn: _navigateToSignIn,
          onCreateAccount: _navigateToSignUp,
        );
      case AuthScreen.signIn:
        return SignInPage(onBack: _navigateBack, onSignUp: _navigateToSignUp);
      case AuthScreen.signUp:
        return SignUpPage(onBack: _navigateBack, onSignIn: _navigateToSignIn);
    }
  }
}
