/// FitTrack — Gradient blob widget
///
/// A decorative organic-shaped gradient background used in the
/// onboarding screens, painted with CustomPainter. Matches the
/// flowing blob shapes from the DIDPOOLFit Figma design.
library;
import 'package:flutter/material.dart';

class GradientBlob extends StatelessWidget {
  final List<Color> gradientColors;
  final double? width;
  final double? height;

  const GradientBlob({
    super.key,
    required this.gradientColors,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double blobWidth = width ?? screenSize.width;
    final double blobHeight = height ?? screenSize.height * 0.55;

    return SizedBox(
      width: blobWidth,
      height: blobHeight,
      child: CustomPaint(
        size: Size(blobWidth, blobHeight),
        painter: _BlobPainter(gradientColors: gradientColors),
      ),
    );
  }
}

class _BlobPainter extends CustomPainter {
  final List<Color> gradientColors;

  _BlobPainter({required this.gradientColors});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = LinearGradient(
        colors: gradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final Path path = Path();

    // Organic blob shape matching the Figma design
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.7);

    // Right-side curve
    path.cubicTo(
      size.width * 0.85,
      size.height * 0.95,
      size.width * 0.65,
      size.height * 1.05,
      size.width * 0.5,
      size.height * 0.9,
    );

    // Left-side curve
    path.cubicTo(
      size.width * 0.35,
      size.height * 0.75,
      size.width * 0.15,
      size.height * 0.85,
      0,
      size.height * 0.75,
    );

    path.close();
    canvas.drawPath(path, paint);

    // Secondary transparent layer for depth
    final Paint overlayPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08);

    final Path overlayPath = Path();
    overlayPath.moveTo(size.width * 0.1, 0);
    overlayPath.lineTo(size.width * 0.9, 0);
    overlayPath.lineTo(size.width * 0.9, size.height * 0.5);

    overlayPath.cubicTo(
      size.width * 0.8,
      size.height * 0.7,
      size.width * 0.5,
      size.height * 0.8,
      size.width * 0.3,
      size.height * 0.65,
    );

    overlayPath.cubicTo(
      size.width * 0.15,
      size.height * 0.55,
      size.width * 0.1,
      size.height * 0.4,
      size.width * 0.1,
      size.height * 0.3,
    );

    overlayPath.close();
    canvas.drawPath(overlayPath, overlayPaint);
  }

  @override
  bool shouldRepaint(covariant _BlobPainter oldDelegate) {
    return oldDelegate.gradientColors != gradientColors;
  }
}
