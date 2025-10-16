import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/discovery_question_model.dart';
import '../../../data/repositories/discovery_repository.dart';

@immutable
class DiscoveryState {
  final List<DiscoveryQuestion> questions;
  final Map<int, String>
  selectedAnswers; // Map of question index to selected option
  final bool isLoading;
  final String? errorMessage;

  const DiscoveryState({
    this.questions = const [],
    this.selectedAnswers = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  DiscoveryState copyWith({
    List<DiscoveryQuestion>? questions,
    Map<int, String>? selectedAnswers,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DiscoveryState(
      questions: questions ?? this.questions,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get hasAllAnswers =>
      questions.isNotEmpty && selectedAnswers.length == questions.length;
}

// Provider for the DiscoveryRepository
final discoveryRepositoryProvider = Provider<DiscoveryRepository>((ref) {
  return DiscoveryRepository();
});

// Provider for the DiscoveryController
final discoveryControllerProvider =
    StateNotifierProvider<DiscoveryController, DiscoveryState>((ref) {
      final repository = ref.watch(discoveryRepositoryProvider);
      return DiscoveryController(repository);
    });

class DiscoveryController extends StateNotifier<DiscoveryState> {
  final DiscoveryRepository _repository;

  DiscoveryController(this._repository) : super(const DiscoveryState());

  /// Fetches discovery questions from the API
  Future<void> fetchQuestions() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      print('🔄 Starting to fetch discovery questions...');
      final response = await _repository.fetchDiscoveryQuestions();
      print(
        '✅ Questions fetched successfully: ${response.questions.length} questions',
      );
      state = state.copyWith(questions: response.questions, isLoading: false);
    } catch (e) {
      print('❌ Error in fetchQuestions: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      debugPrint('Error fetching discovery questions: $e');
    }
  }

  /// Selects an answer for a specific question
  void selectAnswer(int questionIndex, String answer) {
    final updatedAnswers = Map<int, String>.from(state.selectedAnswers);
    updatedAnswers[questionIndex] = answer;
    state = state.copyWith(selectedAnswers: updatedAnswers);
  }

  /// Clears all selected answers
  void clearAnswers() {
    state = state.copyWith(selectedAnswers: {});
  }

  /// Resets the entire state
  void reset() {
    state = const DiscoveryState();
  }
}
