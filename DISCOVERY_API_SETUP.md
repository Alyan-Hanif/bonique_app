# Discovery Questions API Setup

This document explains how the Discovery Questions API is configured in the Bonique app.

## Overview

The Discovery Page fetches questions dynamically from your backend API. The questions are fetched when the page loads, and the API requires the current user's ID for personalization.

## Current Configuration

**API Endpoint:** `https://78ade1ad95a0.ngrok-free.app/wardrobe/questions`

**Method:** GET

**Authentication:** Requires authenticated Supabase user

**Parameters:**

- `user_id` (query parameter) - Automatically sent from the currently logged-in user

**Request Headers:**

```
Content-Type: application/json
ngrok-skip-browser-warning: true
```

**Example Request:**

```
GET https://78ade1ad95a0.ngrok-free.app/wardrobe/questions?user_id=abc123-def456-ghi789
```

## API Response Format

Your API endpoint should return a JSON response in the following format:

```json
{
  "questions": [
    {
      "question": "What type of event are you dressing for?",
      "options": [
        "Casual Outing",
        "Formal Event",
        "Beach Day",
        "Sporting Event"
      ]
    },
    {
      "question": "What type of clothing do you have in mind?",
      "options": ["Dress", "Top and Bottom", "Jumpsuit", "Outerwear"]
    },
    {
      "question": "What is your ideal color palette for this outfit?",
      "options": [
        "Bright and Vibrant",
        "Neutral Tones",
        "Pastels",
        "Dark and Moody"
      ]
    }
  ]
}
```

## How It Works

When a user opens the Discovery page:

1. The app checks if the user is authenticated
2. If authenticated, it retrieves the user's ID from Supabase Auth
3. Makes a GET request to the API with the user_id as a query parameter
4. The API returns personalized questions for that user
5. Questions are displayed dynamically on the page

## Changing the API Endpoint

To change the API endpoint, edit `/lib/data/repositories/discovery_repository.dart`:

```dart
// Update these constants
static const String _baseUrl = 'YOUR_NEW_API_URL';
static const String _questionsEndpoint = '/your/endpoint/path';
```

## Alternative Implementation Options

### Option 1: Supabase Edge Functions

1. Create a Supabase Edge Function named `get-discovery-questions`:

```bash
supabase functions new get-discovery-questions
```

2. Implement the function in `supabase/functions/get-discovery-questions/index.ts`:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const questions = {
      questions: [
        {
          question: "What type of event are you dressing for?",
          options: [
            "Casual Outing",
            "Formal Event",
            "Beach Day",
            "Sporting Event",
          ],
        },
        {
          question: "What type of clothing do you have in mind?",
          options: ["Dress", "Top and Bottom", "Jumpsuit", "Outerwear"],
        },
        {
          question: "What is your ideal color palette for this outfit?",
          options: [
            "Bright and Vibrant",
            "Neutral Tones",
            "Pastels",
            "Dark and Moody",
          ],
        },
        {
          question: "Which fabric do you prefer for comfort?",
          options: ["Cotton", "Linen", "Silk", "Denim"],
        },
        {
          question: "What kind of pattern do you like on your clothing?",
          options: ["Solid Colors", "Stripes", "Floral", "Plaid"],
        },
      ],
    };

    return new Response(JSON.stringify(questions), {
      headers: {
        ...corsHeaders,
        "Content-Type": "application/json",
      },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: {
        ...corsHeaders,
        "Content-Type": "application/json",
      },
    });
  }
});
```

3. Deploy the function:

```bash
supabase functions deploy get-discovery-questions
```

### Option 2: Custom REST API

If you want to use a custom REST API endpoint instead of Supabase Edge Functions:

1. Update `lib/data/repositories/discovery_repository.dart`:

First, add the `http` package to your `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.2.0
```

Then, modify the repository:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/discovery_question_model.dart';

class DiscoveryRepository {
  // Replace with your actual API endpoint
  static const String _apiEndpoint = 'https://your-api.com/api/discovery-questions';

  Future<DiscoveryQuestionsResponse> fetchDiscoveryQuestions() async {
    try {
      final response = await http.get(
        Uri.parse(_apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          // Add any authentication headers if needed
          // 'Authorization': 'Bearer YOUR_TOKEN',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return DiscoveryQuestionsResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load questions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch discovery questions: $e');
    }
  }
}
```

2. Add your API endpoint to `.env`:

```env
DISCOVERY_API_ENDPOINT=https://your-api.com/api/discovery-questions
```

3. Update `lib/core/config/env_config.dart`:

```dart
static String get discoveryApiEndpoint => dotenv.env['DISCOVERY_API_ENDPOINT'] ?? '';
```

### Option 3: Supabase Database Table

If you want to store questions in a Supabase database table:

1. Create a table in Supabase:

```sql
CREATE TABLE discovery_questions (
  id SERIAL PRIMARY KEY,
  question TEXT NOT NULL,
  options JSONB NOT NULL,
  order_index INTEGER NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO discovery_questions (question, options, order_index) VALUES
('What type of event are you dressing for?', '["Casual Outing", "Formal Event", "Beach Day", "Sporting Event"]', 1),
('What type of clothing do you have in mind?', '["Dress", "Top and Bottom", "Jumpsuit", "Outerwear"]', 2),
('What is your ideal color palette for this outfit?', '["Bright and Vibrant", "Neutral Tones", "Pastels", "Dark and Moody"]', 3),
('Which fabric do you prefer for comfort?', '["Cotton", "Linen", "Silk", "Denim"]', 4),
('What kind of pattern do you like on your clothing?', '["Solid Colors", "Stripes", "Floral", "Plaid"]', 5);
```

2. Update `lib/data/repositories/discovery_repository.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';
import '../models/discovery_question_model.dart';

class DiscoveryRepository {
  final SupabaseClient _client = SupabaseService.client;

  Future<DiscoveryQuestionsResponse> fetchDiscoveryQuestions() async {
    try {
      final response = await _client
          .from('discovery_questions')
          .select('question, options')
          .eq('is_active', true)
          .order('order_index', ascending: true);

      final questions = (response as List<dynamic>).map((row) {
        return DiscoveryQuestion(
          question: row['question'] as String,
          options: (row['options'] as List<dynamic>)
              .map((option) => option.toString())
              .toList(),
        );
      }).toList();

      return DiscoveryQuestionsResponse(questions: questions);
    } catch (e) {
      throw Exception('Failed to fetch discovery questions: $e');
    }
  }
}
```

## Features

- **Dynamic Questions**: Questions are loaded from the API
- **Loading State**: Shows a loading spinner while fetching questions
- **Error Handling**: Displays error message with retry button if API call fails
- **Validation**: The "Discover" button only appears when all questions are answered
- **State Management**: Uses Riverpod for clean state management

## Files Modified

1. **Created:**

   - `lib/data/models/discovery_question_model.dart` - Models for questions and responses
   - `lib/data/repositories/discovery_repository.dart` - API call handling
   - `lib/features/home/viewmodel/discovery_viewmodel.dart` - State management

2. **Modified:**
   - `lib/features/home/view/discovery_page.dart` - Updated to use dynamic API data

## Testing

To test the implementation:

1. Ensure your API endpoint is set up and returning data in the correct format
2. Run the app and navigate to the Discovery page
3. You should see:
   - A loading spinner initially
   - Questions loaded from the API
   - Ability to select answers
   - "Discover" button appears when all questions are answered

## Troubleshooting

### Questions not loading

1. Check your API endpoint is correct
2. Verify the API is returning data in the correct format
3. Check the Flutter console for error messages
4. Use the retry button to attempt loading again

### CORS errors (for custom REST APIs)

Make sure your API server has CORS properly configured to allow requests from your app.

### Supabase Edge Function not found

Make sure you've deployed the function and it's active in your Supabase project.

## Next Steps

You may want to add:

- Caching to reduce API calls
- Pull-to-refresh functionality
- Analytics to track which questions users answer
- Dynamic question ordering based on user preferences
