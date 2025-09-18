import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom title bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    const SizedBox(height: 24),

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
                    const SizedBox(height: 24),

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
                    const SizedBox(height: 24),

                    // Conditional input field for Event "Other"
                    if (selectedEvent == 'Other') ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.27),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              offset: const Offset(0, -4),
                              blurRadius: 8.4,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.21),
                              offset: const Offset(0, 4),
                              blurRadius: 8.4,
                            ),
                          ],
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
                      const SizedBox(height: 24),
                    ],

                    // Conditional input field for Type "Other"
                    if (selectedType == 'Other') ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.27),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              offset: const Offset(0, -4),
                              blurRadius: 8.4,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.21),
                              offset: const Offset(0, 4),
                              blurRadius: 8.4,
                            ),
                          ],
                        ),
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Type your preference',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: const Color(0xFF1B1A18),
      //   onPressed: () {},
      //   child: const Icon(Icons.add, color: Colors.white),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // bottomNavigationBar: Container(
      //   height: 80,
      //   decoration: const BoxDecoration(
      //     color: Color(0xFF1B1A18),
      //     borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      //   ),
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //     children: [
      //       _buildNavItem(Icons.checkroom, 'Wardrobe', false),
      //       _buildNavItem(Icons.search, 'Discover', true),
      //       Container(
      //         width: 60,
      //         height: 60,
      //         decoration: const BoxDecoration(
      //           color: Color(0xFF1B1A18),
      //           shape: BoxShape.circle,
      //         ),
      //         child: const Icon(Icons.add, color: Colors.white, size: 30),
      //       ),
      //       _buildNavItem(Icons.checkroom, 'Try-On', false),
      //       _buildNavItem(Icons.person, 'Profile', false),
      //     ],
      //   ),
      // ),
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
            fontSize: 16,
            fontWeight: FontWeight.w600,
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
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1B1A18) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1B1A18)
                : Colors.black.withOpacity(0.27),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              offset: const Offset(0, -4),
              blurRadius: 8.4,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.21),
              offset: const Offset(0, 4),
              blurRadius: 8.4,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.grey,
                  width: 2,
                ),
                color: isSelected ? Colors.white : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.circle, size: 12, color: Color(0xFF1B1A18))
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              option,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF1B1A18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isActive ? Colors.white : Colors.grey, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
