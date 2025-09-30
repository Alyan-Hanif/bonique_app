import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/config/env_config.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/models/user_model.dart';

class AuthRepository {
  final SupabaseClient _client = SupabaseService.client;
  final UserRepository _userRepository = UserRepository();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: EnvConfig.googleOAuthClientId,
  );

  // Sign in with email and password
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // If sign-in is successful, ensure user exists in our users table
      if (response.user != null) {
        await _ensureUserExistsInDatabase(response.user!);
      }

      return response;
    } catch (e) {
      print('Sign-in error: $e');
      rethrow;
    }
  }

  // Sign up with email and password
  Future<AuthResponse> signUp(
    String email,
    String password, {
    String? fullName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );

      // If signup is successful and user is created, store user data in users table
      if (response.user != null) {
        await _storeUserData(response.user!, fullName);
      }

      return response;
    } catch (e) {
      // Log the error for debugging
      print('Signup error: $e');
      rethrow;
    }
  }

  // Sign in with Google
  Future<AuthResponse> signInWithGoogle() async {
    try {
      print('Starting Google sign-in...');

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      print('Google user: $googleUser');

      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print('Google auth tokens received');
      print('ID Token: ${googleAuth.idToken}');
      print('Access Token: ${googleAuth.accessToken}');

      // Check if ID token is available (this is the most important one)
      if (googleAuth.idToken == null) {
        throw Exception('Failed to obtain Google ID token');
      }

      print('Signing in to Supabase with Google...');

      // Sign in to Supabase with the Google credential
      // Note: accessToken can be null in some configurations
      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken, // This can be null
      );

      print('Supabase Google sign-in successful: ${response.user?.email}');

      // If Google sign-in is successful, store/update user data in users table
      if (response.user != null) {
        await _storeGoogleUserData(response.user!, googleUser);
      }

      return response;
    } catch (e) {
      print('Google sign-in error details: $e');
      print('Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  // Store user data in the users table after successful signup
  Future<void> _storeUserData(User user, String? fullName) async {
    try {
      // Check if user already exists in our users table
      final existingUser = await _userRepository.getUserById(user.id);

      if (existingUser == null) {
        // Create new user record
        final userModel = UserModel(
          id: user.id,
          email: user.email ?? '',
          fullName: fullName ?? user.userMetadata?['full_name'] as String?,
          avatarUrl: user.userMetadata?['avatar_url'] as String?,
          createdAt: user.createdAt.isNotEmpty
              ? DateTime.tryParse(user.createdAt)
              : null,
          updatedAt: user.updatedAt?.isNotEmpty ?? false
              ? DateTime.tryParse(user.updatedAt!)
              : null,
          metadata: user.userMetadata,
        );

        await _userRepository.createUser(userModel);
        print('User data stored successfully in users table');
      } else {
        print('User already exists in users table');
      }
    } catch (e) {
      print('Error storing user data: $e');
      // Don't rethrow here to avoid breaking the signup flow
      // The user is still authenticated even if we can't store additional data
    }
  }

  // Store Google user data in the users table
  Future<void> _storeGoogleUserData(
    User user,
    GoogleSignInAccount googleUser,
  ) async {
    try {
      // Check if user already exists in our users table
      final existingUser = await _userRepository.getUserById(user.id);

      if (existingUser == null) {
        // Create new user record with Google data
        final userModel = UserModel(
          id: user.id,
          email: user.email ?? '',
          fullName:
              googleUser.displayName ??
              user.userMetadata?['full_name'] as String?,
          avatarUrl:
              googleUser.photoUrl ??
              user.userMetadata?['avatar_url'] as String?,
          createdAt: user.createdAt.isNotEmpty
              ? DateTime.tryParse(user.createdAt)
              : null,
          updatedAt: user.updatedAt?.isNotEmpty ?? false
              ? DateTime.tryParse(user.updatedAt!)
              : null,
          metadata: {
            ...?user.userMetadata,
            'google_id': googleUser.id,
            'provider': 'google',
          },
        );

        await _userRepository.createUser(userModel);
        print('Google user data stored successfully in users table');
      } else {
        // Update existing user with Google data if needed
        final updates = <String, dynamic>{};

        if (existingUser.fullName == null && googleUser.displayName != null) {
          updates['full_name'] = googleUser.displayName;
        }

        if (existingUser.avatarUrl == null && googleUser.photoUrl != null) {
          updates['avatar_url'] = googleUser.photoUrl;
        }

        if (updates.isNotEmpty) {
          updates['metadata'] = {
            ...?existingUser.metadata,
            'google_id': googleUser.id,
            'provider': 'google',
          };

          await _userRepository.updateUser(user.id, updates);
          print('Google user data updated successfully in users table');
        }
      }
    } catch (e) {
      print('Error storing Google user data: $e');
      // Don't rethrow here to avoid breaking the sign-in flow
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _client.auth.signOut();
  }

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Get current user model from our users table
  Future<UserModel?> getCurrentUserModel() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      return await _userRepository.getUserById(user.id);
    } catch (e) {
      print('Error getting current user model: $e');
      return null;
    }
  }

  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  // Reset password
  Future<void> resetPassword(String email) async {
    // For mobile app, we can use a custom scheme or universal link
    // For now, we'll use the Supabase hosted URL which allows password reset
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'io.supabase.bonique://reset-password', // Custom deep link
    );
  }

  // Ensure user exists in our users table (helper method)
  Future<void> _ensureUserExistsInDatabase(User user) async {
    try {
      // Check if user exists in our users table
      final existingUser = await _userRepository.getUserById(user.id);

      if (existingUser == null) {
        // User doesn't exist in our table, create them
        print('User not found in users table, creating record...');
        await _storeUserData(user, user.userMetadata?['full_name'] as String?);
      } else {
        print('User exists in users table: ${existingUser.email}');
      }
    } catch (e) {
      print('Error ensuring user exists in database: $e');
      // Don't rethrow - authentication should still work even if we can't store user data
    }
  }
}
