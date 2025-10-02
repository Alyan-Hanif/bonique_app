# Core Services

This directory contains core services used throughout the app.

## Services Overview

### 1. SupabaseService (`supabase_service.dart`)

Handles Supabase initialization and connection management.

**Usage:**

```dart
await SupabaseService.init();
final isConnected = await SupabaseService.testConnection();
```

### 2. DeepLinkService (`deep_link_service.dart`)

Manages all deep link handling using app_links (modern, actively maintained).

**Features:**

- ✅ Singleton pattern for easy access
- ✅ Automatic handling of cold start links
- ✅ Stream listening for runtime links
- ✅ Dedicated handlers for different link types
- ✅ Proper lifecycle management

**Usage:**

```dart
// In main.dart
final deepLinkService = DeepLinkService();

@override
void initState() {
  super.initState();
  deepLinkService.initialize(navigatorKey);
}

@override
void dispose() {
  deepLinkService.dispose();
  super.dispose();
}
```

**Supported Deep Links:**

- `io.supabase.bonique://reset-password` - Password reset
- `io.supabase.bonique://login-callback` - OAuth callback
- `io.supabase.bonique://profile` - Profile page
- `io.supabase.bonique://home` - Home page

**Adding New Handlers:**
Edit `deep_link_service.dart` and add your handler in `_handleDeepLink()`:

```dart
if (uri.host == 'your-route' || uri.path == '/your-route') {
  _handleYourRoute(uri);
  return;
}
```

## Architecture Benefits

### Separation of Concerns

Each service handles a specific domain:

- `SupabaseService` → Backend connection
- `DeepLinkService` → Navigation from external links

### Testability

Services can be easily mocked and tested in isolation.

### Maintainability

Logic is organized and easy to find/modify.

### Reusability

Services can be used from any part of the app.

## Best Practices

1. **Initialize services in `main.dart`** before running the app
2. **Use singleton pattern** for services that should have one instance
3. **Handle errors gracefully** with proper logging
4. **Clean up resources** in dispose methods
5. **Document public methods** for other developers
