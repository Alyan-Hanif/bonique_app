import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';

@immutable
class HomeState {
  const HomeState({this.username});
  final String? username;

  HomeState copyWith({String? username}) =>
      HomeState(username: username ?? this.username);
}

final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>(
  (ref) {
    return HomeController(ref);
  },
);

class HomeController extends StateNotifier<HomeState> {
  final Ref _ref;

  HomeController(this._ref) : super(const HomeState());

  void setUsername(String name) {
    state = state.copyWith(username: name);
  }

  Future<void> signOut() async {
    try {
      // Use the AuthViewModel to handle logout
      final authViewModel = _ref.read(authViewModelProvider.notifier);
      authViewModel.signOut();

      debugPrint('User signed out successfully');
    } catch (e) {
      debugPrint('Error during sign out: $e');
    }
  }
}

// Bottom navigation index provider
final bottomNavigationIndexProvider = StateProvider<int>((ref) => 0);
