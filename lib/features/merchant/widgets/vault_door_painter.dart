import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 🚪 VaultDoorPainter: Photorealistic heavy steel vault door
// ─────────────────────────────────────────────────────────────────────────────

class VaultDoorPainter extends CustomPainter {
  final double lockPinRetract; // 0.0 = extended, 1.0 = retracted

  const VaultDoorPainter({this.lockPinRetract = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Door Base — Heavy brushed steel gradient
    canvas.drawRect(
      rect,
      Paint()
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
        ).createShader(rect),
    );

    // 2. Studio lighting reflection (SweepGradient)
    canvas.drawRect(
      rect,
      Paint()
        ..shader = SweepGradient(
          center: Alignment(0.2, -0.3),
          colors: [
            Colors.transparent,
            Colors.white.withValues(alpha: 0.04),
            Colors.transparent,
            Colors.white.withValues(alpha: 0.02),
            Colors.transparent,
          ],
          stops: const [0.0, 0.15, 0.4, 0.7, 1.0],
        ).createShader(rect),
    );

    // 3. Brushed-metal horizontal texture
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.02)
      ..strokeWidth = 0.5;
    for (double y = 0; y < size.height; y += 2.5) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // 4. Inner door panel (recessed rectangle with double bevel)
    const inset = 14.0;
    final innerRect = Rect.fromLTWH(
        inset, inset, size.width - inset * 2, size.height - inset * 2);
    final innerRRect =
        RRect.fromRectAndRadius(innerRect, const Radius.circular(12));

    // Outer shadow
    canvas.drawRRect(
      innerRRect.shift(const Offset(0, 2)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Inset fill
    canvas.drawRRect(
      innerRRect,
      Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF0F2E22).withValues(alpha: 0.5),
            const Color(0xFF081A12).withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(innerRect),
    );

    // Inner bevel highlight
    canvas.drawRRect(
      innerRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..shader = const LinearGradient(
          colors: [
            Color(0x4410B981),
            Color(0x11064E3B),
            Color(0x08000000),
            Color(0x2210B981),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(innerRect),
    );

    // Outer bevel (second border)
    final outerBevelRect = Rect.fromLTWH(
        inset - 2, inset - 2, size.width - inset * 2 + 4, size.height - inset * 2 + 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(outerBevelRect, const Radius.circular(14)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = const Color(0x2210B981),
    );

    // 5. Engraved text "خزنة الفجر المصفحة" (subtle)
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'خزنة الفجر المصفحة',
        style: TextStyle(
          color: Color(0x1A6EE7B7),
          fontSize: 14,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
      textDirection: ui.TextDirection.rtl,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        size.height - inset - 28,
      ),
    );

    // 6. Corner rivets (6 rivets)
    _drawRivet(canvas, Offset(inset + 10, inset + 10));
    _drawRivet(canvas, Offset(size.width - inset - 10, inset + 10));
    _drawRivet(canvas, Offset(inset + 10, size.height * 0.5));
    _drawRivet(canvas, Offset(size.width - inset - 10, size.height * 0.5));
    _drawRivet(canvas, Offset(inset + 10, size.height - inset - 10));
    _drawRivet(canvas, Offset(size.width - inset - 10, size.height - inset - 10));

    // 7. Locking pins (retract as door opens)
    final pinExtension = 6.0 * (1.0 - lockPinRetract);
    if (pinExtension > 0.5) {
      final pinPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF6EE7B7), Color(0xFF10B981), Color(0xFF064E3B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, 6, 20));

      // Right side — 3 pins
      for (final yFrac in [0.28, 0.50, 0.72]) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width - pinExtension, size.height * yFrac, pinExtension, 14),
            const Radius.circular(2),
          ),
          pinPaint,
        );
      }
    }

    // 8. Digital serial number plate (top-left)
    final plateBg = RRect.fromRectAndRadius(
      Rect.fromLTWH(inset + 6, inset + 6, 70, 22),
      const Radius.circular(4),
    );
    canvas.drawRRect(plateBg, Paint()..color = Colors.black.withValues(alpha: 0.4));
    canvas.drawRRect(
      plateBg,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6
        ..color = const Color(0x3310B981),
    );

    // Serial number text
    final serialPainter = TextPainter(
      text: const TextSpan(
        text: 'EFJ-VAULT',
        style: TextStyle(
          color: Color(0x8810B981),
          fontSize: 9,
          fontWeight: FontWeight.w700,
          fontFamily: 'monospace',
          letterSpacing: 1.5,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    serialPainter.layout();
    serialPainter.paint(canvas, Offset(inset + 12, inset + 12));
  }

  void _drawRivet(Canvas canvas, Offset center) {
    const r = 3.8;
    canvas.drawCircle(
      center.translate(0, 1),
      r,
      Paint()..color = Colors.black.withValues(alpha: 0.6),
    );
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: const [Color(0xFF6EE7B7), Color(0xFF10B981), Color(0xFF064E3B)],
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );
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
// ⚙️ VaultSteeringWheelPainter: 5-spoke gold rotary wheel
// ─────────────────────────────────────────────────────────────────────────────

class VaultSteeringWheelPainter extends CustomPainter {
  final double angle;
  final double glowIntensity;

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

    // 1. Outer glow
    if (glowIntensity > 0) {
      canvas.drawCircle(
        center,
        radius + 5,
        Paint()
          ..color = const Color(0xFFF59E0B).withValues(alpha: 0.2 * glowIntensity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }

    // 2. Drop shadow
    canvas.drawCircle(
      center.translate(0, 3),
      radius - 1,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // 3. Outer bezel — thick gold ring
    canvas.drawCircle(
      center,
      radius - 1,
      Paint()
        ..shader = RadialGradient(
          colors: const [
            Color(0xFFFDE68A),
            Color(0xFFF59E0B),
            Color(0xFFD97706),
            Color(0xFF92400E),
          ],
          stops: const [0.0, 0.25, 0.6, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    // 4. Inner recess (dark center area)
    canvas.drawCircle(
      center,
      radius * 0.80,
      Paint()
        ..shader = RadialGradient(
          colors: const [Color(0xFF1A3A2E), Color(0xFF0A1F16), Color(0xFF050D09)],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 0.80)),
    );

    // 5. Inner ring (thinner gold)
    canvas.drawCircle(
      center,
      radius * 0.77,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..shader = SweepGradient(
          colors: const [
            Color(0xFFFDE68A),
            Color(0xFFD97706),
            Color(0xFF78350F),
            Color(0xFFFDE68A),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 0.77)),
    );

    // 6. Five spokes
    final spokePaint = Paint()
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [Color(0xFFFDE68A), Color(0xFFD97706)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    for (int i = 0; i < 5; i++) {
      final spokeAngle = (i * 2 * math.pi / 5);
      final innerPoint = Offset(
        center.dx + radius * 0.2 * math.cos(spokeAngle),
        center.dy + radius * 0.2 * math.sin(spokeAngle),
      );
      final outerPoint = Offset(
        center.dx + (radius * 0.75) * math.cos(spokeAngle),
        center.dy + (radius * 0.75) * math.sin(spokeAngle),
      );
      canvas.drawLine(innerPoint, outerPoint, spokePaint);

      // Handle grip
      canvas.drawCircle(
        outerPoint,
        2.8,
        Paint()
          ..shader = RadialGradient(
            colors: const [Color(0xFFFEF3C7), Color(0xFFF59E0B), Color(0xFF92400E)],
          ).createShader(Rect.fromCircle(center: outerPoint, radius: 2.8)),
      );
    }

    // 7. Center hub
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
          stops: const [0.0, 0.2, 0.5, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 0.18)),
    );

    // 8. Center dot
    canvas.drawCircle(
      center,
      radius * 0.06,
      Paint()..color = const Color(0xFF451A03),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant VaultSteeringWheelPainter oldDelegate) {
    return oldDelegate.angle != angle || oldDelegate.glowIntensity != glowIntensity;
  }
}
