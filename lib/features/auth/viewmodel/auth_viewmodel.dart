import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repository/auth_repository.dart';
import '../../../data/models/user_model.dart';
import '../../../core/utils/connectivity_utils.dart';
import '../../../core/services/user_profile_cache_service.dart';

// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Auth State class
class AuthState {
  final bool isLoading;
  final String? error;
  final bool isLoggedIn;
  final bool isEmailValid;
  final bool isPasswordValid;
  final bool isNameValid;
  // final bool isConfirmPasswordValid;
  final String? emailError;
  final String? passwordError;
  final String? nameError;
  // final String? confirmPasswordError;
  final bool isPasswordVisible;
  // final bool isConfirmPasswordVisible;
  final bool agreeToTerms;
  final UserModel? currentUserModel;

  AuthState({
    this.isLoading = false,
    this.error,
    this.isLoggedIn = false,
    this.isEmailValid = true,
    this.isPasswordValid = true,
    this.isNameValid = true,
    // this.isConfirmPasswordValid = true,
    this.emailError,
    this.passwordError,
    this.nameError,
    // this.confirmPasswordError,
    this.isPasswordVisible = false,
    // this.isConfirmPasswordVisible = false,
    this.agreeToTerms = false,
    this.currentUserModel,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    bool? isLoggedIn,
    bool? isEmailValid,
    bool? isPasswordValid,
    // isConfirmPasswordValid: false,
    bool? isNameValid,
    // bool? isConfirmPasswordValid,
    String? emailError,
    String? passwordError,
    String? nameError,
    // String? confirmPasswordError,
    bool? isPasswordVisible,
    // bool? isConfirmPasswordVisible,
    bool? agreeToTerms,
    UserModel? currentUserModel,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      isNameValid: isNameValid ?? this.isNameValid,
      // isConfirmPasswordValid:
      //     isConfirmPasswordValid ?? this.isConfirmPasswordValid,
      emailError: emailError,
      passwordError: passwordError,
      nameError: nameError,
      // confirmPasswordError: confirmPasswordError,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      // isConfirmPasswordVisible:
      // isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
      agreeToTerms: agreeToTerms ?? this.agreeToTerms,
      currentUserModel: currentUserModel ?? this.currentUserModel,
    );
  }
}

// Auth ViewModel
class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthViewModel(this._repository) : super(AuthState()) {
    // Check initial authentication status
    _checkInitialAuthStatus();
  }

  // Check initial authentication status
  void _checkInitialAuthStatus() async {
    final isLoggedIn = _repository.isLoggedIn;
    UserModel? userModel;

    if (isLoggedIn) {
      try {
        print('🔍 Checking initial auth status...');
        userModel = await _repository.getCurrentUserModel();

        if (userModel != null) {
          print('✅ User found in database: ${userModel.email}');
        } else {
          print('⚠️ User authenticated but not found in database.');
          // DON'T log out immediately - the user might be in the middle of signup
          // or there might be a temporary database issue
          // Instead, just set the state and let the app flow handle it
        }
      } catch (e) {
        print('Error getting current user model: $e');
        // When offline/network error: use cached user or build from local session
        final user = _repository.currentUser;
        if (user != null && _isNetworkError(e)) {
          final cached = UserProfileCacheService.load(user.id);
          if (cached != null) {
            print('📦 Using cached user profile (offline)');
            state = state.copyWith(isLoggedIn: true, currentUserModel: cached);
            return;
          }
          // No cache (e.g. fresh install): use Supabase session so we stay logged in
          final fallback = UserModel.fromSupabaseUser(user);
          print('📦 Using session fallback (offline, no cache)');
          state = state.copyWith(isLoggedIn: true, currentUserModel: fallback);
          return;
        }
        try {
          await _repository.signOut();
        } catch (_) {}
        state = AuthState();
        return;
      }
    }

    state = state.copyWith(
      isLoggedIn: isLoggedIn, // Trust Supabase session
      currentUserModel: userModel,
    );
  }

  static bool _isNetworkError(Object e) {
    if (e is SocketException) return true;
    if (e is OSError && e.message.contains('hostname')) return true;
    final msg = e.toString().toLowerCase();
    return msg.contains('socketexception') ||
        msg.contains('failed host lookup') ||
        msg.contains('no address associated with hostname') ||
        msg.contains('errno = 7') ||
        msg.contains('host lookup') ||
        msg.contains('authretryablefetchexception') ||
        (msg.contains('connection') && msg.contains('refused'));
  }

  // Form validation methods
  bool validateEmail(String email) {
    // Trim whitespace
    final trimmedEmail = email.trim();

    if (trimmedEmail.isEmpty) {
      state = state.copyWith(
        isEmailValid: false,
        emailError: 'Email is required',
      );
      return false;
    }

    // Check for whitespace (leading/trailing spaces were removed, but internal spaces are invalid)
    if (trimmedEmail.contains(' ')) {
      state = state.copyWith(
        isEmailValid: false,
        emailError: 'Email cannot contain spaces',
      );
      return false;
    }

    // More strict email validation
    // Must have: local part + @ + domain + . + TLD (at least 2 chars)
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$',
    );

    if (!emailRegex.hasMatch(trimmedEmail)) {
      state = state.copyWith(
        isEmailValid: false,
        emailError: 'Please enter a valid email address',
      );
      return false;
    }

    // Additional checks for edge cases
    // Check for invalid patterns like user@com, user@., etc.
    final parts = trimmedEmail.split('@');
    if (parts.length != 2) {
      state = state.copyWith(
        isEmailValid: false,
        emailError: 'Please enter a valid email address',
      );
      return false;
    }

    final localPart = parts[0];
    final domainPart = parts[1];

    // Check local part is not empty
    if (localPart.isEmpty) {
      state = state.copyWith(
        isEmailValid: false,
        emailError: 'Email must have a username before @',
      );
      return false;
    }

    // Check domain has at least one dot and valid structure
    if (!domainPart.contains('.') ||
        domainPart.startsWith('.') ||
        domainPart.endsWith('.')) {
      state = state.copyWith(
        isEmailValid: false,
        emailError: 'Please enter a valid email domain',
      );
      return false;
    }

    // Check TLD (top-level domain) is at least 2 characters
    final domainParts = domainPart.split('.');
    final tld = domainParts.last;
    if (tld.length < 2) {
      state = state.copyWith(
        isEmailValid: false,
        emailError: 'Email domain must end with a valid extension',
      );
      return false;
    }

    state = state.copyWith(isEmailValid: true, emailError: null);
    return true;
  }

  bool validatePassword(String password) {
    // Check for leading or trailing spaces (passwords should not be trimmed as spaces might be intentional)
    if (password != password.trim()) {
      state = state.copyWith(
        isPasswordValid: false,
        passwordError: 'Password cannot have leading or trailing spaces',
      );
      return false;
    }

    if (password.isEmpty) {
      state = state.copyWith(
        isPasswordValid: false,
        passwordError: 'Password is required',
      );
      return false;
    }

    if (password.length < 8) {
      state = state.copyWith(
        isPasswordValid: false,
        passwordError: 'Password must be at least 8 characters',
      );
      return false;
    }

    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      state = state.copyWith(
        isPasswordValid: false,
        passwordError: 'Password must contain at least one uppercase letter',
      );
      return false;
    }

    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      state = state.copyWith(
        isPasswordValid: false,
        passwordError: 'Password must contain at least one lowercase letter',
      );
      return false;
    }

    // Check for at least one number
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      state = state.copyWith(
        isPasswordValid: false,
        passwordError: 'Password must contain at least one number',
      );
      return false;
    }

    // Check for at least one special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\\/~`]').hasMatch(password)) {
      state = state.copyWith(
        isPasswordValid: false,
        passwordError:
            r'Password must contain at least one special character (!@#$%^&*...)',
      );
      return false;
    }

    state = state.copyWith(isPasswordValid: true, passwordError: null);
    return true;
  }

  bool validateName(String name) {
    if (name.isEmpty) {
      state = state.copyWith(
        isNameValid: false,
        nameError: 'Full name is required',
      );
      return false;
    }

    if (name.length < 2) {
      state = state.copyWith(
        isNameValid: false,
        nameError: 'Name must be at least 2 characters',
      );
      return false;
    }

    state = state.copyWith(isNameValid: true, nameError: null);
    return true;
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  // Toggle terms agreement
  void toggleTermsAgreement() {
    state = state.copyWith(agreeToTerms: !state.agreeToTerms);
  }

  //Authentication with Google

  // Authentication methods
  Future<bool> signIn(String email, String password) async {
    // Trim email
    final trimmedEmail = email.trim();

    // Validate inputs
    final isEmailValid = validateEmail(trimmedEmail);
    final isPasswordValid = validatePassword(password);

    if (!isEmailValid || !isPasswordValid) {
      return false;
    }

    // Prevent double submission by checking if already loading
    if (state.isLoading) {
      return false;
    }

    // Check internet connectivity before attempting sign in
    final hasConnection = await ConnectivityUtils.hasInternetConnection();
    if (!hasConnection) {
      state = state.copyWith(
        error:
            'No internet connection. Please check your network and try again.',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _repository.signIn(trimmedEmail, password);

      // Check if sign-in was successful by verifying the user exists
      if (response.user != null) {
        // Get user model from our users table
        final userModel = await _repository.getCurrentUserModel();

        // ENFORCE: User must exist in database to proceed
        if (userModel == null) {
          state = state.copyWith(
            isLoading: false,
            error: 'User account not found. Please contact support.',
          );
          return false;
        }

        state = state.copyWith(
          isLoading: false,
          isLoggedIn: true,
          currentUserModel: userModel,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Sign-in failed. Please check your credentials.',
        );
        return false;
      }
    } catch (e) {
      // Provide more user-friendly error messages
      String errorMessage = 'Sign-in failed. Please try again.';

      final errorString = e.toString().toLowerCase();

      if (errorString.contains('invalid login credentials') ||
          errorString.contains('invalid_credentials') ||
          errorString.contains('invalid login') ||
          errorString.contains('wrong password') ||
          errorString.contains('incorrect password')) {
        errorMessage =
            'Invalid email or password. Please check your credentials and try again.';
      } else if (errorString.contains('user not found') ||
          errorString.contains('no user found') ||
          errorString.contains('user does not exist')) {
        errorMessage =
            'No account found with this email. Please sign up first.';
      } else if (errorString.contains('email not confirmed') ||
          errorString.contains('email not verified') ||
          errorString.contains('confirm your email') ||
          errorString.contains('verify your email')) {
        errorMessage =
            'Please verify your email address before signing in. Check your inbox for the verification link.';
      } else if (errorString.contains('user disabled') ||
          errorString.contains('account disabled') ||
          errorString.contains('account has been disabled') ||
          errorString.contains('user banned')) {
        errorMessage =
            'Your account has been disabled. Please contact support for assistance.';
      } else if (errorString.contains('account deleted') ||
          errorString.contains('user deleted')) {
        errorMessage =
            'This account no longer exists. Please sign up for a new account.';
      } else if (errorString.contains('too many requests') ||
          errorString.contains('rate limit') ||
          errorString.contains('too many attempts')) {
        errorMessage =
            'Too many sign-in attempts. Please wait a few minutes and try again.';
      } else if (errorString.contains('network') ||
          errorString.contains('failed to connect') ||
          errorString.contains('unable to resolve host')) {
        errorMessage =
            'Network error. Please check your internet connection and try again.';
      } else if (errorString.contains('timeout') ||
          errorString.contains('timed out')) {
        errorMessage =
            'Request timed out. Please check your connection and try again.';
      } else if (errorString.contains('server') ||
          errorString.contains('503') ||
          errorString.contains('502') ||
          errorString.contains('500') ||
          errorString.contains('internal server error')) {
        errorMessage =
            'Server is temporarily unavailable. Please try again later.';
      } else if (errorString.contains('authsessionmissingexception')) {
        errorMessage =
            'Connection error. Please check your internet connection and try again.';
      } else if (errorString.contains('socketexception')) {
        errorMessage =
            'No internet connection. Please check your network and try again.';
      }

      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    }
  }

  Future<bool> signUp(
    String email,
    String password,
    String fullName,
    // String confirmPassword,
  ) async {
    // Trim email and full name
    final trimmedEmail = email.trim();
    final trimmedFullName = fullName.trim();

    // Validate inputs
    final isEmailValid = validateEmail(trimmedEmail);
    final isPasswordValid = validatePassword(password);
    final isNameValid = validateName(trimmedFullName);
    // final isConfirmPasswordValid = validateConfirmPassword(
    //   password
    //   confirmPassword,
    // );

    if (!isEmailValid || !isPasswordValid || !isNameValid
    // ||
    // !isConfirmPasswordValid
    ) {
      return false;
    }

    if (!state.agreeToTerms) {
      state = state.copyWith(
        error: 'Please agree to the Terms of Service and Privacy Policy',
      );
      return false;
    }

    // Prevent double submission by checking if already loading
    if (state.isLoading) {
      return false;
    }

    // Check internet connectivity before attempting signup
    final hasConnection = await ConnectivityUtils.hasInternetConnection();
    if (!hasConnection) {
      state = state.copyWith(
        error:
            'No internet connection. Please check your network and try again.',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _repository.signUp(
        trimmedEmail,
        password,
        fullName: trimmedFullName,
      );

      // Check if signup was successful
      if (response.user != null) {
        // Get user model from our users table
        final userModel = await _repository.getCurrentUserModel();

        // ENFORCE: User must exist in database to proceed
        if (userModel == null) {
          state = state.copyWith(
            isLoading: false,
            error:
                'Account created but profile setup failed. Please try signing in.',
          );
          return false;
        }

        state = state.copyWith(
          isLoading: false,
          isLoggedIn: true,
          currentUserModel: userModel,
        );
        return true;
      } else {
        // Handle case where user needs email confirmation
        state = state.copyWith(
          isLoading: false,
          error:
              'Please check your email to confirm your account before signing in.',
        );
        return false;
      }
    } catch (e) {
      // Provide more user-friendly error messages
      String errorMessage = 'Signup failed. Please try again.';

      final errorString = e.toString().toLowerCase();

      if (errorString.contains('user already registered') ||
          errorString.contains('already been registered') ||
          errorString.contains('duplicate') ||
          errorString.contains('already exists')) {
        errorMessage =
            'An account with this email already exists. Please sign in instead.';
      } else if (errorString.contains('invalid email') ||
          errorString.contains('email format')) {
        errorMessage = 'Please enter a valid email address.';
      } else if (errorString.contains('password should be at least')) {
        errorMessage = 'Password must be at least 6 characters long.';
      } else if (errorString.contains('network') ||
          errorString.contains('failed to connect') ||
          errorString.contains('unable to resolve host')) {
        errorMessage =
            'Network error. Please check your internet connection and try again.';
      } else if (errorString.contains('timeout') ||
          errorString.contains('timed out')) {
        errorMessage =
            'Request timed out. Please check your connection and try again.';
      } else if (errorString.contains('server') ||
          errorString.contains('503') ||
          errorString.contains('502') ||
          errorString.contains('500')) {
        errorMessage =
            'Server is temporarily unavailable. Please try again later.';
      } else if (errorString.contains('authsessionmissingexception')) {
        errorMessage =
            'Connection error. Please check your internet connection and try again.';
      } else if (errorString.contains('socketexception')) {
        errorMessage =
            'No internet connection. Please check your network and try again.';
      }

      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    final isEmailValid = validateEmail(email);
    if (!isEmailValid) {
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.resetPassword(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.signInWithGoogle();

      // Get user model from our users table
      final userModel = await _repository.getCurrentUserModel();

      // ENFORCE: User must exist in database to proceed
      if (userModel == null) {
        state = state.copyWith(
          isLoading: false,
          error:
              'Google sign-in successful but profile setup failed. Please try again.',
        );
        return false;
      }

      state = state.copyWith(
        isLoading: false,
        isLoggedIn: true,
        currentUserModel: userModel,
      );
      return true;
    } catch (e) {
      String errorMessage = 'Google sign-in failed. Please try again.';

      if (e.toString().contains('sign-in was cancelled')) {
        errorMessage = 'Sign-in was cancelled';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your internet connection.';
      }

      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    }
  }

  void signOut() async {
    await _repository.signOut();
    state = AuthState();
  }

  // Refresh current user model
  Future<void> refreshUserModel() async {
    if (state.isLoggedIn) {
      try {
        final userModel = await _repository.getCurrentUserModel();
        state = state.copyWith(currentUserModel: userModel);
      } catch (e) {
        print('Error refreshing user model: $e');
      }
    }
  }

  // Update current user model (used after profile updates)
  void updateCurrentUser(UserModel userModel) {
    state = state.copyWith(currentUserModel: userModel);
  }

  // Check if user is already logged in
  bool get isUserLoggedIn => _repository.isLoggedIn;

  User? get currentUser => _repository.currentUser;
}

// Provider for AuthViewModel
final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((
  ref,
) {
  return AuthViewModel(ref.read(authRepositoryProvider));
});
