import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/auth_viewmodel.dart';
import 'account_page.dart';
import 'signin_page.dart';
import 'signup_page.dart';
import 'reset_password_page.dart';
import 'body_picture_upload_page.dart';

enum AuthScreen { account, signIn, signUp, resetPassword }

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _currentScreen = AuthScreen.signIn;
        });
      }
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

  void _navigateToResetPassword() {
    setState(() {
      _currentScreen = AuthScreen.resetPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen for auth state changes
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      // ENFORCE: Only navigate if user is logged in AND exists in database
      if (next.isLoggedIn && next.currentUserModel != null) {
        // Check if user has uploaded body picture
        if (!next.currentUserModel!.hasUploadedBodyPic) {
          // Navigate to body picture upload page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const BodyPictureUploadPage(),
            ),
          );
        } else {
          // Navigate to home
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    });

    return Scaffold(
      body: KeyedSubtree(
        key: ValueKey(_currentScreen),
        child: _buildCurrentScreen(),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentScreen) {
      case AuthScreen.account:
        return AccountPage(
          onSignIn: _navigateToSignIn,
          onCreateAccount: _navigateToSignIn,
          onContinueWithEmail: (context) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (ctx) => SignInPage(
                  onBack: () => Navigator.pop(ctx),
                  onSignUp: () {
                    Navigator.pop(ctx);
                    Navigator.of(ctx).push(
                      MaterialPageRoute<void>(
                        builder: (signUpCtx) => SignUpPage(
                          onBack: () => Navigator.pop(signUpCtx),
                          onSignIn: () => Navigator.pop(signUpCtx),
                        ),
                      ),
                    );
                  },
                  onForgotPassword: () {
                    Navigator.pop(ctx);
                    Navigator.of(ctx).push(
                      MaterialPageRoute<void>(
                        builder: (resetCtx) => ResetPasswordPage(
                          onBack: () => Navigator.pop(resetCtx),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      case AuthScreen.signIn:
        return SignInPage(
          onBack: _navigateBack,
          onSignUp: _navigateToSignUp,
          onForgotPassword: _navigateToResetPassword,
        );
      case AuthScreen.signUp:
        return SignUpPage(onBack: _navigateBack, onSignIn: _navigateToSignIn);
      case AuthScreen.resetPassword:
        return ResetPasswordPage(onBack: _navigateBack);
    }
  }
}
