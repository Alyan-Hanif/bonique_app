import 'package:bonique/features/home/widgets/home_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TryOnPage extends ConsumerWidget {
  const TryOnPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Try On'),
      //   backgroundColor: const Color(0xFFFF6B2C),
      //   foregroundColor: Colors.white,
      // ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Center(
                child: Text(
                  'Try-On',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(color: Colors.black12),
              ),
            ),

            TryOnBtn(text: "Try Another ", onPressed: () {}, isLoading: false),

            SizedBox(height: 10),

            SaveOutfitBtn(text: "Save Outfit ", onPressed: () {}, isLoading: false),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
