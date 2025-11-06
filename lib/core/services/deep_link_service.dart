import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bonique/core/services/supabase_service.dart';

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
  Future<void> _handlePasswordResetLink(Uri uri) async {
    // Extract tokens/code from fragment or query parameters
    final fragment = uri.fragment;
    final queryParams = uri.queryParameters;

    String? accessToken;
    String? refreshToken;
    String? type;
    String? code; // OTP code for password reset
    String? error;
    String? errorCode;
    String? errorDescription;

    // Check fragment for tokens (Supabase uses fragment for OAuth)
    if (fragment.isNotEmpty) {
      final fragmentParams = Uri.splitQueryString(fragment);
      accessToken = fragmentParams['access_token'];
      refreshToken = fragmentParams['refresh_token'];
      type = fragmentParams['type'];
      code = fragmentParams['code'];
      error = fragmentParams['error'];
      errorCode = fragmentParams['error_code'];
      errorDescription = fragmentParams['error_description'];
    }

    // Also check query parameters as fallback
    accessToken ??= queryParams['access_token'];
    refreshToken ??= queryParams['refresh_token'];
    type ??= queryParams['type'];
    code ??= queryParams['code']; // OTP code is usually in query params
    error ??= queryParams['error'];
    errorCode ??= queryParams['error_code'];
    errorDescription ??= queryParams['error_description'];

    debugPrint('🔐 Password reset link detected');
    debugPrint('   Access Token: ${accessToken != null}');
    debugPrint(
      '   OTP Code: ${code != null ? code.substring(0, 8) + "..." : "null"}',
    );
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

      // Navigate to auth page with error message
      _navigateToRoute(
        '/auth',
        arguments: {'error': errorMessage, 'errorCode': errorCode},
      );
      return;
    }

    // Handle OTP code flow (most common for password reset)
    if (code != null) {
      try {
        debugPrint('🔐 Processing password reset with OTP code...');
        debugPrint('   Code: ${code.substring(0, 8)}...');

        // IMPORTANT: The Supabase SDK automatically processes the deep link
        // when the app opens. We just need to wait for it to complete.
        // The SDK will exchange the code for a session automatically.
        debugPrint('🔐 Waiting for Supabase SDK to process the code...');

        // Give Supabase SDK time to process the deep link
        // Increased delay to ensure SDK completes before checking session
        await Future.delayed(const Duration(milliseconds: 2500));

        // Check if session was established by the SDK
        final currentUser = SupabaseService.client.auth.currentUser;

        if (currentUser != null) {
          debugPrint(
            '✅ Session established automatically for: ${currentUser.email}',
          );

          // Navigate to password change page
          _navigateToRoute(
            '/update-password',
            arguments: {'verified': true, 'email': currentUser.email},
            replace: true,
          );
        } else {
          // If automatic processing failed, show error
          throw Exception('Session was not established automatically');
        }
      } catch (e) {
        debugPrint('❌ Error processing password reset: $e');

        String errorMessage = 'Failed to verify password reset link.';
        if (e.toString().contains('expired') ||
            e.toString().contains('invalid')) {
          errorMessage =
              'Password reset link has expired or is invalid. Please request a new one.';
        } else if (e.toString().contains('Session was not established')) {
          errorMessage =
              'Could not verify the reset link. The link may have expired. Please request a new password reset.';
        }

        // Navigate to auth page with error
        _navigateToRoute('/auth', arguments: {'error': errorMessage});
      }
    }
    // Handle direct access token flow (alternative flow)
    else if (accessToken != null && type == 'recovery') {
      try {
        debugPrint('🔐 Processing password reset with access token...');
        debugPrint('   Access Token: ${accessToken.substring(0, 20)}...');
        debugPrint(
          '   Refresh Token: ${refreshToken != null ? "Present" : "Missing"}',
        );

        // IMPORTANT: Supabase SDK automatically handles the session when the app opens with
        // the deep link URL. We don't need to manually set the session.
        // Just wait a moment for Supabase to process the URL
        await Future.delayed(const Duration(milliseconds: 2500));

        // Check if session was established
        final currentUser = SupabaseService.client.auth.currentUser;
        if (currentUser != null) {
          debugPrint('✅ Session established for: ${currentUser.email}');
        } else {
          debugPrint(
            '⚠️ No session yet, but proceeding to update password page',
          );
        }

        // Navigate to password change page (replace current route to avoid going back to auth)
        // The update password page will verify the session is valid
        _navigateToRoute(
          '/update-password',
          arguments: {
            'token': accessToken,
            'refreshToken': refreshToken,
            'type': type,
          },
          replace: true, // Replace the current route instead of pushing
        );
      } catch (e) {
        debugPrint('❌ Error processing password reset link: $e');

        // Still try to navigate - the update page will handle the error
        _navigateToRoute(
          '/update-password',
          arguments: {
            'token': accessToken,
            'refreshToken': refreshToken,
            'type': type,
          },
          replace: true,
        );
      }
    } else {
      debugPrint('⚠️ Invalid password reset link: missing token or type');

      // Navigate to reset password page with generic error
      _navigateToRoute(
        '/auth',
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
  void _navigateToRoute(
    String route, {
    Object? arguments,
    bool replace = false,
  }) {
    if (_navigatorKey?.currentState == null) {
      debugPrint('⚠️ Navigator not ready yet');
      return;
    }

    // Wait a bit to ensure navigator is ready
    Future.delayed(const Duration(milliseconds: 300), () {
      if (replace) {
        // Use pushReplacementNamed to replace the current route
        _navigatorKey?.currentState?.pushReplacementNamed(
          route,
          arguments: arguments,
        );
      } else {
        _navigatorKey?.currentState?.pushNamed(route, arguments: arguments);
      }
    });
  }

  /// Public method to manually handle a deep link (useful for testing)
  void handleLink(String link) {
    _handleDeepLink(link);
  }
}
