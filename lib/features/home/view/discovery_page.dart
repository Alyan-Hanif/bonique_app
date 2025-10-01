import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/home_viewmodel.dart'; // Add this import

class DiscoveryPage extends ConsumerStatefulWidget {
  const DiscoveryPage({super.key});

  @override
  ConsumerState<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends ConsumerState<DiscoveryPage> {
  String? selectedEvent;
  String? selectedType;
  String? selectedColor;
  final TextEditingController _otherController = TextEditingController();

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  // Check if all options are selected
  bool get hasSelection =>
      selectedEvent != null && selectedType != null && selectedColor != null;

  @override
  Widget build(BuildContext context) {
    final maxContentWidth = 600.0; // Max width for content on larger screens

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom title bar with updated styling
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const Center(
                child: Text(
                  'Discover',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B1A18),
                  ),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        // Event Section
                        _buildSection(
                          title: 'Event',
                          options: ['Work', 'Casual', 'Party', 'Other'],
                          selectedValue: selectedEvent,
                          onChanged: (value) {
                            setState(() {
                              selectedEvent = value;
                            });
                          },
                        ),
                        const SizedBox(height: 15),

                        // Type Section
                        _buildSection(
                          title: 'Type',
                          options: ['Formal', 'Elegant', 'Fancy', 'Other'],
                          selectedValue: selectedType,
                          onChanged: (value) {
                            setState(() {
                              selectedType = value;
                            });
                          },
                        ),
                        const SizedBox(height: 15),

                        // Color Section
                        _buildSection(
                          title: 'Color',
                          options: ['Black', 'White'],
                          selectedValue: selectedColor,
                          onChanged: (value) {
                            setState(() {
                              selectedColor = value;
                            });
                          },
                        ),
                        const SizedBox(height: 15),

                        // Conditional input field for Event "Other"
                        if (selectedEvent == 'Other') ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0x6D797F99),
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: _otherController,
                              decoration: const InputDecoration(
                                hintText: 'Type your preference',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                        ],

                        // Conditional input field for Type "Other"
                        if (selectedType == 'Other') ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0x6D797F99),
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: 'Type your preference',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                        ],
                        const SizedBox(height: 80), // Space for floating button
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Floating Discover Button (similar to wardrobe page)
      floatingActionButton: hasSelection
          ? FloatingActionButton.extended(
              onPressed: () {
                // Navigate to results page
                ref.read(bottomNavigationIndexProvider.notifier).state = 4;
              },
              backgroundColor: const Color(0xFF1B1A18),
              label: const Text(
                'Discover',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
      bottomNavigationBar: const SizedBox(height: 0),
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
            color: Color(0xFF1B1A18),
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
          color: isSelected ? const Color(0x1B1A1842) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1B1A18)
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
                  color: isSelected ? const Color(0xFF1B1A18) : Colors.grey,
                  width: 2,
                ),
                color: isSelected
                    ? const Color(0xFF1B1A18)
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.circle, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              option,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF1B1A18)
                    : const Color(0xFF1B1A18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
