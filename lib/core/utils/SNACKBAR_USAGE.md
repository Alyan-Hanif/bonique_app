# Awesome Snackbar Usage Guide

This guide shows you how to use the beautiful `awesome_snackbar_content` throughout the Bonique app.

## Import

```dart
import 'package:bonique/core/utils/snackbar_utils.dart';
```

## Available Methods

### 1. Success Messages ✅

Use for successful operations like saving data, completing actions, etc.

```dart
SnackbarUtils.showSuccess(
  context,
  title: 'Success!',
  message: 'Your profile has been updated successfully.',
);
```

**Use cases:**

- Profile updated
- Password changed
- Item added to wardrobe
- Settings saved
- Upload completed

### 2. Error Messages ❌

Use for errors, failures, and validation issues.

```dart
SnackbarUtils.showError(
  context,
  title: 'Error!',
  message: 'Failed to update profile. Please try again.',
);
```

**Use cases:**

- Network errors
- Validation failures
- Authentication errors
- Upload failures
- Missing required fields

### 3. Warning Messages ⚠️

Use for warnings that need user attention but aren't errors.

```dart
SnackbarUtils.showWarning(
  context,
  title: 'Warning!',
  message: 'This action cannot be undone. Are you sure?',
);
```

**Use cases:**

- Unsaved changes
- Low storage space
- Slow network detected
- Account limitations
- Deprecated features

### 4. Info/Help Messages ℹ️

Use for informational messages, tips, or helpful guidance.

```dart
SnackbarUtils.showInfo(
  context,
  title: 'Tip',
  message: 'Swipe left to delete items from your wardrobe.',
);
```

**Use cases:**

- Feature tips
- Tutorial hints
- General information
- Update notifications
- Helpful guidance

## Material Banners

For messages that need to stay visible until user dismisses them, use banners:

```dart
// Show banner
SnackbarUtils.showBanner(
  context,
  title: 'No Internet',
  message: 'Please check your connection and try again.',
  contentType: ContentType.warning,
);

// Hide banner when done
SnackbarUtils.hideBanner(context);
```

## Examples from the App

### Password Reset (Deep Link Error)

```dart
SnackbarUtils.showError(
  context,
  title: 'Link Expired!',
  message: 'This password reset link has expired. Please request a new one.',
);
```

### Password Changed Successfully

```dart
SnackbarUtils.showSuccess(
  context,
  title: 'Success!',
  message: 'Your password has been changed successfully!',
);
```

### Invalid Password

```dart
SnackbarUtils.showError(
  context,
  title: 'Invalid Password',
  message: 'Password must be at least 6 characters long',
);
```

### Item Added to Wardrobe

```dart
SnackbarUtils.showSuccess(
  context,
  title: 'Added!',
  message: 'Item has been added to your wardrobe.',
);
```

## Best Practices

1. **Keep titles short** - 1-3 words max
2. **Make messages clear** - Explain what happened and what to do next
3. **Use appropriate types** - Match the message type to the situation
4. **Don't spam** - One snackbar at a time
5. **Provide context** - Help users understand what happened

## Colors & Icons

The `awesome_snackbar_content` package automatically provides:

- ✅ **Success**: Green with checkmark
- ❌ **Error/Failure**: Red with X mark
- ⚠️ **Warning**: Orange with warning triangle
- ℹ️ **Info/Help**: Blue with info icon

No need to configure colors or icons manually!
