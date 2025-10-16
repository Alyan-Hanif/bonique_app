import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/home_viewmodel.dart';
import '../viewmodel/discovery_viewmodel.dart';
import 'results_page.dart';

class DiscoveryPage extends ConsumerStatefulWidget {
  const DiscoveryPage({super.key});

  @override
  ConsumerState<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends ConsumerState<DiscoveryPage> {
  @override
  void initState() {
    super.initState();
    // Fetch questions when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(discoveryControllerProvider.notifier).fetchQuestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxContentWidth = 600.0; // Max width for content on larger screens
    final discoveryState = ref.watch(discoveryControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom title bar with updated styling
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Center(
                child: Text(
                  'Discover',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            // Content
            Expanded(
              child: _buildContent(context, discoveryState, maxContentWidth),
            ),
          ],
        ),
      ),
      // Floating Discover Button (similar to wardrobe page)
      floatingActionButton: discoveryState.hasAllAnswers
          ? FloatingActionButton.extended(
              onPressed: () {
                // Collect selected answers and join them with spaces
                final selectedAnswersText = discoveryState
                    .selectedAnswers
                    .values
                    .join(' ');
                print('🔍 Selected answers: $selectedAnswersText');

                // Store the answers in the provider
                ref.read(discoveryAnswersProvider.notifier).state =
                    selectedAnswersText;

                // Navigate to results page
                ref.read(bottomNavigationIndexProvider.notifier).state = 4;
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              label: const Text(
                'Discover',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
      bottomNavigationBar: const SizedBox(height: 0),
    );
  }

  Widget _buildContent(
    BuildContext context,
    DiscoveryState state,
    double maxContentWidth,
  ) {
    // Show loading indicator
    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    // Show error message
    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Failed to load questions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ref
                      .read(discoveryControllerProvider.notifier)
                      .fetchQuestions();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show questions
    if (state.questions.isEmpty) {
      return Center(
        child: Text(
          'No questions available',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // Dynamically build sections from API data
              ...state.questions.asMap().entries.map((entry) {
                final index = entry.key;
                final question = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: _buildSection(
                    title: question.question,
                    options: question.options,
                    selectedValue: state.selectedAnswers[index],
                    onChanged: (value) {
                      ref
                          .read(discoveryControllerProvider.notifier)
                          .selectAnswer(index, value!);
                    },
                  ),
                );
              }),
              const SizedBox(height: 80), // Space for floating button
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<String> options,
    required String? selectedValue,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.5, // line-height: 24px / font-size: 16px = 1.5
            letterSpacing: 0,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        ...options.map(
          (option) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildOptionCard(
              option: option,
              isSelected: selectedValue == option,
              onTap: () => onChanged(option),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard({
    required String option,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : const Color(0x6D797F99),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                  width: 2,
                ),
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.circle, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              option,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
