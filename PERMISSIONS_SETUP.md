# Permissions Setup for Bonique

This document outlines the device permissions configuration for camera, gallery, and other features in the Bonique app.

## Overview

The app now includes comprehensive permission handling for:

- 📸 **Camera Access** - Take photos for try-on and wardrobe items
- 🖼️ **Photo Library Access** - Select images from device gallery
- 💾 **Storage Access** - Read and write media files (Android)

## Platform Configuration

### Android (`android/app/src/main/AndroidManifest.xml`)

The following permissions have been added:

```xml
<!-- Camera Permission -->
<uses-permission android:name="android.permission.CAMERA" />

<!-- Storage Permissions for Android 12 and below -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />

<!-- Media Permissions for Android 13+ -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />

<!-- Internet Permission -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!-- Camera Hardware Features -->
<uses-feature android:name="android.hardware.camera" android:required="false" />
<uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />
```

**Note:** Camera features are marked as `required="false"` so the app can still be installed on devices without cameras.

### iOS (`ios/Runner/Info.plist`)

The following usage descriptions have been added:

```xml
<!-- Camera Permission -->
<key>NSCameraUsageDescription</key>
<string>Bonique needs access to your camera to take photos of your outfits and products.</string>

<!-- Photo Library Read Permission -->
<key>NSPhotoLibraryUsageDescription</key>
<string>Bonique needs access to your photo library to select and upload images.</string>

<!-- Photo Library Write Permission -->
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Bonique needs permission to save photos to your photo library.</string>
```

## Runtime Permission Handling

### Permission Service

A dedicated `PermissionService` (`lib/core/services/permission_service.dart`) handles all runtime permission requests with user-friendly dialogs.

#### Key Methods:

- `requestCameraWithDialog(BuildContext)` - Request camera permission with dialog
- `requestPhotoWithDialog(BuildContext)` - Request photo library permission with dialog
- `isCameraPermissionGranted()` - Check camera permission status
- `isPhotoPermissionGranted()` - Check photo permission status
- `requestAllImagePermissions(BuildContext)` - Request all image-related permissions

### Features with Permission Integration

#### 1. Try-On Page (`lib/features/home/view/try_on_page.dart`)

- ✅ Camera permission check before taking photos
- ✅ Gallery permission check before selecting images
- ✅ User-friendly error messages

#### 2. Edit Profile Page (`lib/features/home/view/edit_profile_page.dart`)

- ✅ Gallery permission check before selecting profile picture

#### 3. Add Item Page (`lib/features/home/view/add_item_page.dart`)

- ✅ Camera permission check before taking photos
- ✅ Gallery permission check before selecting wardrobe items
- ✅ Support for multiple image selection

## User Experience

### Permission Flow:

1. **First Request**: When user tries to access camera/gallery for the first time, a system dialog appears asking for permission.

2. **Denied**: If user denies permission, a snackbar message explains why the permission is needed.

3. **Permanently Denied**: If user permanently denies permission (Android) or denies multiple times (iOS), a custom dialog appears with an "Open Settings" button to guide them to app settings.

### Best Practices Implemented:

- ✅ Permissions are requested **just-in-time** (when the user needs the feature)
- ✅ Clear, contextual permission messages explain why each permission is needed
- ✅ Graceful handling of denied permissions with helpful error messages
- ✅ Direct link to app settings for permanently denied permissions

## Dependencies

- **permission_handler**: ^12.0.1 - Runtime permission management

## Testing Permissions

### Android:

```bash
# Grant permissions via ADB
adb shell pm grant com.example.bonique android.permission.CAMERA
adb shell pm grant com.example.bonique android.permission.READ_MEDIA_IMAGES

# Revoke permissions via ADB
adb shell pm revoke com.example.bonique android.permission.CAMERA
adb shell pm revoke com.example.bonique android.permission.READ_MEDIA_IMAGES

# Reset permissions
adb shell pm clear com.example.bonique
```

### iOS:

```bash
# Reset permissions (requires app reinstall)
# Or use Simulator > Reset Content and Settings
```

## Troubleshooting

### Issue: Camera/Gallery not working on Android 13+

**Solution**: Ensure you have the new media permissions declared:

```xml
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```

### Issue: Permission dialog not showing

**Solution**: Check that usage descriptions are present in `Info.plist` for iOS, and permissions are declared in `AndroidManifest.xml` for Android.

### Issue: "Permission permanently denied" on Android

**Solution**: User needs to go to Settings > Apps > Bonique > Permissions and manually enable the required permissions. The app will guide them with a dialog.

## Future Enhancements

Optional permissions that can be added later:

### Location (for nearby stores/events):

```xml
<!-- Android -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

```xml
<!-- iOS -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>Bonique needs your location to show nearby stores and fashion events.</string>
```

### Microphone (for video recording):

```xml
<!-- Android -->
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

```xml
<!-- iOS -->
<key>NSMicrophoneUsageDescription</key>
<string>Bonique needs access to your microphone for video recording.</string>
```

## Resources

- [Android Permissions Guide](https://developer.android.com/guide/topics/permissions/overview)
- [iOS Permission Guide](https://developer.apple.com/documentation/uikit/protecting_the_user_s_privacy)
- [permission_handler Package](https://pub.dev/packages/permission_handler)

---

**Last Updated**: November 4, 2025
**Version**: 1.0.0
