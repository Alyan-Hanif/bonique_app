# Android 12 Gallery Permission Fix

## Overview

Updated the permission handling system to properly support gallery access across all Android versions, with specific fixes for Android 12 (API 32).

## Changes Made

### 1. Permission Service Updates (`lib/core/services/permission_service.dart`)

Added version-aware permission handling:

- **Android 13+ (API 33+)**: Uses `Permission.photos` (READ_MEDIA_IMAGES)
- **Android 10-12 (API 29-32)**: Uses `Permission.storage` (READ_EXTERNAL_STORAGE)
- **Below Android 10**: Uses `Permission.storage` (READ_EXTERNAL_STORAGE)

### Key Updates:

1. **Added `device_info_plus` import**: To detect Android SDK version at runtime
2. **Updated `requestPhotoPermission()`**: Now checks Android version and requests the appropriate permission
3. **Updated `isPhotoPermissionGranted()`**: Checks the correct permission based on Android version
4. **Updated `requestPhotoWithDialog()`**: Shows proper dialogs with version-aware permission requests
5. **Updated `hasImagePermissions()`**: Uses the new version-aware check

### 2. Android Manifest Updates (`android/app/src/main/AndroidManifest.xml`)

The manifest already had the correct permissions configured:

```xml
<!-- Storage Permissions for Android 10-12 (API 29-32) -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />

<!-- Media Permissions for Android 13+ -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
```

## How It Works

### Android Version Detection

The service now uses `DeviceInfoPlugin` to detect the Android SDK version:

```dart
final androidInfo = await DeviceInfoPlugin().androidInfo;
final sdkInt = androidInfo.version.sdkInt;
```

### Permission Request Flow

1. App detects the Android version
2. Requests appropriate permission:
   - Android 12: Requests `READ_EXTERNAL_STORAGE`
   - Android 13+: Requests `READ_MEDIA_IMAGES`
3. User grants/denies permission
4. App handles the response appropriately

## Testing

To test the gallery permissions:

1. **Android 12 devices**: The app will request storage permission
2. **Android 13+ devices**: The app will request media images permission
3. Verify in device settings that the correct permission is shown

## Dependencies

Existing dependencies used:

- `permission_handler: ^12.0.1`
- `device_info_plus: ^12.2.0`

## Why This Fix Was Needed

Android 12 requires `READ_EXTERNAL_STORAGE` for gallery access, while Android 13+ uses the new granular media permissions (`READ_MEDIA_IMAGES`). The previous implementation always requested `Permission.photos`, which didn't properly handle Android 12's storage permission requirements.

This update ensures:

- ✅ Android 12 users can access the gallery
- ✅ Android 13+ users get granular permission prompts
- ✅ Backward compatibility with older Android versions
- ✅ iOS compatibility maintained

