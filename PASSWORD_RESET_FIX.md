# Password Reset Localhost Fix - Quick Guide

## Problem

Password reset emails contain a link to `localhost:3000` which doesn't work.

## Immediate Solution (Recommended)

### Step 1: Update Supabase Email Template

1. Go to your **Supabase Dashboard**
2. Click **Authentication** → **Email Templates**
3. Click on **"Reset Password"** template
4. Find this line in the template:
   ```
   {{ .SiteURL }}/auth/reset-password?token={{ .Token }}
   ```
5. Replace it with:
   ```
   {{ .ConfirmationURL }}
   ```
6. Click **Save**

### What This Does

- Users click the reset link in their email
- They're taken to Supabase's built-in password reset page
- They enter their new password on that page
- Password is reset successfully
- No localhost issues!

## Alternative: Configure Site URL

### Step 2: Set Proper Site URL

1. In Supabase Dashboard, go to **Authentication** → **URL Configuration**
2. Update **Site URL** to one of:
   - Your production domain: `https://yourdomain.com`
   - For development: Use the Supabase default URL
3. Under **Redirect URLs**, add:
   - `{{ YOUR_SUPABASE_URL }}/auth/v1/verify`
   - Any custom redirect URLs you need

## Test the Fix

1. Request a password reset from your app
2. Check your email
3. Click the "Reset Password" link
4. You should see a Supabase page (not localhost)
5. Enter your new password
6. Password should be updated successfully

## Notes

- The fix is server-side (Supabase dashboard), no code changes needed in your app
- This works for both mobile and web without any additional configuration
- For production apps, consider implementing deep linking (see SUPABASE_SETUP.md)
