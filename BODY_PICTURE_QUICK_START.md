# Body Picture Upload - Quick Start Guide

## ⚡ Quick Setup (5 minutes)

### Step 1: Database Migration

Run this SQL in your **Supabase SQL Editor**:

```sql
-- Add new fields to users table
ALTER TABLE public.users
ADD COLUMN IF NOT EXISTS has_uploaded_body_pic BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS body_pic_url TEXT;
```

### Step 2: Create Storage Bucket

1. Go to **Supabase Dashboard** → **Storage**
2. Click **New bucket**
3. Name: `body_pictures`
4. Make it **Public**
5. Click **Create bucket**

### Step 3: Apply Storage Policies

Run this SQL in your **Supabase SQL Editor**:

```sql
-- Enable RLS on storage.objects
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Create policies for body_pictures bucket
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

### Step 4: Test the App

1. Run the app: `flutter run`
2. Sign up with a new account
3. You should be redirected to the body picture upload page
4. Upload an image or skip
5. Verify navigation to home page

## ✅ That's it!

The feature is now fully functional. Users will be prompted to upload a body picture after authentication.

## 📖 Need More Details?

See `BODY_PICTURE_SETUP.md` for complete documentation including:

- Detailed explanations
- Code usage examples
- Troubleshooting guide
- Security considerations

## 🔧 Code Changes Made

All code changes have been implemented:

- ✅ Database schema updated
- ✅ UserModel updated with new fields
- ✅ Body picture repository created
- ✅ Upload modal page created
- ✅ Auth navigation logic updated
- ✅ Splash page logic updated
- ✅ Routes added to main.dart

## 🎯 User Flow

```
Sign Up/Login → Check has_uploaded_body_pic
                       ↓
                   If FALSE → Body Picture Upload Page → Home
                       ↓
                   If TRUE → Home (skip upload)
```

## 🚀 Next Steps (Optional)

1. Add body picture management in user profile settings
2. Allow users to update their body picture later
3. Add image cropping functionality
4. Implement progress indicators for large uploads

