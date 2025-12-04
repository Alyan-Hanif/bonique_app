# Body Picture Upload Feature Setup

This document explains the body picture upload feature that prompts users to upload a full-body picture after authentication for virtual try-on purposes.

## Overview

After a user signs up or logs in, the app checks if they have uploaded a body picture. If not, they are automatically redirected to a modal screen to upload one before accessing the main app.

## Features

1. **Automatic Check**: After authentication, the app checks the `has_uploaded_body_pic` field
2. **Modal Upload Screen**: Users are prompted with an intuitive upload interface
3. **Image Source Options**: Users can choose between camera or gallery
4. **Skip Option**: Users can skip the upload and do it later
5. **Secure Storage**: Images are stored in Supabase Storage with proper security

## Database Schema

### Users Table Fields

Two new fields have been added to the `users` table:

- `has_uploaded_body_pic` (BOOLEAN, default: false) - Tracks if user has uploaded a body picture
- `body_pic_url` (TEXT, nullable) - Stores the URL of the uploaded body picture

### Migration SQL

If your database already has the users table, run this migration:

```sql
ALTER TABLE public.users
ADD COLUMN IF NOT EXISTS has_uploaded_body_pic BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS body_pic_url TEXT;
```

## Supabase Storage Setup

### 1. Create Storage Bucket

In your Supabase Dashboard:

1. Navigate to **Storage** in the left sidebar
2. Click **New bucket**
3. Set the bucket name to: `body_pictures`
4. Set the bucket to **Public** (so users can view their own images)
5. Click **Create bucket**

### 2. Set Bucket Policies

Apply these Row Level Security (RLS) policies for the storage bucket:

#### Policy 1: Users can upload their own body pictures

```sql
CREATE POLICY "Users can upload own body pictures"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'body_pictures'
  AND auth.uid()::text = (storage.foldername(name))[1]
);
```

#### Policy 2: Users can view their own body pictures

```sql
CREATE POLICY "Users can view own body pictures"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'body_pictures'
  AND auth.uid()::text = (storage.foldername(name))[1]
);
```

#### Policy 3: Users can update their own body pictures

```sql
CREATE POLICY "Users can update own body pictures"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'body_pictures'
  AND auth.uid()::text = (storage.foldername(name))[1]
);
```

#### Policy 4: Users can delete their own body pictures

```sql
CREATE POLICY "Users can delete own body pictures"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'body_pictures'
  AND auth.uid()::text = (storage.foldername(name))[1]
);
```

### 3. Alternative: Quick Setup via SQL

Run this in your Supabase SQL Editor:

```sql
-- Enable RLS on storage.objects if not already enabled
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Create all policies at once
CREATE POLICY "Users can upload own body pictures"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'body_pictures'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can view own body pictures"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'body_pictures'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can update own body pictures"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'body_pictures'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can delete own body pictures"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'body_pictures'
  AND auth.uid()::text = (storage.foldername(name))[1]
);
```

## File Structure

The uploaded images are organized by user ID:

```
body_pictures/
  ├── {userId}/
  │   ├── {userId}_{timestamp}.jpg
  │   └── {userId}_{timestamp2}.jpg
  └── {anotherUserId}/
      └── {anotherUserId}_{timestamp}.jpg
```

## Code Implementation

### Key Components

1. **UserModel** (`lib/data/models/user_model.dart`)

   - Added `hasUploadedBodyPic` and `bodyPicUrl` fields

2. **BodyPictureRepository** (`lib/data/repositories/body_picture_repository.dart`)

   - Handles image upload to Supabase Storage
   - Updates user record in database
   - Provides methods for delete and update operations

3. **BodyPictureUploadPage** (`lib/features/auth/view/body_picture_upload_page.dart`)

   - Modal UI for uploading body pictures
   - Camera and gallery selection
   - Image preview and validation

4. **Auth Navigation** (`lib/features/auth/view/auth_page.dart`)

   - Checks `hasUploadedBodyPic` after authentication
   - Redirects to upload page if false
   - Redirects to home if true

5. **Splash Page** (`lib/features/splash/view/splash_page.dart`)
   - Also checks body picture status on app start
   - Handles deep linking properly

### Usage in Code

#### Check if user has uploaded body picture

```dart
final authState = ref.watch(authViewModelProvider);
final hasUploadedBodyPic = authState.currentUserModel?.hasUploadedBodyPic ?? false;

if (!hasUploadedBodyPic) {
  // Show prompt or navigate to upload page
}
```

#### Upload a body picture

```dart
final bodyPictureRepository = BodyPictureRepository();
final imageFile = File('/path/to/image.jpg');
final userId = 'user-uuid';

try {
  final updatedUser = await bodyPictureRepository.uploadBodyPicture(
    userId,
    imageFile,
  );
  print('Upload successful: ${updatedUser.bodyPicUrl}');
} catch (e) {
  print('Upload failed: $e');
}
```

#### Update/Replace a body picture

```dart
final newImageFile = File('/path/to/new_image.jpg');
final oldUrl = userModel.bodyPicUrl;

final updatedUser = await bodyPictureRepository.updateBodyPicture(
  userId,
  newImageFile,
  oldUrl,
);
```

#### Delete a body picture

```dart
await bodyPictureRepository.deleteBodyPicture(
  userId,
  userModel.bodyPicUrl,
);
```

## User Flow

1. **New User Sign Up** → Authentication → Body Picture Upload → Home
2. **Existing User Login (no body pic)** → Authentication → Body Picture Upload → Home
3. **Existing User Login (has body pic)** → Authentication → Home
4. **User Skips Upload** → Home (can upload later from profile)

## Permissions Required

The app requests the following permissions:

- **Camera**: For taking photos directly
- **Photo Library/Gallery**: For selecting existing photos
  - Android 13+: `Permission.photos`
  - Android < 13: `Permission.storage`
  - iOS: `Permission.photos`

## Testing Checklist

- [ ] Database migration completed (new fields added)
- [ ] Storage bucket `body_pictures` created
- [ ] Storage policies applied correctly
- [ ] Test new user signup → body picture upload prompt
- [ ] Test existing user login → skip to home (if already uploaded)
- [ ] Test camera permission and photo capture
- [ ] Test gallery permission and photo selection
- [ ] Test image upload to Supabase Storage
- [ ] Test database update after upload
- [ ] Test "skip for now" functionality
- [ ] Test navigation flow (auth → upload → home)
- [ ] Verify images are stored with correct path structure
- [ ] Verify users can only access their own images

## Security Considerations

1. **Row Level Security**: Only users can access their own body pictures
2. **Folder Structure**: Images are organized by user ID for easy isolation
3. **File Naming**: Unique timestamps prevent filename collisions
4. **Public URL**: URLs are public but require knowledge of exact path (security through obscurity)
5. **Size Limits**: Images are compressed (max 1920x1920, 85% quality) before upload

## Future Enhancements

- Add body picture management in user profile
- Allow re-upload/update of body picture
- Add image cropping before upload
- Add image quality/size validation
- Show upload progress indicator
- Add image compression options
- Store multiple body pictures (front, side, back views)

## Troubleshooting

### Issue: Upload fails with "Bucket not found"

**Solution**: Make sure you created the `body_pictures` bucket in Supabase Storage

### Issue: Upload fails with "Permission denied"

**Solution**: Check that storage policies are correctly applied. Run the policy SQL commands again.

### Issue: User not redirected to upload page

**Solution**: Ensure the database fields are properly added and the user record has `has_uploaded_body_pic = false`

### Issue: Image URL not accessible

**Solution**: Verify the bucket is set to **Public** in Supabase Storage settings

### Issue: Permission denied on Android 13+

**Solution**: Ensure `Permission.photos` is requested instead of `Permission.storage` for Android 13+

## Related Files

- `supabase_users_table.sql` - Database schema with new fields
- `lib/data/models/user_model.dart` - User model with body picture fields
- `lib/data/repositories/body_picture_repository.dart` - Repository for body picture operations
- `lib/features/auth/view/body_picture_upload_page.dart` - Upload UI
- `lib/features/auth/view/auth_page.dart` - Auth navigation logic
- `lib/features/splash/view/splash_page.dart` - Splash navigation logic
- `lib/main.dart` - App routes

## Support

For issues or questions, please contact the development team or refer to:

- [Supabase Storage Documentation](https://supabase.com/docs/guides/storage)
- [Flutter Image Picker Documentation](https://pub.dev/packages/image_picker)
- [Flutter Permission Handler Documentation](https://pub.dev/packages/permission_handler)

