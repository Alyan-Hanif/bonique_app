# Forgot Password Setup Guide for Bonique

This guide explains how to set up and use the forgot password functionality with Supabase in your Flutter app.

## 📋 Table of Contents

- [Overview](#overview)
- [Supabase Configuration](#supabase-configuration)
- [Testing the Flow](#testing-the-flow)
- [Troubleshooting](#troubleshooting)
- [Technical Details](#technical-details)

---

## 🎯 Overview

The forgot password flow works as follows:

1. User clicks "Forgot Password?" on the sign-in page
2. User enters their email address
3. Supabase sends a password reset email with a deep link
4. User clicks the link in the email
5. App opens and navigates to the update password page
6. User enters and confirms new password
7. Password is updated and user is signed out
8. User signs in with the new password

---

## ⚙️ Supabase Configuration

### Step 1: Access Supabase Dashboard

1. Go to [https://app.supabase.com/](https://app.supabase.com/)
2. Sign in to your account
3. Select your project (bonique)

### Step 2: Configure Email Templates

1. In the left sidebar, click **Authentication**
2. Click **Email Templates**
3. Select **Reset Password** from the list
4. Update the email template:

**Recommended Template:**

```html
<h2>Reset Your Password</h2>

<p>Hi there,</p>

<p>We received a request to reset the password for your Bonique account.</p>

<p>Click the button below to reset your password:</p>

<p>
  <a
    href="{{ .ConfirmationURL }}"
    style="display: inline-block; padding: 12px 24px; background-color: #A45A41; color: white; text-decoration: none; border-radius: 6px; font-weight: bold;"
  >
    Reset Password
  </a>
</p>

<p>Or copy and paste this URL into your browser:</p>
<p>{{ .ConfirmationURL }}</p>

<p><strong>This link will expire in 1 hour.</strong></p>

<p>If you didn't request a password reset, you can safely ignore this email.</p>

<p>Thanks,<br />The Bonique Team</p>
```

5. Click **Save** to apply changes

### Step 3: Configure Redirect URLs

1. In the left sidebar, still under **Authentication**, click **URL Configuration**
2. Scroll to **Redirect URLs** section
3. Add the following URLs (one per line):

```
io.supabase.bonique://reset-password
```

**For production with custom domain (optional):**

```
https://yourdomain.com/reset-password
```

4. Set the **Site URL** (usually your app's website or a default URL)

   - Example: `https://bonique.app` or `http://localhost:3000` for development

5. Click **Save**

### Step 4: Email Provider Configuration (Important!)

Supabase uses email to send password reset links. Make sure your email provider is configured:

#### Option A: Use Supabase's Default Email Service (For Testing)

- This is already set up by default
- Limited to a few emails per hour
- Good for development/testing

#### Option B: Configure Custom SMTP (For Production)

1. Go to **Project Settings** > **Authentication**
2. Scroll to **SMTP Settings**
3. Configure your SMTP provider (e.g., SendGrid, AWS SES, Mailgun)
4. Fill in:
   - SMTP Host
   - SMTP Port
   - SMTP Username
   - SMTP Password
   - Sender Email
   - Sender Name
5. Click **Save**

### Step 5: Email Rate Limiting (Optional)

To prevent abuse, configure rate limiting:

1. Go to **Authentication** > **Rate Limits**
2. Set appropriate limits for:
   - Password resets per hour
   - Emails per IP address
3. Click **Save**

---

## 🧪 Testing the Flow

### Prerequisites

- Your app must be installed on a physical device or emulator
- Deep linking must be properly configured (already done in your project)
- Internet connection required

### Testing Steps

#### 1. Test Password Reset Request

```dart
// The app already has this functionality in reset_password_page.dart
```

1. Run the app
2. Navigate to the Sign In page
3. Click **"Forgot Password?"**
4. Enter a registered email address
5. Click **"Send Reset Link"**
6. You should see a success message

**Expected Result:**

- Success message appears
- Email is sent to the provided address

#### 2. Test Email Reception

1. Check your email inbox (and spam folder)
2. You should receive an email titled **"Reset Your Password"** or similar
3. The email should contain a "Reset Password" button/link

**Expected Result:**

- Email arrives within 1-2 minutes
- Email contains a clickable link

#### 3. Test Deep Link Handling

1. Open the email on your device
2. Click the **"Reset Password"** link
3. The app should automatically open

**Expected Result:**

- App opens automatically
- Navigates to the Update Password page
- No error messages appear

**Debugging Deep Links:**

If the app doesn't open, check:

- Is the app installed on the same device as the email?
- Check the deep link URL format in the email
- Look at the app logs for deep link messages

```bash
# Android
adb logcat | grep "Deep link"

# iOS
# Check Xcode console for deep link logs
```

#### 4. Test Password Update

1. Enter a new password (must meet requirements):

   - At least 8 characters
   - At least one uppercase letter
   - At least one lowercase letter
   - At least one number
   - At least one special character

2. Confirm the new password
3. Click **"Update Password"**

**Expected Result:**

- Success message appears
- User is automatically signed out
- Redirected to Sign In page

#### 5. Test New Password

1. On the Sign In page
2. Enter your email
3. Enter the **NEW** password
4. Click **"Sign In"**

**Expected Result:**

- Successfully signed in
- Navigated to Home page

---

## 🔧 Troubleshooting

### Problem: Email Not Received

**Possible Causes & Solutions:**

1. **Email in Spam Folder**

   - Check your spam/junk folder
   - Mark Supabase emails as "Not Spam"

2. **Email Rate Limiting**

   - Wait 5-10 minutes between requests
   - Check Supabase rate limit settings

3. **Invalid Email Address**

   - Ensure the email is registered in your app
   - Check for typos

4. **SMTP Not Configured**
   - For production, configure custom SMTP
   - Check SMTP credentials in Supabase

**Debug Steps:**

```bash
# Check Supabase logs in dashboard
# Go to: Project > Logs > Auth Logs
# Look for "password reset" events
```

### Problem: Deep Link Not Opening App

**Possible Causes & Solutions:**

1. **App Not Installed**

   - Install the app on the device
   - Use the same device to open the email

2. **Deep Link Configuration Issue**

   - Verify AndroidManifest.xml has `io.supabase.bonique` scheme
   - For iOS, verify Info.plist configuration
   - Rebuild the app after configuration changes

3. **URL Scheme Mismatch**
   - Check that Supabase redirect URL matches: `io.supabase.bonique://reset-password`
   - Verify no typos in the scheme

**Debug Steps:**

```dart
// Add this to deep_link_service.dart for debugging
debugPrint('🔗 Registered deep link scheme: io.supabase.bonique');

// Check if deep links are being received
// Look for console output starting with '🔗'
```

### Problem: "Invalid Link" or "Expired Link" Error

**Possible Causes & Solutions:**

1. **Link Expired**

   - Password reset links expire after 1 hour (Supabase default)
   - Request a new password reset link

2. **Link Already Used**

   - Each link can only be used once
   - Request a new link if needed

3. **Session Not Created**
   - The deep link might not have the access_token
   - Check the URL format in the email

**Debug Steps:**

```dart
// Check logs for token presence
// Look for: "🔐 Password reset link detected"
// and "Token present: true/false"
```

### Problem: Password Not Updating

**Possible Causes & Solutions:**

1. **Password Requirements Not Met**

   - Ensure password meets all requirements (see Step 4 above)
   - Check error message for specific requirement

2. **Same Password**

   - New password cannot be the same as old password
   - Choose a different password

3. **Session Expired**

   - Don't wait too long on the update password page
   - If expired, request a new reset link

4. **Network Error**
   - Check internet connection
   - Try again

**Debug Steps:**

```dart
// Check logs for:
// "🔐 User session found, updating password for: [email]"
// Look for error messages in catch block
```

### Problem: App Crashes on Deep Link

**Possible Causes & Solutions:**

1. **Route Not Registered**

   - Already fixed in main.dart
   - Ensure `/update-password` route exists

2. **Missing Dependencies**
   - Run `flutter pub get`
   - Clean and rebuild: `flutter clean && flutter pub get`

**Debug Steps:**

```bash
# Check for crash logs
flutter run --verbose

# Look for navigation errors or route errors
```

---

## 🔍 Technical Details

### File Structure

```
lib/
├── features/
│   └── auth/
│       ├── view/
│       │   ├── signin_page.dart           # Sign in with "Forgot Password" link
│       │   ├── reset_password_page.dart   # Email entry & send reset link
│       │   └── update_password_page.dart  # New password entry
│       ├── viewmodel/
│       │   └── auth_viewmodel.dart        # resetPassword() method
│       └── repository/
│           └── auth_repository.dart       # Supabase API calls
└── core/
    └── services/
        ├── deep_link_service.dart         # Handle deep links
        └── supabase_service.dart          # Supabase client
```

### Deep Link Flow

```
1. User clicks email link:
   io.supabase.bonique://reset-password#access_token=xxx&type=recovery

2. OS opens app with deep link

3. app_links package receives the link

4. DeepLinkService._handleDeepLink() processes it

5. DeepLinkService._handlePasswordResetLink() extracts token

6. Supabase session is established with access_token

7. Navigate to /update-password with token argument

8. UpdatePasswordPage displays password form

9. User enters new password

10. Supabase.auth.updateUser() is called

11. Password updated successfully

12. User signed out and redirected to /auth
```

### Key Methods

#### auth_repository.dart

```dart
Future<void> resetPassword(String email) async {
  await _client.auth.resetPasswordForEmail(
    email,
    redirectTo: 'io.supabase.bonique://reset-password',
  );
}
```

#### deep_link_service.dart

```dart
Future<void> _handlePasswordResetLink(Uri uri) async {
  // Extract access_token and type from URL
  // Establish Supabase session with token
  await SupabaseService.client.auth.setSession(accessToken);
  // Navigate to update password page
}
```

#### update_password_page.dart

```dart
Future<void> _updatePassword() async {
  // Verify session exists
  final currentUser = SupabaseService.client.auth.currentUser;
  // Update password
  await SupabaseService.client.auth.updateUser(
    UserAttributes(password: newPassword),
  );
  // Sign out and redirect
}
```

### Security Considerations

1. **Token Expiration**: Reset links expire after 1 hour (Supabase default)
2. **One-Time Use**: Each reset link can only be used once
3. **Secure Transmission**: Tokens are sent via HTTPS
4. **Password Requirements**: Enforced on client and server
5. **Rate Limiting**: Prevents brute force attacks

### Configuration Files

#### android/app/src/main/AndroidManifest.xml

```xml
<!-- Password reset / deep links -->
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="io.supabase.bonique" />
</intent-filter>
```

#### ios/Runner/Info.plist

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>io.supabase.bonique</string>
        </array>
    </dict>
</array>
```

---

## 📚 Additional Resources

- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
- [Supabase Password Reset](https://supabase.com/docs/guides/auth/auth-password-reset)
- [Flutter Deep Linking](https://docs.flutter.dev/development/ui/navigation/deep-linking)
- [app_links Package](https://pub.dev/packages/app_links)

---

## 🎉 Summary

You now have a fully functional forgot password system! Users can:

- ✅ Request password reset via email
- ✅ Receive reset link in email
- ✅ Open app via deep link
- ✅ Set new password securely
- ✅ Sign in with new password

**Need help?** Check the troubleshooting section or contact your development team.

---

**Last Updated:** October 27, 2025  
**Version:** 1.0.0

