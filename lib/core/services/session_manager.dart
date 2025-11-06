import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

/// Manages user session, token refresh, and session lifecycle
class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  final SupabaseClient _client = Supabase.instance.client;
  StreamSubscription<AuthState>? _authStateSubscription;
  Timer? _sessionCheckTimer;

  /// Initialize session manager and listen to auth state changes
  void initialize() {
    // Listen to auth state changes
    _authStateSubscription = _client.auth.onAuthStateChange.listen((authState) {
      _handleAuthStateChange(authState);
    });

    // Start periodic session check (every 5 minutes)
    _startSessionChecks();
  }

  /// Handle auth state changes
  void _handleAuthStateChange(AuthState authState) {
    final event = authState.event;
    final session = authState.session;

    print('Auth state changed: $event');

    switch (event) {
      case AuthChangeEvent.signedIn:
        print('✅ User signed in');
        _onSignIn(session);
        break;
      case AuthChangeEvent.signedOut:
        print('🔒 User signed out');
        _onSignOut();
        break;
      case AuthChangeEvent.tokenRefreshed:
        print('🔄 Token refreshed');
        _onTokenRefresh(session);
        break;
      case AuthChangeEvent.userUpdated:
        print('👤 User updated');
        break;
      case AuthChangeEvent.passwordRecovery:
        print('🔑 Password recovery initiated');
        _onPasswordRecovery(session);
        break;
      default:
        break;
    }
  }

  /// Called when password recovery is initiated
  void _onPasswordRecovery(Session? session) {
    if (session != null) {
      print('✅ Password recovery session established');
      print('   User: ${session.user.email}');
      print('   Expires at: ${session.expiresAt}');
      // Don't schedule refresh yet - user needs to update password first
    } else {
      print('⚠️ Password recovery without session');
    }
  }

  /// Called when user signs in
  void _onSignIn(Session? session) {
    if (session != null) {
      print('Session established. Expires at: ${session.expiresAt}');
      _scheduleTokenRefresh(session);
    }
  }

  /// Called when user signs out
  void _onSignOut() {
    _cancelTimers();
  }

  /// Called when token is refreshed
  void _onTokenRefresh(Session? session) {
    if (session != null) {
      print('New session expires at: ${session.expiresAt}');
      _scheduleTokenRefresh(session);
    }
  }

  /// Schedule token refresh before expiration
  void _scheduleTokenRefresh(Session session) {
    // Supabase automatically handles token refresh, but we can monitor it
    final expiresAt = session.expiresAt;
    if (expiresAt != null) {
      final expirationTime = DateTime.fromMillisecondsSinceEpoch(
        expiresAt * 1000,
      );
      final timeUntilExpiry = expirationTime.difference(DateTime.now());

      print('Token expires in: ${timeUntilExpiry.inMinutes} minutes');

      // Log warning if token is about to expire
      if (timeUntilExpiry.inMinutes < 10) {
        print(
          '⚠️ Token expires soon. Auto-refresh should happen automatically.',
        );
      }
    }
  }

  /// Start periodic session checks
  void _startSessionChecks() {
    _sessionCheckTimer?.cancel();
    _sessionCheckTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _checkSessionHealth();
    });
  }

  /// Check if session is still valid and healthy
  Future<void> _checkSessionHealth() async {
    final session = _client.auth.currentSession;

    if (session == null) {
      print('ℹ️ No active session found (user logged out or in recovery flow)');
      return;
    }

    final expiresAt = session.expiresAt;
    if (expiresAt != null) {
      final expirationTime = DateTime.fromMillisecondsSinceEpoch(
        expiresAt * 1000,
      );
      final timeUntilExpiry = expirationTime.difference(DateTime.now());

      if (timeUntilExpiry.isNegative) {
        print('❌ Session expired! Attempting refresh...');
        await refreshSession();
      } else if (timeUntilExpiry.inMinutes < 10) {
        print('⚠️ Session expires in ${timeUntilExpiry.inMinutes} minutes');
      } else {
        print(
          '✅ Session healthy, expires in ${timeUntilExpiry.inMinutes} minutes',
        );
      }
    }
  }

  /// Manually refresh the session
  Future<bool> refreshSession() async {
    try {
      final response = await _client.auth.refreshSession();

      if (response.session != null) {
        print('✅ Session refreshed successfully');
        return true;
      } else {
        print('❌ Failed to refresh session');
        return false;
      }
    } catch (e) {
      print('❌ Error refreshing session: $e');
      return false;
    }
  }

  /// Check if user has an active session
  bool get hasActiveSession {
    final session = _client.auth.currentSession;
    if (session == null) return false;

    final expiresAt = session.expiresAt;
    if (expiresAt == null) return true; // If no expiration, consider active

    final expirationTime = DateTime.fromMillisecondsSinceEpoch(
      expiresAt * 1000,
    );
    return DateTime.now().isBefore(expirationTime);
  }

  /// Get current session
  Session? get currentSession => _client.auth.currentSession;

  /// Get time until session expires (in minutes)
  int? get minutesUntilExpiry {
    final session = _client.auth.currentSession;
    final expiresAt = session?.expiresAt;

    if (expiresAt == null) return null;

    final expirationTime = DateTime.fromMillisecondsSinceEpoch(
      expiresAt * 1000,
    );
    final timeUntilExpiry = expirationTime.difference(DateTime.now());

    return timeUntilExpiry.inMinutes;
  }

  /// Check if session is about to expire (less than 10 minutes)
  bool get isSessionExpiringSoon {
    final minutes = minutesUntilExpiry;
    return minutes != null && minutes < 10;
  }

  /// Cancel all timers and subscriptions
  void _cancelTimers() {
    _sessionCheckTimer?.cancel();
    _sessionCheckTimer = null;
  }

  /// Dispose session manager
  void dispose() {
    _authStateSubscription?.cancel();
    _cancelTimers();
  }

  /// Handle app resuming from background
  Future<void> onAppResume() async {
    print('App resumed - checking session health...');

    // Don't immediately check/refresh - give Supabase time to process any
    // deep links (like password recovery) that might have triggered the resume
    await Future.delayed(const Duration(milliseconds: 2000));

    await _checkSessionHealth();

    // Check if we need to refresh
    // Only attempt refresh if there's actually a session to refresh
    // (not logged out or in password recovery flow)
    final session = _client.auth.currentSession;
    if (session != null && !hasActiveSession) {
      print('Session invalid after resume - attempting refresh...');
      await refreshSession();
    } else if (session == null) {
      print('No session found - user may be logged out or in recovery flow');
    }
  }

  /// Handle network connectivity change
  Future<void> onConnectivityChange(bool hasConnection) async {
    if (hasConnection && !hasActiveSession) {
      print('Connection restored - checking session...');
      await refreshSession();
    }
  }

  /// Clear session (for manual logout or cache clear)
  Future<void> clearSession() async {
    try {
      await _client.auth.signOut();
      _cancelTimers();
      print('✅ Session cleared successfully');
    } catch (e) {
      print('❌ Error clearing session: $e');
      rethrow;
    }
  }
}
