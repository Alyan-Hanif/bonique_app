# Offline Cache Implementation – Bonique App

This document describes the full implementation of offline-first behaviour for the Bonique app: what was built, what was used, what problems appeared, and how they were fixed.

---

## 1. Goal

Implement this flow on app start and when loading wardrobe data:

```
APP START
   ↓
Check Internet
   ↓
IF online:
   Fetch API → Save to Hive → Show API Data
ELSE:
   Load from Hive → Show Cached Data
```

So the app works offline by using cached data (wardrobe list and user profile) and cached images.

---

## 2. What Was Used

### 2.1 Packages

| Package                           | Purpose                                                                                                 |
| --------------------------------- | ------------------------------------------------------------------------------------------------------- |
| **hive_flutter** (^1.1.0)         | Local key-value storage for caching wardrobe list and user profile. Persists across app restarts.       |
| **connectivity_plus** (^6.0.0)    | Already in project. Used to check online/offline before calling APIs.                                   |
| **cached_network_image** (^3.4.1) | Caches image bytes to disk. When offline, images loaded before are shown from cache instead of failing. |

### 2.2 New / Modified Code

| File                                                | Role                                                                                                                                                                                          |
| --------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `lib/core/services/wardrobe_cache_service.dart`     | Hive box for wardrobe items per user. `save(userId, items)`, `load(userId)`.                                                                                                                  |
| `lib/core/services/wardrobe_data_source.dart`       | Offline-first logic: if online → fetch API, save to Hive, return data; if offline → load from Hive. Returns `WardrobeDataResult` (items + `fromCache`).                                       |
| `lib/core/services/user_profile_cache_service.dart` | Hive box for current user profile. `save(user)`, `load(userId)`, `clear(userId)`.                                                                                                             |
| `lib/main.dart`                                     | Calls `Hive.initFlutter()`, then `WardrobeCacheService.init()` and `UserProfileCacheService.init()` before `runApp()`.                                                                        |
| `lib/features/home/view/wardrobe_page.dart`         | Uses `WardrobeDataSource.getWardrobeItems()`, shows “Showing cached data (offline)” banner when `fromCache`, uses `CachedNetworkImage` for grid and full-screen viewer, adds pull-to-refresh. |
| `lib/features/auth/repository/auth_repository.dart` | `getCurrentUserModel()` saves user to `UserProfileCacheService` on success and rethrows on error; `signOut()` clears user cache and catches errors so offline sign-out doesn’t crash.         |
| `lib/features/auth/viewmodel/auth_viewmodel.dart`   | On API failure in `_checkInitialAuthStatus()`: if network error → use cached user, else build `UserModel.fromSupabaseUser(currentUser)` so user stays logged in when offline with no cache.   |

---

## 3. What Was Implemented (Step by Step)

### 3.1 Wardrobe Offline-First (List Data)

1. **Hive + WardrobeCacheService**
   - One Hive box `wardrobe_cache`, key `wardrobe_<userId>`, value = list of `WardrobeModel.toJson()`.
   - `save(userId, items)` after a successful API fetch; `load(userId)` when offline.

2. **WardrobeDataSource**
   - `getWardrobeItems(userId)`:
     - If **online**: call `WardrobeRepository.getWardrobeItems(userId)`, then `WardrobeCacheService.save(userId, items)`, return `WardrobeDataResult(items, fromCache: false)`.
     - If **offline**: `WardrobeCacheService.load(userId)`, return `WardrobeDataResult(items, fromCache: true)`.
     - If online but API **throws**: fallback to cache if non-empty.

3. **Wardrobe UI**
   - `wardrobeDataProvider` uses `WardrobeDataSource.getWardrobeItems(userId)` instead of calling the repository directly.
   - When `result.fromCache` is true, show an amber “Showing cached data (offline)” banner.
   - Pull-to-refresh invalidates `wardrobeDataProvider` and refetches (from API or cache).

### 3.2 User Profile Offline (Stay Logged In)

1. **UserProfileCacheService**
   - Hive box `user_profile_cache`, key `user_<userId>`, value = `UserModel.toJson()`.
   - Written when we successfully load the user from the API; read when API fails (e.g. offline).

2. **AuthRepository**
   - `getCurrentUserModel()`: on success, `UserProfileCacheService.save(userModel)`; on error, **rethrow** (so view model can try cache).
   - `signOut()`: clear `UserProfileCacheService` for current user; wrap `_client.auth.signOut()` in try/catch so offline sign-out doesn’t throw.

3. **AuthViewModel (`_checkInitialAuthStatus`)**
   - When `getCurrentUserModel()` **throws**:
     - If it’s a **network error** (see below) and we have `currentUser`:
       - Try `UserProfileCacheService.load(userId)`.
       - If found → set `currentUserModel = cached`, stay logged in.
       - If **not** found → set `currentUserModel = UserModel.fromSupabaseUser(currentUser)` (session fallback), stay logged in.
     - Otherwise → sign out (and catch sign-out errors).

4. **Network error detection**
   - `_isNetworkError(e)`: treat as network error if message contains e.g. `socketexception`, `failed host lookup`, `no address associated with hostname`, `errno = 7`, `host lookup`, `authretryablefetchexception`, or connection refused.

### 3.3 Images Offline (Full Display, Not Just Thumbnails)

1. **Problem**
   - Wardrobe list was cached (URLs), but images were loaded with `Image.network()` / `NetworkImage()`. Offline, those URLs (Supabase storage) fail, so only placeholders or “thumbnails” showed.

2. **Fix**
   - Use **cached_network_image**:
     - Grid tiles: `Image.network()` → `CachedNetworkImage(imageUrl: item.imagePath, ...)` with placeholder and errorWidget.
     - Preload: `precacheImage(CachedNetworkImageProvider(item.imagePath), context)`.
     - Full-screen viewer: `PhotoView(imageProvider: CachedNetworkImageProvider(item.imagePath))`.
   - When online, images are downloaded and stored on disk by the package; when offline, they are read from that cache and displayed at full size.

---

## 4. Problems Faced and Fixes

### 4.1 Restart Offline: Nothing Showed (Wardrobe Empty)

**What happened**

- User restarted the app with device offline. Wardrobe showed no items; logs showed “USER NOT LOGGED IN OR NO USER MODEL”.

**Cause**

- On startup, the app called Supabase to get the current user profile. That request failed (no network). The code then **signed the user out** (“User authenticated but not found in database. Signing out…”). So `currentUserModel` became null and the wardrobe provider returned an empty list and never tried Hive.

**Fix**

- Do **not** sign out on network failure. Instead:
  - Try **UserProfileCacheService** for the current user id; if hit, keep user logged in with cached profile.
  - If cache miss: build a fallback **UserModel.fromSupabaseUser(currentUser)** from the local Supabase session and keep user logged in.
- Only sign out when the API returns “user not in DB” (null with no exception) or when it’s not a network error.

---

### 4.2 Offline Sign-Out Crashed (Unhandled Exception)

**What happened**

- When the app tried to sign out while offline, it threw:  
  `AuthRetryableFetchException(... uri=.../auth/v1/logout?scope=local)`.

**Cause**

- `signOut()` called `_client.auth.signOut()`, which performs a network request. With no network, that request failed and the exception was unhandled.

**Fix**

- In **AuthRepository.signOut()**: wrap `_googleSignIn.signOut()` and `_client.auth.signOut()` in try/catch; on error, log and continue. Always clear **UserProfileCacheService** for the current user so local state is cleared even when server sign-out fails.

---

### 4.3 Cached User Not Found: “No cached user for … (offline)”

**What happened**

- Logs showed “No cached user for &lt;userId&gt; (offline)” and the user was still signed out on next startup.

**Cause**

- User profile is only written to Hive when `getCurrentUserModel()` **succeeds** (online). On a **fresh install** or first launch offline (or after clearing app data), the cache was empty, so we had nothing to load and the code path still led to sign-out.

**Fix**

- When we have a network error and **no** cached profile, do **not** sign out. Build a minimal profile from the **local Supabase session**: `UserModel.fromSupabaseUser(currentUser)` and set that as `currentUserModel`. User stays logged in with id/email/metadata from the session; wardrobe can then load from Hive for that userId.

---

### 4.4 Images Only Showing as Thumbnails / Not Displaying Offline

**What happened**

- Offline, wardrobe list loaded from Hive (items with image URLs), but images didn’t display properly—only thumbnails or placeholders.

**Cause**

- Image URLs point to Supabase storage (https). With `Image.network()` / `NetworkImage()`, no network means the image request fails, so Flutter showed placeholders or error widgets (“thumbnails only”).

**Fix**

- Use **cached_network_image** for all wardrobe images:
  - **CachedNetworkImage** for grid tiles.
  - **CachedNetworkImageProvider** for precache and for **PhotoView** in the full-screen viewer.
- The package caches image bytes to disk. Once images are loaded while online, they are served from cache when offline, so full-size images display correctly.

---

## 5. Flow Summary

| Scenario                  | Wardrobe list                                                       | User auth                                                        | Images                                              |
| ------------------------- | ------------------------------------------------------------------- | ---------------------------------------------------------------- | --------------------------------------------------- |
| **Online**                | Fetch from API → save to Hive → show API data                       | Fetch profile from API → save to Hive; session from Supabase     | Load from URL → cached_network_image writes to disk |
| **Offline, cache exists** | Load from Hive → show cached list + “Showing cached data (offline)” | Use cached profile or session fallback; stay logged in           | Load from cached_network_image disk cache           |
| **Offline, no cache**     | Empty list (or previous cache)                                      | Stay logged in via session fallback (UserModel.fromSupabaseUser) | Placeholder/error if never loaded before            |
| **Online but API fails**  | Fallback to Hive cache if non-empty                                 | Use cached user or session fallback                              | From cache if already cached                        |

---

## 6. How to Test

1. **Wardrobe cache**
   - Online: open app, log in, open Wardrobe tab (list and images load).
   - Turn on airplane mode (or disable Wi‑Fi).
   - Restart app and open Wardrobe: list and images should show from cache; “Showing cached data (offline)” banner appears.

2. **User profile / login state**
   - Online: log in once (profile cached).
   - Offline: restart app → should stay logged in (cached or session fallback).
   - Fresh install offline: if Supabase still has a valid local session, app should still keep user logged in via session fallback.

3. **Images**
   - Load Wardrobe once online so images are cached by cached_network_image.
   - Go offline and reopen Wardrobe: images should display at full size from disk cache.

4. **Pull-to-refresh**
   - On Wardrobe tab, pull down to refresh; data is reloaded (from API when online, from Hive when offline).

---

## 7. Files Touched (Reference)

- `pubspec.yaml` – Added `hive_flutter`, `cached_network_image`.
- `lib/main.dart` – Hive init, WardrobeCacheService.init(), UserProfileCacheService.init().
- `lib/core/services/wardrobe_cache_service.dart` – New.
- `lib/core/services/wardrobe_data_source.dart` – New (+ `WardrobeDataResult`).
- `lib/core/services/user_profile_cache_service.dart` – New.
- `lib/features/home/view/wardrobe_page.dart` – WardrobeDataSource, fromCache banner, CachedNetworkImage, pull-to-refresh.
- `lib/features/auth/repository/auth_repository.dart` – getCurrentUserModel save/rethrow, signOut clear cache + try/catch.
- `lib/features/auth/viewmodel/auth_viewmodel.dart` – \_checkInitialAuthStatus: cache + session fallback, \_isNetworkError.

---

_Last updated: Feb 2025_
