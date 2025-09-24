# bonique

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Environment Configuration

This project uses environment variables to manage configuration values. All sensitive data and configuration should be stored in environment variables rather than hardcoded in the source code.

### Setup

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit the `.env` file with your actual values:
   ```bash
   nano .env
   ```

3. Fill in the required environment variables:
   - `SUPABASE_URL`: Your Supabase project URL
   - `SUPABASE_ANON_KEY`: Your Supabase anonymous key
   - `GOOGLE_PROJECT_ID`: Your Google Cloud project ID
   - `GOOGLE_PROJECT_NUMBER`: Your Google Cloud project number
   - `GOOGLE_API_KEY`: Your Google API key
   - `APP_PACKAGE_NAME`: Your app's package name
   - `APP_NAME`: Your app's display name

### Security Notes

- The `.env` file is excluded from version control for security
- Never commit sensitive keys or URLs to the repository
- Use different environment files for different environments (development, staging, production)
- The `.env.example` file serves as a template for required variables

### Usage in Code

Environment variables are accessed through the `EnvConfig` class:

```dart
import 'package:bonique/core/config/env_config.dart';

// Get Supabase URL
String supabaseUrl = EnvConfig.supabaseUrl;

// Get Google API key
String apiKey = EnvConfig.googleApiKey;
```

