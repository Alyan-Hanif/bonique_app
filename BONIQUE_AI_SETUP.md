# Bonique AI Backend Configuration

This document explains how the Bonique AI backend URL is configured in the app.

## Environment Variable Setup

The Bonique AI backend URL is stored in the `.env` file as an environment variable for security and flexibility.

### Adding the Variable to Your .env File

Open your `.env` file and add the following line:

```bash
# Bonique AI Backend Configuration
BONIQUE_AI_URL=https://9ef0f3990b51.ngrok-free.app
```

**Important Notes:**

- Replace the URL with your actual backend URL
- For ngrok, remember to update this URL every time you restart ngrok (free tier URLs change)
- Never commit your `.env` file to version control

### Full .env Example

Your `.env` file should look like this:

```bash
# Supabase Configuration
SUPABASE_URL=your_supabase_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here

# Google Services Configuration
GOOGLE_PROJECT_ID=your_google_project_id_here
GOOGLE_PROJECT_NUMBER=your_google_project_number_here
GOOGLE_API_KEY=your_google_api_key_here
GOOGLE_OAUTH_CLIENT_ID=your_google_oauth_client_id_here

# App Configuration
APP_PACKAGE_NAME=com.example.bonique
APP_NAME=bonique

# Bonique AI Backend Configuration
BONIQUE_AI_URL=https://9ef0f3990b51.ngrok-free.app
```

## Code Implementation

### Files Updated

All repository files now use the environment variable instead of hardcoded URLs:

1. **`lib/core/config/env_config.dart`**

   - Added `boniqueAiUrl` getter
   - Added to validation checks

2. **`lib/data/repositories/discovery_repository.dart`**

   - Uses `EnvConfig.boniqueAiUrl` for API calls

3. **`lib/data/repositories/recommendations_repository.dart`**

   - Uses `EnvConfig.boniqueAiUrl` for API calls

4. **`lib/data/repositories/wardrobe_repository.dart`**
   - Uses `EnvConfig.boniqueAiUrl` for API calls

### Usage in Code

```dart
import '../../core/config/env_config.dart';

class MyRepository {
  static String get _baseUrl => EnvConfig.boniqueAiUrl;

  // Use _baseUrl in your API calls
}
```

## API Endpoints

The app makes the following calls to your Bonique AI backend:

### 1. Discovery Questions

- **Endpoint:** `GET /wardrobe/questions`
- **Query Params:** `user_id`
- **Used in:** Discovery page to fetch personalized questions

### 2. Product Recommendations

- **Endpoint:** `GET /wardrobe/recommendations`
- **Query Params:** `user_id`, `query`, `top_k`
- **Used in:** Results page to show recommended products

### 3. Image Upload

- **Endpoint:** `POST /images/upload`
- **Query Params:** `user_id`
- **Body:** Multipart form-data with image file
- **Used in:** Add Item page when uploading wardrobe items

## Updating the URL

### For Development (ngrok)

1. Start your backend server
2. Start ngrok: `ngrok http 8000` (or your port)
3. Copy the ngrok URL from the terminal
4. Update your `.env` file with the new URL
5. Restart the app

### For Production

1. Update `.env` with your production URL
2. Rebuild the app
3. The URL is read at app startup, so no code changes needed

## Security Notes

- The `.env` file is excluded from version control (in `.gitignore`)
- Never commit sensitive URLs or API keys to the repository
- Use different `.env` files for different environments (dev, staging, prod)
- The `EnvConfig.validateConfig()` ensures all required variables are set at startup

## Troubleshooting

### App can't connect to backend

1. Check if the URL in `.env` is correct
2. Verify your backend server is running
3. For ngrok, check if the tunnel is active at `http://localhost:4040`
4. Look for connection logs in the app console (marked with 🌐 emoji)

### URL not updating

1. Hot reload doesn't reload environment variables
2. Do a full app restart (stop and run again)
3. Verify the `.env` file is in the project root directory

## Example API Logs

When properly configured, you'll see logs like:

```
🌐 FETCHING RECOMMENDATIONS FROM API
👤 User ID: abc123
📝 Query: summer dress work
🔗 Full API URL with params: https://9ef0f3990b51.ngrok-free.app/wardrobe/recommendations?user_id=abc123&query=summer+dress+work&top_k=20
📡 API Response Status: 200
✅ API Response parsed successfully
```
