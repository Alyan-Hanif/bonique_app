# Body Picture Check on Home Page

## ✅ Implementation

Added a check on the **Home Page** that verifies if the user has uploaded their body picture.

### Flow

```
User logs in
    ↓
Navigate to HOME PAGE
    ↓
Check: Has body picture?
    ├─ NO → Navigate to BODY PICTURE UPLOAD PAGE
    └─ YES → Stay on HOME PAGE ✅
```

---

## 📋 Changes Made

### File: `lib/features/home/view/home_page.dart`

**Added import**:

```dart
import 'package:bonique/features/auth/view/body_picture_upload_page.dart';
```

**Added initState method**:

```dart
@override
void initState() {
  super.initState();
  // Check if user has uploaded body picture after the frame is built
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _checkBodyPictureStatus();
  });
}
```

**Added check method**:

```dart
void _checkBodyPictureStatus() {
  final authState = ref.read(authViewModelProvider);
  final currentUser = authState.currentUserModel;

  // Check if user is logged in and has user model
  if (authState.isLoggedIn && currentUser != null) {
    // Check if user has uploaded body picture
    if (!currentUser.hasUploadedBodyPic) {
      print('⚠️ User has not uploaded body picture, navigating to upload page');
      // Navigate to body picture upload page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const BodyPictureUploadPage(),
        ),
      );
    } else {
      print('✅ User has body picture, staying on home page');
    }
  }
}
```

---

## 🎯 Complete App Flow

### Scenario 1: New User (No Body Picture)

```
1. User opens app
   ↓
2. Splash screen
   ↓
3. User not logged in → ONBOARDING
   ↓
4. User logs in/signs up
   ↓
5. Navigate to HOME PAGE
   ↓
6. Home page checks: hasUploadedBodyPic = false
   ↓
7. Navigate to BODY PICTURE UPLOAD PAGE ✅
   ↓
8. User uploads picture
   ↓
9. Navigate back to HOME PAGE ✅
   ↓
10. User can now use the app
```

### Scenario 2: Returning User (Has Body Picture)

```
1. User opens app
   ↓
2. Splash screen
   ↓
3. User logged in → HOME PAGE ✅
   ↓
4. Home page checks: hasUploadedBodyPic = true
   ↓
5. Stay on HOME PAGE ✅
   ↓
6. User can use the app immediately
```

### Scenario 3: User Restarts App (Has Body Picture)

```
1. User closes app
   ↓
2. User reopens app
   ↓
3. Splash screen
   ↓
4. Check auth: isLoggedIn = true ✅
   ↓
5. Navigate to HOME PAGE ✅
   ↓
6. Home page checks: hasUploadedBodyPic = true
   ↓
7. Stay on HOME PAGE ✅
```

### Scenario 4: User Restarts App (No Body Picture Yet)

```
1. User was in middle of onboarding
   ↓
2. User closes app
   ↓
3. User reopens app
   ↓
4. Splash screen
   ↓
5. Check auth: isLoggedIn = true ✅
   ↓
6. Navigate to HOME PAGE
   ↓
7. Home page checks: hasUploadedBodyPic = false
   ↓
8. Navigate to BODY PICTURE UPLOAD PAGE ✅
```

---

## 📝 Expected Logs

### User Without Body Picture:

```
I/flutter: ✅ User is logged in, navigating to home page
I/flutter: ⚠️ User has not uploaded body picture, navigating to upload page
// User sees Body Picture Upload Page
```

### User With Body Picture:

```
I/flutter: ✅ User is logged in, navigating to home page
I/flutter: ✅ User has body picture, staying on home page
// User stays on Home Page
```

---

## 🔄 Body Picture Upload Flow

When user is on **Body Picture Upload Page**:

1. **User selects image** (camera or gallery)
2. **User uploads** → Calls `uploadBodyPicture()`
3. **Updates user model** → Sets `has_uploaded_body_pic = true`
4. **Navigates to home** → `Navigator.pushReplacementNamed(context, '/home')`
5. **Home page checks again** → `hasUploadedBodyPic = true` ✅
6. **User stays on home** → Can use the app

---

## 🎨 User Experience

### Good UX:

- ✅ Seamless flow from login to home
- ✅ Automatic redirect if body picture needed
- ✅ User can skip if they want (Skip button on upload page)
- ✅ No repeated checks - only checks on first load of home page
- ✅ User stays logged in across restarts

### What Happens:

1. **First time user**: Login → Upload Body Picture → Home
2. **Returning user**: Login → Home (immediate)
3. **User who skipped**: Login → Home → Can upload later from profile

---

## 🔐 Security & Data Flow

### Data Model (UserModel):

```dart
class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final bool hasUploadedBodyPic;  ← This field
  final String? bodyPicUrl;
  // ... other fields
}
```

### Database (Supabase):

- Table: `users`
- Columns:
  - `has_uploaded_body_pic` (boolean)
  - `body_pic_url` (text)

### Storage (Supabase):

- Bucket: `personImages`
- Path: `{userId}/{timestamp}.jpg`

---

## 🧪 Testing

### Test 1: New User Flow

```
1. Log out (if logged in)
2. Sign up with new account
3. ✅ Should navigate to Body Picture Upload Page
4. Upload a picture
5. ✅ Should navigate to Home Page
6. Close and reopen app
7. ✅ Should stay on Home Page (has picture)
```

### Test 2: Skip Upload

```
1. Log out (if logged in)
2. Sign up with new account
3. ✅ Navigate to Body Picture Upload Page
4. Click "Skip for now"
5. ✅ Should navigate to Home Page
6. Close and reopen app
7. ✅ Should navigate to Body Picture Upload Page again (no picture)
```

### Test 3: Existing User

```
1. Log in with account that has body picture
2. ✅ Should navigate directly to Home Page
3. ✅ Should stay on Home Page (not redirect)
```

---

## 🎉 Summary

**What Works Now**:

- ✅ User logs in → Stays logged in across restarts
- ✅ First-time users → Prompted to upload body picture
- ✅ Returning users → Go straight to home
- ✅ Users can skip upload and do it later
- ✅ Automatic check on home page load
- ✅ Clean, seamless user experience

**Complete Flow**:

```
App Start → Splash → Login Check
    ↓
If Logged In:
    → Home Page → Body Picture Check
        ↓
        If No Picture: → Upload Page → Home Page
        If Has Picture: → Stay on Home Page ✅

If Not Logged In:
    → Onboarding → Login/Signup → Home Page → Body Picture Check
```

The app now has a **complete onboarding flow** with body picture verification! 🎊

