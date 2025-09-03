import 'package:flutter/material.dart';

class HomeGreeting extends StatelessWidget {
  const HomeGreeting({super.key, required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Hello, \\${name.isEmpty ? 'Guest' : name}',
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(fontWeight: FontWeight.w700),
    );
  }
} 