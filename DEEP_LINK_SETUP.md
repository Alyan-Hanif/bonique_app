# Deep Link Setup with app_links

This document explains the deep linking setup for the Bonique app using `app_links` (the modern replacement for uni_links).

## ✅ What's Been Configured

### 1. Deep Link Service (`lib/core/services/deep_link_service.dart`)

- ✅ Created dedicated service using Singleton pattern
- ✅ Handles initial links (cold start scenarios)
- ✅ Handles link streams (when app is running)
- ✅ Password reset handler with token extraction
- ✅ OAuth login callback handler
- ✅ Profile and home route handlers
- ✅ Extensible architecture for new handlers
- ✅ Proper error handling and logging

### 2. Main App Setup (`lib/main.dart`)

- ✅ Converted `MyApp` to StatefulWidget
- ✅ Added `navigatorKey` for programmatic navigation
- ✅ Integrated `DeepLinkService` with proper lifecycle
- ✅ Clean initialization in `initState()`
- ✅ Proper cleanup in `dispose()`

### 3. Android Configuration (`android/app/src/main/AndroidManifest.xml`)

- ✅ Updated intent filter with scheme: `io.supabase.bonique`
- ✅ Configured for all hosts (password reset, profile, etc.)

### 4. iOS Configuration (`ios/Runner/Info.plist`)

- ✅ Added `CFBundleURLTypes` configuration
- ✅ Registered URL scheme: `io.supabase.bonique`

## 🔗 Supported Deep Link Format

The app now handles deep links in this format:

```
io.supabase.bonique://[host]?[params]
```

### Examples:

- `io.supabase.bonique://reset-password#access_token=xxx&type=recovery`
- `io.supabase.bonique://profile`
- `io.supabase.bonique://home`

## 🔐 Supabase Configuration Required

### Step 1: Update Supabase Redirect URLs

1. Go to your **Supabase Dashboard**
2. Navigate to **Authentication** → **URL Configuration**
3. Under **Redirect URLs**, add:
   ```
   io.supabase.bonique://reset-password
   io.supabase.bonique://login-callback
   ```

### Step 2: Update Email Template (Optional)

If you want password reset to open in your app:

1. Go to **Authentication** → **Email Templates**
2. Edit the **"Reset Password"** template
3. Update the redirect URL to:
   ```
   io.supabase.bonique://reset-password
   ```

## 🧪 Testing Deep Links

### Test on Android (using ADB)

```bash
adb shell am start -W -a android.intent.action.VIEW -d "io.supabase.bonique://reset-password"
```

### Test on iOS (using xcrun)

```bash
xcrun simctl openurl booted "io.supabase.bonique://reset-password"
```

### Test Password Reset Flow

1. Request password reset from your app
2. Check your email
3. Click the reset link
4. App should open to password change screen

## 📋 Current Deep Link Handlers

### Password Reset

- **Path**: `reset-password`
- **Format**: `io.supabase.bonique://reset-password#access_token=xxx&type=recovery`
- **Handler**: `_handlePasswordResetLink()`
- **Action**: Navigates to `/change-password` route with token

### Profile (Example)

- **Path**: `profile`
- **Format**: `io.supabase.bonique://profile`
- **Handler**: `_handleDeepLink()`
- **Action**: Navigates to `/home` route

## 🚀 Adding New Deep Link Handlers

To add a new deep link handler, edit `lib/core/services/deep_link_service.dart`:

**Step 1**: Add your handler in the `_handleDeepLink()` method:

```dart
void _handleDeepLink(String link) {
  debugPrint('📱 Processing deep link: $link');
  final uri = Uri.parse(link);

  // Add your new handler here
  if (uri.host == 'your-new-route' || uri.path == '/your-new-route') {
    _handleYourNewRoute(uri);
    return;
  }

  // ... existing handlers
}
```

**Step 2**: Create a dedicated handler method:

```dart
void _handleYourNewRoute(Uri uri) {
  // Extract any parameters you need
  final id = uri.queryParameters['id'];

  debugPrint('🔗 Your new route detected: $id');

  // Navigate to your route
  _navigateToRoute('/your-route', arguments: {'id': id});
}
```

This keeps the code organized and makes each handler testable!

## ⚠️ Important Notes

1. **Package Choice**: We use `app_links` (not `uni_links`) as it's actively maintained and compatible with modern Android/iOS
2. **Token Extraction**: Supabase uses URL fragments (`#`) for OAuth tokens, not query parameters
3. **Navigation Timing**: The code includes a 300ms delay to ensure navigator is ready
4. **Error Handling**: All deep link errors are logged but don't crash the app
5. **Cold Start**: Initial links (app opened from link) are handled separately from stream links

## 🔍 Debugging

To see deep link logs:

```bash
# Android
adb logcat | grep "Deep link"

# iOS
# View logs in Xcode console
```

Look for these log messages:

- `📱 Deep link received: [link]`
- `🔐 Password reset link detected`
- `⚠️ Unhandled deep link: [link]`

## 📝 Next Steps

1. ✅ Deep link service created in `lib/core/services/deep_link_service.dart`
2. ✅ Service integrated in `main.dart`
3. ✅ Android intent filters are set up
4. ✅ iOS URL schemes are configured
5. ⏳ Create `/change-password` route (or reuse existing page)
6. ⏳ Update Supabase dashboard with redirect URLs
7. ⏳ Test password reset flow end-to-end

## 🆘 Troubleshooting

### Deep links not working on Android?

- Make sure app is installed
- Verify intent filter in `AndroidManifest.xml`
- Check if other apps are handling the same scheme

### Deep links not working on iOS?

- Verify `CFBundleURLSchemes` in `Info.plist`
- Rebuild the app after plist changes
- Check iOS system logs for errors

### Password reset not navigating?

- Ensure `/change-password` route exists
- Check token extraction in logs
- Verify Supabase email template format
