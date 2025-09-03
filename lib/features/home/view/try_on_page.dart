import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TryOnPage extends ConsumerWidget {
  const TryOnPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Try On'),
        backgroundColor: const Color(0xFFFF6B2C),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Virtual Try-On',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try clothes virtually before you buy',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 64,
                      color: Color(0xFFFF6B2C),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Try-on feature will appear here',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 