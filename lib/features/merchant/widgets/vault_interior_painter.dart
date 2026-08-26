import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 🏦 VaultInteriorPainter: The dark interior cavity of the vault
// ─────────────────────────────────────────────────────────────────────────────

class VaultInteriorPainter extends CustomPainter {
  final double doorOpenProgress; // 0.0 → 1.0

  const VaultInteriorPainter({this.doorOpenProgress = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Deep dark interior background
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF0A0F0C),
          Color(0xFF0D1A14),
          Color(0xFF081210),
          Color(0xFF050A08),
        ],
        stops: [0.0, 0.3, 0.7, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // 2. Subtle back wall texture (very faint horizontal lines)
    final texturePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.015)
      ..strokeWidth = 0.5;
    for (double y = 0; y < size.height; y += 6) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), texturePaint);
    }

    // 3. Top LED light — warm amber glow from above
    if (doorOpenProgress > 0.3) {
      final ledOpacity = ((doorOpenProgress - 0.3) / 0.7).clamp(0.0, 1.0);
      final ledCenter = Offset(size.width * 0.5, 0);
      canvas.drawCircle(
        ledCenter,
        size.width * 0.35,
        Paint()
          ..shader =
              RadialGradient(
                center: Alignment.topCenter,
                radius: 0.6,
                colors: [
                  Color.fromRGBO(245, 158, 11, 0.12 * ledOpacity),
                  Color.fromRGBO(245, 158, 11, 0.04 * ledOpacity),
                  Colors.transparent,
                ],
              ).createShader(
                Rect.fromCircle(center: ledCenter, radius: size.width * 0.35),
              ),
      );

      // Small LED dot
      canvas.drawCircle(
        Offset(size.width * 0.5, 6),
        3,
        Paint()
          ..color = Color.fromRGBO(252, 211, 77, 0.7 * ledOpacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      canvas.drawCircle(
        Offset(size.width * 0.5, 6),
        1.5,
        Paint()..color = Color.fromRGBO(254, 243, 199, 0.9 * ledOpacity),
      );
    }

    // 4. Metallic shelf lines (decorative)
    if (doorOpenProgress > 0.5) {
      final shelfOpacity = ((doorOpenProgress - 0.5) / 0.5).clamp(0.0, 1.0);
      final shelfPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            Color.fromRGBO(110, 231, 183, 0.08 * shelfOpacity),
            Color.fromRGBO(110, 231, 183, 0.15 * shelfOpacity),
            Color.fromRGBO(110, 231, 183, 0.08 * shelfOpacity),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, 2))
        ..strokeWidth = 1.0;

      // Two shelf lines
      canvas.drawLine(
        Offset(size.width * 0.1, size.height * 0.08),
        Offset(size.width * 0.9, size.height * 0.08),
        shelfPaint,
      );
      canvas.drawLine(
        Offset(size.width * 0.1, size.height * 0.92),
        Offset(size.width * 0.9, size.height * 0.92),
        shelfPaint,
      );
    }

    // 5. Left-side door shadow (cast by the open door)
    if (doorOpenProgress > 0.4) {
      final shadowOpacity =
          ((doorOpenProgress - 0.4) / 0.6).clamp(0.0, 1.0) * 0.4;
      final shadowWidth = size.width * 0.15 * doorOpenProgress;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, shadowWidth, size.height),
        Paint()
          ..shader = LinearGradient(
            colors: [
              Color.fromRGBO(0, 0, 0, shadowOpacity),
              Colors.transparent,
            ],
          ).createShader(Rect.fromLTWH(0, 0, shadowWidth, size.height)),
      );
    }

    // 6. Inner border glow (ambient emerald rim)
    if (doorOpenProgress > 0.6) {
      final glowOpacity = ((doorOpenProgress - 0.6) / 0.4).clamp(0.0, 1.0);
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 2, size.width - 4, size.height - 4),
        const Radius.circular(14),
      );
      canvas.drawRRect(
        rrect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = Color.fromRGBO(16, 185, 129, 0.15 * glowOpacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant VaultInteriorPainter oldDelegate) {
    return oldDelegate.doorOpenProgress != doorOpenProgress;
  }
}
