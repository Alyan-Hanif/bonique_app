import 'package:flutter/material.dart';

class DashedBorder extends StatelessWidget {
  final Widget child;
  final double strokeWidth;
  final Color color;
  final double dashLength;
  final double dashSpace;

  const DashedBorder({
    super.key,
    required this.child,
    this.strokeWidth = 2.0,
    this.color = Colors.grey,
    this.dashLength = 5.0,
    this.dashSpace = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DashedBorderPainter(
        strokeWidth: strokeWidth,
        color: color,
        dashLength: dashLength,
        dashSpace: dashSpace,
      ),
      child: child,
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;
  final double dashLength;
  final double dashSpace;

  DashedBorderPainter({
    required this.strokeWidth,
    required this.color,
    required this.dashLength,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(12),
      ));

    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final pathMetrics = path.computeMetrics();
    
    for (final pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final extractPath = pathMetric.extractPath(
          distance,
          distance + dashLength,
        );
        canvas.drawPath(extractPath, paint);
        distance += dashLength + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
