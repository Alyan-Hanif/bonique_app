# Auto Logout on Install/Update - Implementation Guide

## Overview

The app now automatically logs out users whenever the app is installed or updated. This is a security best practice that ensures sessions are cleared when the app version changes.

## How It Works

### Version Tracking

- Uses `package_info_plus` to get current app version and build number
- Uses `shared_preferences` to store the last known version
- Compares current version with stored version on every app launch

### Automatic Logout Trigger

The logout is triggered when:

1. **Fresh Install**: No stored version found (first time launch)
2. **Update**: Current version differs from stored version
3. **Build Number Change**: Even if version is same but build number changed

### Implementation Details

#### New Service: `VersionChecker`

Location: `lib/core/services/version_checker.dart`

Key methods:

- `checkVersionAndLogout()`: Main method that checks version and performs logout if needed
- `getVersionInfo()`: Get current app version information
- `clearStoredVersion()`: Clear stored version (for testing)

#### Integration in `main.dart`

The version check is performed during app initialization, right after session manager setup:

```dart
// Check app version and logout if needed (on install/update)
final versionChanged = await VersionChecker.checkVersionAndLogout();
if (versionChanged) {
  print('🔄 App version changed - user logged out for security');
}
```

### Dependencies Added

```yaml
package_info_plus: ^8.0.0 # Get app version info
shared_preferences: ^2.2.2 # Store version locally
```

## Execution Flow

```
App Launch
    ↓
Initialize Supabase
    ↓
Initialize Session Manager
    ↓
Check App Version ←─── VersionChecker.checkVersionAndLogout()
    ↓
Compare with Stored Version
    ├─ Same Version → Continue normally
    └─ Different/No Version →
        ↓
        Logout from Supabase
        ↓
        Store New Version
        ↓
        Continue to Auth Screen
```

## Debugging

### Console Logs

The version checker provides detailed console logs:

- `🔍 Checking app version...` - Start of version check
- `📱 Current version: X.X.X+Y` - Current app version
- `💾 Stored version: X.X.X+Y` - Previously stored version
- `🆕 Fresh install detected` - First time install
- `🔄 Version changed from X to Y` - Update detected
- `🚪 User logged out successfully` - Logout completed
- `✅ Version unchanged` - No action needed

### Testing

#### Test Fresh Install

```dart
// Clear stored version to simulate fresh install
await VersionChecker.clearStoredVersion();
// Restart app
```

#### Test Update

1. Change version in `pubspec.yaml`:
   ```yaml
   version: 1.0.1+2 # Increment version or build number
   ```
2. Run `flutter pub get`
3. Restart app

#### Get Version Info

```dart
final versionInfo = await VersionChecker.getVersionInfo();
print('Version: ${versionInfo['version']}');
print('Build: ${versionInfo['buildNumber']}');
```

## Security Benefits

1. **Session Cleanup**: Ensures no stale sessions after updates
2. **Authentication Reset**: Forces re-authentication after major changes
3. **Token Refresh**: Clears any cached authentication tokens
4. **User Data Protection**: Prevents potential issues with data schema changes

## User Experience

- **Seamless**: Logout happens silently during app initialization
- **Secure**: Users are directed to login screen after install/update
- **Transparent**: Console logs provide visibility for debugging
- **Non-intrusive**: Only happens once per version change

## Files Modified

1. **`pubspec.yaml`**

   - Added `package_info_plus: ^8.0.0`
   - Added `shared_preferences: ^2.2.2`

2. **`lib/core/services/version_checker.dart`** (NEW)

   - Version checking and logout logic

3. **`lib/main.dart`**
   - Import `version_checker.dart`
   - Call `VersionChecker.checkVersionAndLogout()` during initialization

## Future Enhancements

Possible improvements:

- Add migration logic for specific version updates
- Show custom message to user about update
- Add option to skip logout for minor updates
- Implement version-specific data migrations
- Add analytics tracking for update events

## Notes

- The version check is non-blocking - if it fails, the app continues normally
- Uses `debugPrint` for logging which is automatically removed in release builds
- Logout is performed silently without user notification
- Version is stored as separate keys for version and build number
