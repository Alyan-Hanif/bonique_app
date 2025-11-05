# App Icon Setup Guide

## Overview

Custom app icons have been successfully configured using the `flutter_launcher_icons` package.

## Configuration

### Package Used

- **flutter_launcher_icons**: ^0.14.2 (added to `dev_dependencies`)

### Icon Image

- **Source Image**: `assets/images/bonique/splash-logo.png`
- **Platforms**: Android & iOS

### Settings in pubspec.yaml

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/bonique/splash-logo.png"

  # Android specific settings
  adaptive_icon_background: "#FFFFFF" # White background for Android adaptive icon
  adaptive_icon_foreground: "assets/images/bonique/splash-logo.png"

  # iOS settings
  remove_alpha_ios: true
```

## What Was Generated

### Android Icons

- Standard launcher icons for all screen densities (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- Adaptive icons (Android 8.0+) with separate foreground and background layers
- Created `colors.xml` file in Android project for adaptive icon background color
- Mipmap XML configuration files

### iOS Icons

- All required icon sizes for iOS devices
- Removed alpha channel for iOS compatibility

## How to Customize

### Change the Icon Image

1. Replace or use a different image in `assets/images/bonique/`
2. Update the `image_path` in `pubspec.yaml`:
   ```yaml
   image_path: "assets/images/bonique/your-new-icon.png"
   ```
3. Run: `dart run flutter_launcher_icons`

### Change Android Adaptive Icon Background Color

1. Update the `adaptive_icon_background` color in `pubspec.yaml`:
   ```yaml
   adaptive_icon_background: "#YOUR_HEX_COLOR"
   ```
2. Run: `dart run flutter_launcher_icons`

### Use Different Icons for Android and iOS

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path_android: "assets/images/bonique/android-icon.png"
  image_path_ios: "assets/images/bonique/ios-icon.png"
```

## Requirements for Icon Images

### Recommended Specifications

- **Format**: PNG
- **Size**: 1024x1024 pixels (minimum)
- **Background**: Can be transparent or solid
- **Aspect Ratio**: 1:1 (square)

### Android Adaptive Icons

- The foreground image should have padding (about 25% on each side)
- The safe zone for important content is the center 66% of the image
- Background can be a solid color or an image

### iOS Icons

- Must be square with no transparency (alpha channel removed automatically)
- Should look good at various sizes

## Rebuilding the App

After generating new icons, you need to rebuild the app:

```bash
# For Android
flutter clean
flutter build apk

# For iOS
flutter clean
flutter build ios
```

Or simply run the app again in debug mode, and the new icons will be applied.

## Viewing the Icons

### Android

- Check the generated icons in:
  - `android/app/src/main/res/mipmap-*/ic_launcher.png`
  - `android/app/src/main/res/mipmap-*/ic_launcher_foreground.png`

### iOS

- Check the generated icons in:
  - `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## Troubleshooting

### Icons not updating after generation

1. Run `flutter clean`
2. Delete the app from your device/emulator
3. Rebuild and reinstall the app

### Image quality issues

- Use a high-resolution image (at least 1024x1024)
- Ensure the image has sufficient padding for adaptive icons

### Background color not showing

- Make sure the hex color format is correct: `#RRGGBB` or `#AARRGGBB`
- Rebuild the app after changing colors

## Command Reference

```bash
# Install/update dependencies
flutter pub get

# Generate launcher icons
dart run flutter_launcher_icons

# Alternative command (older versions)
flutter pub run flutter_launcher_icons

# Clean and rebuild
flutter clean
flutter build apk  # for Android
flutter build ios  # for iOS
```

## Additional Resources

- [flutter_launcher_icons on pub.dev](https://pub.dev/packages/flutter_launcher_icons)
- [Android Adaptive Icons Guide](https://developer.android.com/develop/ui/views/launch/icon_design_adaptive)
- [iOS App Icon Guidelines](https://developer.apple.com/design/human-interface-guidelines/app-icons)
