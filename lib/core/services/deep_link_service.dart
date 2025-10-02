import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';

/// Service to handle deep linking using app_links
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  StreamSubscription? _linkSubscription;
  GlobalKey<NavigatorState>? _navigatorKey;
  late AppLinks _appLinks;

  /// Initialize deep link handling
  /// Pass the navigator key to enable programmatic navigation
  Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    _navigatorKey = navigatorKey;
    _appLinks = AppLinks();

    // Handle initial link if app was opened from cold start
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint('🔗 Initial deep link: $initialUri');
        _handleDeepLink(initialUri.toString());
      }
    } catch (e) {
      debugPrint('❌ Error getting initial link: $e');
    }

    // Listen for deep links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        debugPrint('🔗 Deep link received while running: $uri');
        _handleDeepLink(uri.toString());
      },
      onError: (err) {
        debugPrint('❌ Deep link error: $err');
      },
    );
  }

  /// Dispose resources and cancel subscriptions
  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }

  /// Handle different types of deep links
  void _handleDeepLink(String link) {
    debugPrint('📱 Processing deep link: $link');

    final uri = Uri.parse(link);

    // Handle password reset deep link
    // Format: io.supabase.bonique://reset-password#access_token=xxx&type=recovery
    if (uri.host == 'reset-password' || uri.path == '/reset-password') {
      _handlePasswordResetLink(uri);
      return;
    }

    // Handle profile deep link
    // Format: io.supabase.bonique://profile
    if (uri.host == 'profile' || uri.path == '/profile') {
      _navigateToRoute('/home');
      return;
    }

    // Handle home deep link
    // Format: io.supabase.bonique://home
    if (uri.host == 'home' || uri.path == '/home') {
      _navigateToRoute('/home');
      return;
    }

    // Handle login callback (for OAuth flows)
    // Format: io.supabase.bonique://login-callback
    if (uri.host == 'login-callback' || uri.path == '/login-callback') {
      _handleLoginCallback(uri);
      return;
    }

    // Default handling for unknown deep links
    debugPrint('⚠️ Unhandled deep link: $link');
  }

  /// Handle password reset deep link from Supabase
  void _handlePasswordResetLink(Uri uri) {
    // Extract tokens from fragment or query parameters
    final fragment = uri.fragment;
    final queryParams = uri.queryParameters;

    String? accessToken;
    String? type;
    String? error;
    String? errorCode;
    String? errorDescription;

    // Check fragment for tokens (Supabase uses fragment for OAuth)
    if (fragment.isNotEmpty) {
      final fragmentParams = Uri.splitQueryString(fragment);
      accessToken = fragmentParams['access_token'];
      type = fragmentParams['type'];
      error = fragmentParams['error'];
      errorCode = fragmentParams['error_code'];
      errorDescription = fragmentParams['error_description'];
    }

    // Also check query parameters as fallback
    accessToken ??= queryParams['access_token'];
    type ??= queryParams['type'];
    error ??= queryParams['error'];
    errorCode ??= queryParams['error_code'];
    errorDescription ??= queryParams['error_description'];

    debugPrint('🔐 Password reset link detected');
    debugPrint('   Token present: ${accessToken != null}');
    debugPrint('   Type: $type');
    debugPrint('   Error: $error');
    debugPrint('   Error code: $errorCode');

    // Check if there's an error in the deep link
    if (error != null) {
      String errorMessage = 'Password reset link error';

      if (errorCode == 'otp_expired') {
        errorMessage =
            'This password reset link has expired. Please request a new one.';
      } else if (errorDescription != null) {
        errorMessage = Uri.decodeComponent(
          errorDescription.replaceAll('+', ' '),
        );
      }

      debugPrint('❌ Password reset error: $errorMessage');

      // Navigate to reset password page with error message
      _navigateToRoute(
        '/reset-password',
        arguments: {'error': errorMessage, 'errorCode': errorCode},
      );
      return;
    }

    if (accessToken != null && type == 'recovery') {
      // Navigate to password change page with valid token
      _navigateToRoute(
        '/change-password',
        arguments: {'token': accessToken, 'type': type},
      );
    } else {
      debugPrint('⚠️ Invalid password reset link: missing token or type');

      // Navigate to reset password page with generic error
      _navigateToRoute(
        '/reset-password',
        arguments: {
          'error': 'Invalid password reset link. Please request a new one.',
        },
      );
    }
  }

  /// Handle OAuth login callback
  void _handleLoginCallback(Uri uri) {
    final fragment = uri.fragment;
    final queryParams = uri.queryParameters;

    String? accessToken;
    String? refreshToken;

    // Check fragment for tokens
    if (fragment.isNotEmpty) {
      final fragmentParams = Uri.splitQueryString(fragment);
      accessToken = fragmentParams['access_token'];
      refreshToken = fragmentParams['refresh_token'];
    }

    // Also check query parameters
    accessToken ??= queryParams['access_token'];
    refreshToken ??= queryParams['refresh_token'];

    debugPrint('🔐 Login callback detected');
    debugPrint('   Access token present: ${accessToken != null}');
    debugPrint('   Refresh token present: ${refreshToken != null}');

    if (accessToken != null) {
      // Navigate to home after successful login
      _navigateToRoute('/home');
    }
  }

  /// Navigate to a specific route using the navigator key
  void _navigateToRoute(String route, {Object? arguments}) {
    if (_navigatorKey?.currentState == null) {
      debugPrint('⚠️ Navigator not ready yet');
      return;
    }

    // Wait a bit to ensure navigator is ready
    Future.delayed(const Duration(milliseconds: 300), () {
      _navigatorKey?.currentState?.pushNamed(route, arguments: arguments);
    });
  }

  /// Public method to manually handle a deep link (useful for testing)
  void handleLink(String link) {
    _handleDeepLink(link);
  }
}
