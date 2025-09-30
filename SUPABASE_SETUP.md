# Supabase Users Table Setup

This document explains how to set up the users table in Supabase to store additional user data beyond the default authentication.

## Database Setup

### 1. Create the Users Table

Run the SQL script `supabase_users_table.sql` in your Supabase SQL editor:

```sql
-- The script creates:
-- - users table with additional fields
-- - Indexes for performance
-- - Row Level Security (RLS) policies
-- - Automatic triggers for user creation
-- - Updated timestamp functionality
```

### 2. Table Structure

The `users` table includes:

- `id` (UUID, Primary Key) - References auth.users(id)
- `email` (TEXT) - User's email address
- `full_name` (TEXT) - User's full name
- `avatar_url` (TEXT) - User's profile picture URL
- `created_at` (TIMESTAMP) - When the user was created
- `updated_at` (TIMESTAMP) - When the user was last updated
- `metadata` (JSONB) - Additional user data

### 3. Security Features

- **Row Level Security (RLS)** enabled
- Users can only access their own data
- Automatic user profile creation on signup
- Secure policies for data access

### 4. Automatic Features

- **Auto-creation**: User profiles are automatically created when users sign up
- **Auto-update**: Updated timestamp is automatically maintained
- **Google Integration**: Google sign-in data is automatically stored

## Usage in Code

### Accessing User Data

```dart
// Get current user model
final authState = ref.watch(authViewModelProvider);
final userModel = authState.currentUserModel;

if (userModel != null) {
  print('User: ${userModel.fullName}');
  print('Email: ${userModel.email}');
  print('Avatar: ${userModel.avatarUrl}');
}
```

### Updating User Data

```dart
// Update user profile
final userRepository = UserRepository();
await userRepository.updateUser(
  userId,
  {'full_name': 'New Name', 'avatar_url': 'new_url'}
);
```

## Testing

1. **Sign Up**: Create a new account and verify user data is stored
2. **Google Sign In**: Test Google authentication and data storage
3. **Profile Updates**: Test updating user information
4. **Data Retrieval**: Verify user data can be retrieved correctly

## Troubleshooting

### Common Issues

1. **Permission Denied**: Ensure RLS policies are correctly set up
2. **User Not Found**: Check if the trigger is working for auto-creation
3. **Data Not Saving**: Verify the users table exists and has correct structure

### Debug Steps

1. Check Supabase logs for errors
2. Verify table structure matches the model
3. Test RLS policies in Supabase dashboard
4. Check trigger functions are active

## Environment Variables

Make sure your `.env` file contains:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

The implementation automatically handles user data storage for both email/password and Google sign-in methods.

## Password Reset Configuration

### Configure Supabase Redirect URLs

1. Go to your Supabase Dashboard
2. Navigate to **Authentication** → **URL Configuration**
3. Add the following to **Redirect URLs**:
   - `io.supabase.bonique://reset-password` (for mobile deep linking)
   - `https://yourdomain.com/reset-password` (if you have a web version)

### For Testing Password Reset:

**Option 1: Use Supabase Email Templates (Simplest for Mobile)**

1. Go to **Authentication** → **Email Templates** in Supabase Dashboard
2. Edit the "Reset Password" template
3. Change the redirect URL to use the Supabase hosted page:
   - Replace `{{ .SiteURL }}/auth/reset-password?token={{ .Token }}`
   - With `{{ .ConfirmationURL }}`

This will use Supabase's built-in password reset page where users can:

- Click the link in their email
- Get redirected to a Supabase-hosted page
- Enter their new password
- Get automatically redirected back to your app

**Option 2: Implement Deep Linking (For Production)**

If you want users to reset password directly in your app:

1. Add deep linking packages to `pubspec.yaml`:

```yaml
dependencies:
  uni_links: ^0.5.1
  app_links: ^3.4.5
```

2. Configure Android deep linking in `android/app/src/main/AndroidManifest.xml`:

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="io.supabase.bonique" />
</intent-filter>
```

3. Configure iOS deep linking in `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>io.supabase.bonique</string>
        </array>
    </dict>
</array>
```

**Option 3: Quick Fix for Development (Desktop/Web Testing)**

For testing on desktop or web during development:

1. In Supabase Dashboard → **Authentication** → **URL Configuration**
2. Set **Site URL** to: `http://localhost:3000`
3. Add redirect URL: `http://localhost:3000/reset-password`
4. Create a simple HTML page to handle the reset (see below)

### Simple Local Reset Password Page

Create a file `reset-password.html` for local testing:

```html
<!DOCTYPE html>
<html>
  <head>
    <title>Reset Password</title>
    <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
  </head>
  <body>
    <h1>Reset Your Password</h1>
    <form id="resetForm">
      <input
        type="password"
        id="newPassword"
        placeholder="New Password"
        required
      />
      <button type="submit">Reset Password</button>
    </form>
    <div id="message"></div>

    <script>
      const { createClient } = supabase;
      const supabaseUrl = "YOUR_SUPABASE_URL";
      const supabaseKey = "YOUR_SUPABASE_ANON_KEY";
      const client = createClient(supabaseUrl, supabaseKey);

      document
        .getElementById("resetForm")
        .addEventListener("submit", async (e) => {
          e.preventDefault();
          const newPassword = document.getElementById("newPassword").value;

          const { error } = await client.auth.updateUser({
            password: newPassword,
          });

          if (error) {
            document.getElementById("message").innerText =
              "Error: " + error.message;
          } else {
            document.getElementById("message").innerText =
              "Password updated successfully!";
          }
        });
    </script>
  </body>
</html>
```

### Recommended Approach

For mobile apps, **Option 1** (Supabase Email Templates) is the easiest:

- No deep linking configuration needed
- Users click email link → go to Supabase page → reset password → done
- Works immediately without any additional setup
