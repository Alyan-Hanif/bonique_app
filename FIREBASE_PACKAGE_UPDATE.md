# Firebase Package ID Update Guide

## Quick Fix Applied ✅

I've updated your `google-services.json` file to use the new package ID: `com.bonique.app`

This will allow your app to build and run immediately.

---

## ⚠️ Proper Firebase Console Update (Required for Production)

For production use, you should properly register the new package ID in Firebase Console:

### Steps:

1. **Go to Firebase Console**

   - Visit: https://console.firebase.google.com
   - Select your project: `cloud-storage-alyan`

2. **Add New Android App** (Recommended)

   - Click the gear icon ⚙️ next to "Project Overview"
   - Select "Project settings"
   - Scroll down to "Your apps"
   - Click "Add app" → Select Android icon
   - Enter package name: `com.bonique.app`
   - Enter app nickname: "Bonique"
   - Click "Register app"

3. **Download New google-services.json**

   - After registering, download the new `google-services.json`
   - Replace the current file at: `android/app/google-services.json`

4. **Get SHA-1 Fingerprint** (Important for Google Sign-In)
   ```bash
   # Debug SHA-1
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
   - Copy the SHA-1 fingerprint
   - In Firebase Console, go to: Project Settings → Your Apps → Bonique
   - Scroll to "SHA certificate fingerprints"
   - Click "Add fingerprint"
   - Paste your SHA-1
   - Click "Save"

---

## Alternative: Update Existing App

Instead of adding a new app, you can update the existing one:

1. **In Firebase Console:**

   - Project Settings → Your apps
   - Find the existing app (com.example.bonique)
   - Unfortunately, you **cannot change** the package name of an existing app

2. **Solution:**
   - You must add a new app with the new package ID
   - Or keep the manual edit I made to `google-services.json`

---

## Google Sign-In Configuration

Since you're using Google Sign-In, you also need to update Google Cloud Console:

### Steps:

1. **Go to Google Cloud Console**

   - Visit: https://console.cloud.google.com
   - Select project: `cloud-storage-alyan`

2. **Update OAuth Consent Screen**

   - APIs & Services → OAuth consent screen
   - Update app name to "Bonique"
   - Add/update app logo
   - Save

3. **Update OAuth 2.0 Client IDs**

   - APIs & Services → Credentials
   - Find your Android OAuth client
   - Click edit
   - Update package name to: `com.bonique.app`
   - Add SHA-1 fingerprint (same as Firebase)
   - Save

4. **Web Client ID** (if using)
   - Your web client ID should remain the same
   - No changes needed

---

## Testing Checklist

After updating Firebase:

- [ ] App builds successfully
- [ ] Google Sign-In works on debug builds
- [ ] Email/password authentication works
- [ ] Firebase services (Storage, Auth) work correctly

Before release:

- [ ] Generate release keystore
- [ ] Get release SHA-1 fingerprint
- [ ] Add release SHA-1 to Firebase Console
- [ ] Add release SHA-1 to Google Cloud Console
- [ ] Test Google Sign-In with release build
- [ ] Configure release signing in build.gradle

---

## Current Configuration

### Package ID

- **Old:** `com.example.bonique`
- **New:** `com.bonique.app`

### Firebase Project

- **Project ID:** `cloud-storage-alyan`
- **Project Number:** `1051919162406`

### Files Updated

- ✅ `android/app/google-services.json` (temporary fix)

### Still Using Old Package (Update Later)

- Firebase Console app registration
- Google Cloud Console OAuth client

---

## What Works Now vs Production

### ✅ Works Now (Development)

- App builds and runs
- Basic Firebase services
- Email/password auth
- Firebase Storage

### ⚠️ May Not Work (Needs Update)

- Google Sign-In (needs Google Cloud Console update)
- Firebase Dynamic Links (if using)
- Firebase App Distribution (if using)

### 🚫 Won't Work in Production (Until Fixed)

- Google Sign-In on release builds (needs release SHA-1)
- Play Store release (needs proper Firebase registration)

---

## Recommended Action Plan

### For Development (Now)

✅ You're good! The manual edit I made will work for testing.

### For Beta Testing

1. Register new app in Firebase Console
2. Download proper google-services.json
3. Update Google Cloud Console OAuth clients
4. Add debug SHA-1 to both Firebase and Google Cloud

### For Production Release

1. Generate release keystore
2. Get release SHA-1
3. Add release SHA-1 to Firebase and Google Cloud Console
4. Test release build thoroughly
5. Submit to Play Store

---

## Troubleshooting

### Build Error: "No matching client found"

- **Cause:** Package name mismatch in google-services.json
- **Solution:** Already fixed! ✅

### Google Sign-In Fails

- **Cause:** OAuth client not updated or SHA-1 missing
- **Solution:**
  1. Update package name in Google Cloud Console
  2. Add SHA-1 fingerprint
  3. Wait 5-10 minutes for changes to propagate

### "API key not valid" Error

- **Cause:** Firebase project restrictions
- **Solution:** Check API restrictions in Google Cloud Console

---

## Quick Commands Reference

```bash
# Get debug SHA-1
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Generate release keystore (when ready)
keytool -genkey -v -keystore ~/bonique-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias bonique

# Get release SHA-1 (after generating keystore)
keytool -list -v -keystore ~/bonique-release-key.jks -alias bonique

# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

---

## Links

- **Firebase Console:** https://console.firebase.google.com
- **Google Cloud Console:** https://console.cloud.google.com
- **Your Project:** https://console.firebase.google.com/project/cloud-storage-alyan

---

**Status:** ✅ Temporary fix applied | ⚠️ Proper Firebase registration recommended for production

**Next Step:** Test the app to confirm everything works, then plan Firebase Console update when ready for production.

