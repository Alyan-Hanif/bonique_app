# Login Edge Cases & Session Management - Implementation Summary

This document outlines all edge cases handled in the login flow, session management, and UI/UX considerations for a robust authentication experience.

---

## ✅ 1. Input Validation Edge Cases

### Empty Fields

**Handled by**: `AuthViewModel.validateEmail()` and `AuthViewModel.validatePassword()`

- **Empty email**: Shows "Email is required"
- **Empty password**: Shows "Password is required"
- **Both empty**: Both errors displayed simultaneously

### Invalid Email Format

**Comprehensive validation includes**:

- No @ symbol: `user.com` ❌
- Invalid domain: `user@com`, `user@.`, `user@domain.` ❌
- Spaces in email: `user @domain.com` ❌
- Multiple @ symbols ❌
- Empty local part: `@domain.com` ❌

**Implementation**: Enhanced regex validation + domain structure checks

### Password Validation

- **Leading/trailing spaces**: Detected and rejected
- **Minimum length**: Enforced (8 characters)
- **Complexity requirements**: Uppercase, lowercase, number, special character

**Note**: For login, we validate format but allow server to handle actual credential validation.

---

## ✅ 2. Authentication Error Handling

### Wrong Email or Password

**Detected patterns**:

- "Invalid login credentials"
- "invalid_credentials"
- "wrong password"
- "incorrect password"

**User-friendly message**:

> "Invalid email or password. Please check your credentials and try again."

### Non-Existent User

**Detected patterns**:

- "User not found"
- "no user found"
- "user does not exist"

**User-friendly message**:

> "No account found with this email. Please sign up first."

### Account Disabled/Deleted

**Account Disabled**:

- Patterns: "user disabled", "account disabled", "user banned"
- Message: "Your account has been disabled. Please contact support for assistance."

**Account Deleted**:

- Patterns: "account deleted", "user deleted"
- Message: "This account no longer exists. Please sign up for a new account."

### Email Not Verified

**Detected patterns**:

- "Email not confirmed"
- "email not verified"
- "confirm your email"
- "verify your email"

**User-friendly message**:

> "Please verify your email address before signing in. Check your inbox for the verification link."

### Rate Limiting

**Detected patterns**:

- "Too many requests"
- "rate limit"
- "too many attempts"

**User-friendly message**:

> "Too many sign-in attempts. Please wait a few minutes and try again."

**Implementation Location**: `lib/features/auth/viewmodel/auth_viewmodel.dart` - `signIn()` method

---

## ✅ 3. Network/Performance Edge Cases

### No Internet Connection

**Proactive Check**:

- Uses `connectivity_plus` package
- Checks connectivity BEFORE attempting login
- Prevents unnecessary API calls

**Reactive Handling**:

- Catches `SocketException`
- Detects network errors during request

**User-friendly message**:

> "No internet connection. Please check your network and try again."

### API/Server Unreachable

**Detected patterns**:

- DNS failure: "unable to resolve host"
- Connection failures: "failed to connect"
- Server errors: 500, 502, 503
- "internal server error"

**Messages**:

- Network errors: "Network error. Please check your internet connection..."
- Server errors: "Server is temporarily unavailable. Please try again later."

### Request Timeout

**Implementation**:

- 30-second timeout on all authentication requests
- Applied in `AuthRepository.signIn()` method

**User-friendly message**:

> "Request timed out. Please check your connection and try again."

### Slow Internet - Loading Spinner

**Implementation**:

- `isLoading` state managed in `AuthViewModel`
- Button shows loading spinner and is disabled during request
- Prevents double submissions

```dart
AuthPrimaryButton(
  text: 'Sign In',
  onPressed: _handleSignIn,
  isLoading: authState.isLoading, // Shows spinner, disables button
)
```

---

## ✅ 4. Session / Token Management

### Overview

**New Component**: `SessionManager` class
**Location**: `lib/core/services/session_manager.dart`

### Access Token Expiration & Auto-Refresh

**Supabase Built-in Features**:

- Automatic token refresh (handled by Supabase SDK)
- `autoRefreshToken: true` enabled in initialization

**Our Enhancement**:

- Monitors token expiration time
- Logs warnings when token expires in < 10 minutes
- Periodic health checks every 5 minutes
- Manual refresh capability

**Implementation**:

```dart
// Token automatically refreshes via Supabase
// SessionManager monitors and provides manual refresh if needed
Future<bool> refreshSession() async {
  final response = await _client.auth.refreshSession();
  return response.session != null;
}
```

### User Clears App Cache/Storage

**Behavior**:

1. **Auth state reset**: Session cleared from local storage
2. **On app relaunch**: `_checkInitialAuthStatus()` runs
3. **User redirected**: Sent to login/onboarding screen
4. **No errors**: Graceful handling, no crashes

**Implementation**: `AuthViewModel._checkInitialAuthStatus()`

### Network Type Switching (WiFi ↔ Mobile Data)

**Handled by**: Connectivity listener in `main.dart`

```dart
// Listen to connectivity changes
_connectivitySubscription = ConnectivityUtils.onConnectivityChanged.listen(
  _onConnectivityChanged,
);

void _onConnectivityChanged(List<ConnectivityResult> results) {
  final hasConnection = results.isNotEmpty &&
                       !results.contains(ConnectivityResult.none);

  if (hasConnection) {
    // Connection restored - check session health
    _sessionManager.onConnectivityChange(true);
  }
}
```

**Behavior**:

- Detects WiFi → Mobile data switch (and vice versa)
- Checks session health when connection restored
- Attempts refresh if session invalid
- Seamless user experience

### Background App - Session Auto-Refresh

**Implementation**: App lifecycle monitoring

```dart
class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // App came back to foreground - check session health
        _sessionManager.onAppResume();
        break;
      // ... other cases
    }
  }
}
```

**Behavior**:

1. User backgrounds app for extended period
2. When app resumes: `onAppResume()` is called
3. Session health check performed
4. If expired: Automatic refresh attempted
5. If refresh fails: User gracefully redirected to login

**Features**:

- ✅ Handles long background periods (hours/days)
- ✅ No abrupt logouts
- ✅ Automatic session recovery when possible
- ✅ Graceful degradation if refresh fails

---

## ✅ 5. UI/UX Edge Cases

### Keyboard Hiding Input Fields

**Implementation**: `SingleChildScrollView` wrapper

```dart
SingleChildScrollView(
  child: Form(
    child: Column(
      children: [
        // Email field
        AuthInputField(...),
        // Password field
        AuthInputField(...),
      ],
    ),
  ),
)
```

**Behavior**:

- Keyboard appears: Screen scrolls automatically
- Active field remains visible
- User can scroll manually if needed
- Works on all screen sizes

### Dark Mode & Device Themes

**Current Implementation**: Light theme only

**Material 3 Ready**: Theme system uses `ColorScheme.fromSeed()`

```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFA45A41),
    primary: const Color(0xFFA45A41),
    secondary: const Color(0xFFE9E2C6),
  ),
  useMaterial3: true,
),
```

**To Add Dark Mode** (Future):

1. Add `darkTheme` parameter to `MaterialApp`
2. Use `Theme.of(context).colorScheme` for all colors
3. Test contrast ratios for accessibility

### Accessibility

**Current Implementation**:

- Semantic labels on input fields
- Proper label/placeholder structure
- Icon prefixes for visual cues

**Screen Reader Support**:

```dart
AuthInputField(
  label: 'Enter your email address',  // Read by screen readers
  placeholder: 'jongsoo@gmail.com',   // Example text
  prefixIcon: Icons.email_outlined,    // Visual indicator
)
```

**Large Text Support**:

- Uses relative text sizing (`AuthTextStyles`)
- Respects system font size settings
- Layout adapts to text size changes

**To Enhance** (Future):

- Add `Semantics` widgets with explicit labels
- Test with TalkBack (Android) / VoiceOver (iOS)
- Ensure all interactive elements have semantic labels
- Add tooltips for icon buttons

### Tap Outside to Dismiss Keyboard

**Implementation**: Automatic with Flutter's `Scaffold`

**Behavior**:

- User taps outside input field
- Keyboard automatically dismisses
- Focus removed from field
- No configuration needed

### Error/Success Messages

**Implementation**: `SnackbarUtils` with `awesome_snackbar_content`

**Features**:

- ✅ Clear, actionable messages
- ✅ Color-coded (red for errors, green for success)
- ✅ Auto-dismissible (with timer)
- ✅ Manually dismissible (swipe or tap)
- ✅ Shows at top of screen
- ✅ Non-blocking (user can continue interacting)
- ✅ Accessible (screen reader announces content)

**Example Usage**:

```dart
// Error message
SnackbarUtils.showError(
  context,
  title: 'Sign In Failed',
  message: 'Invalid email or password.',
);

// Success message
SnackbarUtils.showSuccess(
  context,
  title: 'Welcome Back!',
  message: 'You have successfully signed in.',
);
```

---

## 🔄 6. Additional Edge Cases Covered

### Double Submission Prevention

**Implementation**: Loading state check

```dart
// Prevent double submission by checking if already loading
if (state.isLoading) {
  return false;
}
```

**Behavior**:

- User rapidly taps "Sign In" button
- First tap: Request initiated, loading starts
- Subsequent taps: Ignored (button disabled)
- One request only

### Session Persistence

**Handled by**: Supabase local storage

**Behavior**:

- User signs in successfully
- Session stored locally (encrypted)
- App closed and reopened
- User automatically signed in (if session valid)
- No re-authentication needed

### Concurrent Auth Requests

**Protected by**: State management + loading flag

**Scenario**: User switches between Sign In and Google Sign In rapidly
**Behavior**: Previous request cancelled, new one initiated

---

## 📊 Session Manager Features Summary

| Feature                     | Status | Description                      |
| --------------------------- | ------ | -------------------------------- |
| Token Expiration Monitoring | ✅     | Tracks token expiry time         |
| Auto-Refresh                | ✅     | Supabase handles automatically   |
| Manual Refresh              | ✅     | Available via `refreshSession()` |
| Periodic Health Checks      | ✅     | Every 5 minutes                  |
| App Resume Handling         | ✅     | Checks session on app resume     |
| Network Change Handling     | ✅     | Refreshes on connection restore  |
| Session Validity Check      | ✅     | `hasActiveSession` property      |
| Expiry Warnings             | ✅     | Logs when < 10 min remaining     |
| Auth State Listening        | ✅     | Reacts to sign in/out events     |

---

## 📁 Files Modified/Created

### New Files

1. `lib/core/services/session_manager.dart` - Session and token management
2. `lib/core/utils/connectivity_utils.dart` - Network connectivity utilities
3. `LOGIN_EDGE_CASES_HANDLED.md` - This documentation

### Modified Files

1. `lib/features/auth/viewmodel/auth_viewmodel.dart` - Enhanced error handling
2. `lib/features/auth/repository/auth_repository.dart` - Added timeouts
3. `lib/main.dart` - Added session manager & lifecycle handling
4. `pubspec.yaml` - Added connectivity_plus dependency

---

## 🧪 Testing Recommendations

### Manual Testing Checklist

#### Input Validation

- [ ] Try logging in with empty email - should show error
- [ ] Try logging in with empty password - should show error
- [ ] Try invalid email formats - should show specific errors
- [ ] Enter password with leading/trailing spaces - should be detected

#### Authentication Errors

- [ ] Try wrong password with correct email - should show "Invalid email or password"
- [ ] Try non-existent email - should show "No account found"
- [ ] Try unverified email (if applicable) - should show verification message
- [ ] Try signing up twice with same email - should show "already exists"

#### Network Handling

- [ ] Turn off WiFi/data, try login - should show immediate error
- [ ] Turn on airplane mode, try login - should show no connection error
- [ ] Use slow network (throttle in Chrome DevTools) - should timeout gracefully
- [ ] Switch WiFi to mobile data during login - should complete successfully

#### Session Management

- [ ] Sign in, close app, reopen - should stay signed in
- [ ] Sign in, clear app cache, reopen - should show login screen
- [ ] Sign in, background app for 10+ minutes, resume - should stay signed in
- [ ] Sign in, lose internet, regain internet - session should remain valid

#### UI/UX

- [ ] Tap email field, keyboard should appear and not hide field
- [ ] Enter long email/password, should scroll to keep field visible
- [ ] Tap outside input field, keyboard should dismiss
- [ ] Rapidly tap Sign In button - should only send one request
- [ ] Error messages should appear and be dismissible
- [ ] Success messages should appear and auto-dismiss

#### Accessibility

- [ ] Enable TalkBack/VoiceOver - all fields should be readable
- [ ] Increase system font size to largest - UI should adapt
- [ ] Use only keyboard navigation - should be able to sign in
- [ ] Check color contrast for text/backgrounds

---

## 🚀 Advanced Features

### Session Debugging

Enable detailed session logging:

```dart
// In SessionManager
print('Session expires in: ${minutesUntilExpiry} minutes');
print('Session valid: $hasActiveSession');
print('Token refresh needed: $isSessionExpiringSoon');
```

### Manual Session Refresh

For manual testing or recovery:

```dart
final sessionManager = SessionManager();
final success = await sessionManager.refreshSession();
if (success) {
  print('Session refreshed!');
}
```

### Check Session Health

```dart
final sessionManager = SessionManager();
print('Active session: ${sessionManager.hasActiveSession}');
print('Minutes until expiry: ${sessionManager.minutesUntilExpiry}');
print('Expiring soon: ${sessionManager.isSessionExpiringSoon}');
```

---

## 📱 Platform-Specific Notes

### Android

- **Network permissions**: `ACCESS_NETWORK_STATE` required (already in manifest)
- **Background execution**: Session checks work in background
- **Lifecycle**: Handles app pause/resume correctly

### iOS

- **Background execution**: Limited by iOS; session checks on app resume
- **Network changes**: Detected when app is in foreground
- **Keychain**: Supabase uses secure keychain storage

---

## 🔐 Security Considerations

### Token Storage

- ✅ Tokens stored securely by Supabase (encrypted local storage)
- ✅ Never logged or exposed in production
- ✅ Automatic cleanup on sign out

### Session Hijacking Prevention

- ✅ Tokens have expiration (enforced by Supabase)
- ✅ Auto-refresh uses secure channels
- ✅ Session invalidated on sign out

### Network Security

- ✅ All requests use HTTPS (enforced by Supabase)
- ✅ Timeout prevents hanging connections
- ✅ Error messages don't expose sensitive info

---

## 🎯 Error Messages Quick Reference

| Scenario             | User Message                                                              |
| -------------------- | ------------------------------------------------------------------------- |
| Empty email          | "Email is required"                                                       |
| Empty password       | "Password is required"                                                    |
| Invalid email format | "Please enter a valid email address"                                      |
| Wrong credentials    | "Invalid email or password. Please check your credentials and try again." |
| User not found       | "No account found with this email. Please sign up first."                 |
| Email not verified   | "Please verify your email address before signing in..."                   |
| Account disabled     | "Your account has been disabled. Please contact support..."               |
| Account deleted      | "This account no longer exists. Please sign up for a new account."        |
| Too many attempts    | "Too many sign-in attempts. Please wait a few minutes..."                 |
| No internet          | "No internet connection. Please check your network and try again."        |
| Timeout              | "Request timed out. Please check your connection and try again."          |
| Server error         | "Server is temporarily unavailable. Please try again later."              |

---

## 📞 Support & Troubleshooting

### Common Issues

**Issue**: User says "I'm signed out randomly"
**Solution**: Check session expiry logs, ensure network stable, verify auto-refresh working

**Issue**: "Can't sign in after clearing cache"
**Solution**: Expected behavior - user must sign in again after clearing cache

**Issue**: "Login hangs forever"
**Solution**: Check network connection, verify server availability, timeout should trigger after 30s

**Issue**: "Error messages don't make sense"
**Solution**: Check console logs for actual error, update error parsing if new error types appear

---

## 📈 Future Enhancements

### Potential Improvements

1. **Biometric Authentication**: Face ID / Fingerprint login
2. **Remember Me**: Optional long-lived sessions
3. **Multi-device Management**: View/revoke sessions from other devices
4. **Login Analytics**: Track failed attempts, successful logins
5. **Progressive Security**: Extra verification for sensitive actions
6. **Offline Mode**: Limited functionality without internet

### Dark Mode Implementation

```dart
// Add to MyApp
darkTheme: ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFA45A41),
    brightness: Brightness.dark,
  ),
  useMaterial3: true,
),
themeMode: ThemeMode.system, // Or ThemeMode.dark
```

---

**Last Updated**: November 6, 2025  
**Implementation Status**: ✅ Complete  
**Coverage**: Login, Signup, Session Management, UI/UX  
**Next Review**: When adding new auth features or platforms
