# Supabase Users Table Setup

This document explains how to set up the users table in Supabase to store additional user data beyond the default authentication.

## Database Setup

### 1. Create the Users Table

Run the SQL script `supabase_users_table.sql` in your Supabase SQL editor:

```sql
-- The script creates:
-- - users table with additional fields
-- - Indexes for performance
-- - Row Level Security (RLS) policies
-- - Automatic triggers for user creation
-- - Updated timestamp functionality
```

### 2. Table Structure

The `users` table includes:

- `id` (UUID, Primary Key) - References auth.users(id)
- `email` (TEXT) - User's email address
- `full_name` (TEXT) - User's full name
- `avatar_url` (TEXT) - User's profile picture URL
- `created_at` (TIMESTAMP) - When the user was created
- `updated_at` (TIMESTAMP) - When the user was last updated
- `metadata` (JSONB) - Additional user data

### 3. Security Features

- **Row Level Security (RLS)** enabled
- Users can only access their own data
- Automatic user profile creation on signup
- Secure policies for data access

### 4. Automatic Features

- **Auto-creation**: User profiles are automatically created when users sign up
- **Auto-update**: Updated timestamp is automatically maintained
- **Google Integration**: Google sign-in data is automatically stored

## Usage in Code

### Accessing User Data

```dart
// Get current user model
final authState = ref.watch(authViewModelProvider);
final userModel = authState.currentUserModel;

if (userModel != null) {
  print('User: ${userModel.fullName}');
  print('Email: ${userModel.email}');
  print('Avatar: ${userModel.avatarUrl}');
}
```

### Updating User Data

```dart
// Update user profile
final userRepository = UserRepository();
await userRepository.updateUser(
  userId, 
  {'full_name': 'New Name', 'avatar_url': 'new_url'}
);
```

## Testing

1. **Sign Up**: Create a new account and verify user data is stored
2. **Google Sign In**: Test Google authentication and data storage
3. **Profile Updates**: Test updating user information
4. **Data Retrieval**: Verify user data can be retrieved correctly

## Troubleshooting

### Common Issues

1. **Permission Denied**: Ensure RLS policies are correctly set up
2. **User Not Found**: Check if the trigger is working for auto-creation
3. **Data Not Saving**: Verify the users table exists and has correct structure

### Debug Steps

1. Check Supabase logs for errors
2. Verify table structure matches the model
3. Test RLS policies in Supabase dashboard
4. Check trigger functions are active

## Environment Variables

Make sure your `.env` file contains:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

The implementation automatically handles user data storage for both email/password and Google sign-in methods.
