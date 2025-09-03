import 'package:flutter/material.dart';

class PhoneMock extends StatelessWidget {
  const PhoneMock({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 9 / 19.5,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
          border: Border.all(color: Colors.black12, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Screen content
            Positioned.fill(
              child: Container(
                color: Colors.white,
                child: child,
              ),
            ),
            // Simple notch at the top center
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 110,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 