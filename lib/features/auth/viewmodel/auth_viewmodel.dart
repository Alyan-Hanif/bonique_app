import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthState {
  final bool isLoading;
  final String? error;
  final bool isLoggedIn;
  final bool isEmailValid;
  final bool isPasswordValid;
  final bool isConfirmPasswordValid;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;

  AuthState({
    this.isLoading = false,
    this.error,
    this.isLoggedIn = false,
    this.isEmailValid = true,
    this.isPasswordValid = true,
    this.isConfirmPasswordValid = true,
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    bool? isLoggedIn,
    bool? isEmailValid,
    bool? isPasswordValid,
    bool? isConfirmPasswordValid,
    String? emailError,
    String? passwordError,
    String? confirmPasswordError,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      isConfirmPasswordValid:
          isConfirmPasswordValid ?? this.isConfirmPasswordValid,
      emailError: emailError,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthViewModel(this._repository) : super(AuthState());

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

  bool validateConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      state = state.copyWith(
        isConfirmPasswordValid: false,
        confirmPasswordError: 'Please confirm your password',
      );
      return false;
    }

    if (confirmPassword != password) {
      state = state.copyWith(
        isConfirmPasswordValid: false,
        confirmPasswordError: 'Passwords do not match',
      );
      return false;
    }

    state = state.copyWith(
      isConfirmPasswordValid: true,
      confirmPasswordError: null,
    );
    return true;
  }

  // Clear validation errors
  void clearValidationErrors() {
    state = state.copyWith(
      error: null,
      emailError: null,
      passwordError: null,
      confirmPasswordError: null,
    );
  }

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
      await _repository.signIn(email, password);
      state = state.copyWith(isLoading: false, isLoggedIn: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> signUp(
    String email,
    String password,
    String confirmPassword,
  ) async {
    // Validate inputs
    final isEmailValid = validateEmail(email);
    final isPasswordValid = validatePassword(password);
    final isConfirmPasswordValid = validateConfirmPassword(
      password,
      confirmPassword,
    );

    if (!isEmailValid || !isPasswordValid || !isConfirmPasswordValid) {
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.signUp(email, password);
      state = state.copyWith(isLoading: false, isLoggedIn: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void signOut() async {
    await _repository.signOut();
    state = AuthState();
  }

  // Check if user is already logged in
  bool get isUserLoggedIn => _repository.currentUser != null;
}

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((
  ref,
) {
  return AuthViewModel(ref.read(authRepositoryProvider));
});
