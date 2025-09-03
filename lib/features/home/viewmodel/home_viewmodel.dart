import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class HomeState {
  const HomeState({this.username});
  final String? username;

  HomeState copyWith({String? username}) => HomeState(
        username: username ?? this.username,
      );
}

final homeControllerProvider =
    StateNotifierProvider<HomeController, HomeState>((ref) {
  return HomeController();
});

class HomeController extends StateNotifier<HomeState> {
  HomeController() : super(const HomeState());

  void setUsername(String name) {
    state = state.copyWith(username: name);
  }

  void signOut() {
    // For now simply print; navigation will be handled by caller
    debugPrint('Sign out tapped');
  }
} 