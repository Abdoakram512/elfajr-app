import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 🚪 VaultDoorPainter: The heavy steel vault door surface
// ─────────────────────────────────────────────────────────────────────────────

class VaultDoorPainter extends CustomPainter {
  final double lockPinRetract; // 0.0 = extended, 1.0 = retracted

  const VaultDoorPainter({this.lockPinRetract = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Door Base — Heavy brushed steel gradient
    final basePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF1A3A2E),
          Color(0xFF0D2A1F),
          Color(0xFF071A12),
          Color(0xFF0A2218),
        ],
        stops: [0.0, 0.35, 0.7, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    canvas.drawRect(rect, basePaint);

    // 2. Subtle brushed-metal horizontal lines (texture)
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..strokeWidth = 0.5;
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // 3. Inner door panel (recessed rectangle)
    const inset = 14.0;
    final innerRect = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );
    final innerRRect =
        RRect.fromRectAndRadius(innerRect, const Radius.circular(12));

    // Shadow for inset effect
    canvas.drawRRect(
      innerRRect.shift(const Offset(0, 2)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Inset panel fill
    canvas.drawRRect(
      innerRRect,
      Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF0F2E22).withValues(alpha: 0.6),
            const Color(0xFF081A12).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(innerRect),
    );

    // Inset panel border
    canvas.drawRRect(
      innerRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..shader = const LinearGradient(
          colors: [
            Color(0x5510B981),
            Color(0x22064E3B),
            Color(0x11000000),
            Color(0x3310B981),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(innerRect),
    );

    // 4. Corner Rivets (4 corners of the door)
    _drawRivet(canvas, Offset(inset + 10, inset + 10));
    _drawRivet(canvas, Offset(size.width - inset - 10, inset + 10));
    _drawRivet(canvas, Offset(inset + 10, size.height - inset - 10));
    _drawRivet(
        canvas, Offset(size.width - inset - 10, size.height - inset - 10));

    // 5. Locking Pins — retract as door opens
    final pinExtension = 6.0 * (1.0 - lockPinRetract);
    final pinPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF6EE7B7), Color(0xFF10B981), Color(0xFF064E3B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, 6, 20));

    // Right side pins (extend outward to the right)
    if (pinExtension > 0.5) {
      final pinW = pinExtension;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
              size.width - pinW, size.height * 0.30, pinW, 16),
          const Radius.circular(2),
        ),
        pinPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
              size.width - pinW, size.height * 0.55, pinW, 16),
          const Radius.circular(2),
        ),
        pinPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
              size.width - pinW, size.height * 0.75, pinW, 16),
          const Radius.circular(2),
        ),
        pinPaint,
      );
    }

    // 6. Top-left brand mark area
    final brandRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(inset + 6, inset + 6, 60, 20),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      brandRect,
      Paint()..color = Colors.black.withValues(alpha: 0.3),
    );
  }

  void _drawRivet(Canvas canvas, Offset center) {
    const r = 3.8;

    // Shadow
    canvas.drawCircle(
      center.translate(0, 1),
      r,
      Paint()..color = Colors.black.withValues(alpha: 0.6),
    );

    // Metallic body
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF6EE7B7),
            const Color(0xFF10B981),
            const Color(0xFF064E3B),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );

    // Center recess
    canvas.drawCircle(
      center,
      r * 0.4,
      Paint()..color = Colors.black.withValues(alpha: 0.7),
    );
  }

  @override
  bool shouldRepaint(covariant VaultDoorPainter oldDelegate) {
    return oldDelegate.lockPinRetract != lockPinRetract;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ⚙️ VaultSteeringWheelPainter: The 3D rotary steering wheel
// ─────────────────────────────────────────────────────────────────────────────

class VaultSteeringWheelPainter extends CustomPainter {
  final double angle;
  final double glowIntensity; // 0.0 → 1.0 for pulsing glow

  const VaultSteeringWheelPainter({
    required this.angle,
    this.glowIntensity = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.translate(-center.dx, -center.dy);

    // 1. Outer glow (when pulsing)
    if (glowIntensity > 0) {
      canvas.drawCircle(
        center,
        radius + 4,
        Paint()
          ..color = const Color(0xFFF59E0B)
              .withValues(alpha: 0.25 * glowIntensity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    // 2. Drop shadow
    canvas.drawCircle(
      center.translate(0, 2),
      radius - 1,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // 3. Outer bezel ring
    canvas.drawCircle(
      center,
      radius - 1,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFDE68A),
            const Color(0xFFF59E0B),
            const Color(0xFFD97706),
            const Color(0xFF92400E),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    // 4. Inner recess
    canvas.drawCircle(
      center,
      radius * 0.78,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF1A3A2E),
            const Color(0xFF0A1F16),
          ],
        ).createShader(
            Rect.fromCircle(center: center, radius: radius * 0.78)),
    );

    // 5. Inner ring
    canvas.drawCircle(
      center,
      radius * 0.75,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..shader = SweepGradient(
          colors: const [
            Color(0xFFFDE68A),
            Color(0xFFD97706),
            Color(0xFF78350F),
            Color(0xFFFDE68A),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 0.75)),
    );

    // 6. Three spokes
    final spokePaint = Paint()
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [Color(0xFFFDE68A), Color(0xFFD97706)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    for (int i = 0; i < 3; i++) {
      final spokeAngle = (i * 2 * math.pi / 3);
      final innerPoint = Offset(
        center.dx + radius * 0.2 * math.cos(spokeAngle),
        center.dy + radius * 0.2 * math.sin(spokeAngle),
      );
      final outerPoint = Offset(
        center.dx + (radius * 0.73) * math.cos(spokeAngle),
        center.dy + (radius * 0.73) * math.sin(spokeAngle),
      );
      canvas.drawLine(innerPoint, outerPoint, spokePaint);

      // Handle grip (small circle at outer end)
      canvas.drawCircle(
        outerPoint,
        3.0,
        Paint()
          ..shader = RadialGradient(
            colors: const [
              Color(0xFFFEF3C7),
              Color(0xFFF59E0B),
              Color(0xFF92400E),
            ],
          ).createShader(Rect.fromCircle(center: outerPoint, radius: 3.0)),
      );
    }

    // 7. Center hub — specular highlight
    canvas.drawCircle(
      center,
      radius * 0.18,
      Paint()
        ..shader = RadialGradient(
          colors: const [
            Colors.white,
            Color(0xFFFDE68A),
            Color(0xFFF59E0B),
            Color(0xFF78350F),
          ],
          stops: const [0.0, 0.25, 0.55, 1.0],
        ).createShader(
            Rect.fromCircle(center: center, radius: radius * 0.18)),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant VaultSteeringWheelPainter oldDelegate) {
    return oldDelegate.angle != angle ||
        oldDelegate.glowIntensity != glowIntensity;
  }
}
