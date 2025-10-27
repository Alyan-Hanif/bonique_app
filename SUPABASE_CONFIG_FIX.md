# Fix Supabase Password Reset Configuration

## 🔴 Current Issue

Your Supabase is sending password reset links with an OTP `code` like this:

```
io.supabase.bonique://reset-password?code=03b2fda4-bf5f-4738-980b-ab50abd94787
```

But we need it to send links with `access_token` for the PKCE flow to work properly.

## ✅ Solution: Configure Supabase Email Settings

Follow these steps in the Supabase Dashboard:

### Step 1: Access Email Settings

1. Go to [Supabase Dashboard](https://app.supabase.com/)
2. Select your project (bonique)
3. Click **Authentication** in the left sidebar
4. Click **Email Templates**

### Step 2: Update Password Reset Email Template

1. Select **Reset Password** from the list
2. Look for the email content
3. Make sure the template uses `{{ .ConfirmationURL }}` in the link

**IMPORTANT:** The URL should look like this in the template:

```html
<h2>Reset Your Password</h2>

<p>Click the link below to reset your password:</p>

<p>
  <a href="{{ .ConfirmationURL }}">Reset Password</a>
</p>

<p>Or copy and paste this URL into your browser:</p>
<p>{{ .ConfirmationURL }}</p>

<p>This link will expire in 1 hour.</p>
```

### Step 3: Configure Site URL and Redirect URLs

1. In the left sidebar, still under **Authentication**, click **URL Configuration**
2. Set these values:

**Site URL:**

```
io.supabase.bonique://
```

**Redirect URLs (add both):**

```
io.supabase.bonique://reset-password
io.supabase.bonique://reset-password/
```

3. Click **Save**

### Step 4: Verify Auth Settings

1. Go to **Project Settings** (gear icon in sidebar)
2. Click **Authentication** tab
3. Scroll to **Email Auth**
4. Make sure these are enabled:
   - ✅ Enable email confirmations
   - ✅ Secure email change

### Step 5: Test Again

After making these changes:

1. Clean your app cache:

   ```bash
   flutter clean
   flutter pub get
   ```

2. Restart your app and test the password reset flow again

3. The email should now contain a link with `access_token` instead of just `code`

## 🔍 How to Verify

When you click the reset link in the email, check your console logs. You should see:

```
✅ Good (access_token present):
io.supabase.bonique://reset-password#access_token=xxx&refresh_token=yyy&type=recovery

❌ Bad (only code present):
io.supabase.bonique://reset-password?code=xxx
```

## 🆘 If It Still Sends Code

If Supabase still sends `code` instead of `access_token`, try this:

### Alternative: Update the Repository Method

Update the `resetPassword` method to use a different redirect configuration:

1. Open `lib/features/auth/repository/auth_repository.dart`

2. Find the `resetPassword` method and update it:

```dart
Future<void> resetPassword(String email) async {
  await _client.auth.resetPasswordForEmail(
    email,
    redirectTo: 'io.supabase.bonique://reset-password',
    // Try adding this option:
    // This tells Supabase to use PKCE flow
    emailRedirectTo: 'io.supabase.bonique://reset-password',
  );
}
```

## 📝 Notes

- The issue is with how Supabase generates the password reset links
- With PKCE flow enabled in the app, Supabase should send access tokens
- The configuration in the Supabase dashboard determines the URL format
- Once configured correctly, the deep link will work automatically

## 🎯 Expected Result

After configuration, when you:

1. Request password reset
2. Check email
3. Click the link

The app should:

- Open automatically ✅
- Navigate to Update Password page ✅
- Have an active session ✅
- Allow password update ✅

---

**Need more help?** Share the exact URL format from the email (with tokens removed) and I can provide specific guidance.

