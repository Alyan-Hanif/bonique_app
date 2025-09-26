import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repository/auth_repository.dart';
import '../../../data/models/user_model.dart';

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
        userModel = await _repository.getCurrentUserModel();

        // ENFORCE: If user is authenticated but not in database, sign them out
        if (userModel == null) {
          print('User authenticated but not found in database. Signing out...');
          await _repository.signOut();
          state = AuthState();
          return;
        }
      } catch (e) {
        print('Error getting current user model: $e');
        // Sign out on error to ensure clean state
        await _repository.signOut();
        state = AuthState();
        return;
      }
    }

    state = state.copyWith(
      isLoggedIn:
          isLoggedIn &&
          userModel != null, // Only logged in if user exists in DB
      currentUserModel: userModel,
    );
  }

  // Form validation methods
  bool validateEmail(String email) {
    if (email.isEmpty) {
      state = state.copyWith(
        isEmailValid: false,
        emailError: 'Email is required',
      );
      return false;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      state = state.copyWith(
        isEmailValid: false,
        emailError: 'Please enter a valid email',
      );
      return false;
    }

    state = state.copyWith(isEmailValid: true, emailError: null);
    return true;
  }

  bool validatePassword(String password) {
    if (password.isEmpty) {
      state = state.copyWith(
        isPasswordValid: false,
        passwordError: 'Password is required',
      );
      return false;
    }

    if (password.length < 6) {
      state = state.copyWith(
        isPasswordValid: false,
        passwordError: 'Password must be at least 6 characters',
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
    // Validate inputs
    final isEmailValid = validateEmail(email);
    final isPasswordValid = validatePassword(password);

    if (!isEmailValid || !isPasswordValid) {
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _repository.signIn(email, password);

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

      if (e.toString().contains('Invalid login credentials') ||
          e.toString().contains('invalid_credentials')) {
        errorMessage =
            'Invalid email or password. Please check your credentials.';
      } else if (e.toString().contains('User not found')) {
        errorMessage =
            'No account found with this email. Please sign up first.';
      } else if (e.toString().contains('Email not confirmed')) {
        errorMessage =
            'Please check your email and confirm your account before signing in.';
      } else if (e.toString().contains('Too many requests')) {
        errorMessage =
            'Too many sign-in attempts. Please wait a moment and try again.';
      } else if (e.toString().contains('AuthSessionMissingException')) {
        errorMessage =
            'Connection error. Please check your internet connection and try again.';
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
    // Validate inputs
    final isEmailValid = validateEmail(email);
    final isPasswordValid = validatePassword(password);
    final isNameValid = validateName(fullName);
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

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _repository.signUp(
        email,
        password,
        fullName: fullName,
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

      if (e.toString().contains('User already registered')) {
        errorMessage =
            'An account with this email already exists. Please sign in instead.';
      } else if (e.toString().contains('Invalid email')) {
        errorMessage = 'Please enter a valid email address.';
      } else if (e.toString().contains('Password should be at least')) {
        errorMessage = 'Password must be at least 6 characters long.';
      } else if (e.toString().contains('AuthSessionMissingException')) {
        errorMessage =
            'Connection error. Please check your internet connection and try again.';
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
