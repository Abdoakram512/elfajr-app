import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/utils/app_formatters.dart';
import '../models/payment_receipt_model.dart';
import 'receipt_image_viewer_dialog.dart';

class CashVoucherCard extends StatefulWidget {
  final PaymentReceiptModel receipt;
  final CashVoucherPalette palette;
  final bool isTopCard;
  final bool isConfirming;
  final VoidCallback onConfirm;

  const CashVoucherCard({
    super.key,
    required this.receipt,
    required this.palette,
    required this.isTopCard,
    required this.isConfirming,
    required this.onConfirm,
  });

  @override
  State<CashVoucherCard> createState() => _CashVoucherCardState();
}

class _CashVoucherCardState extends State<CashVoucherCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _vaultAnimController;

  @override
  void initState() {
    super.initState();
    _vaultAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();
  }

  @override
  void dispose() {
    _vaultAnimController.dispose();
    super.dispose();
  }

  Widget _buildThumbnail(String imageUrl, CashVoucherPalette p) {
    Widget imageWidget;
    if (imageUrl.startsWith('data:image')) {
      try {
        final commaIdx = imageUrl.indexOf(',');
        final base64Str = commaIdx != -1 ? imageUrl.substring(commaIdx + 1) : imageUrl;
        final Uint8List bytes = base64Decode(base64Str);
        imageWidget = Image.memory(bytes, width: 52, height: 52, fit: BoxFit.cover);
      } catch (_) {
        imageWidget = _placeholder();
      }
    } else {
      imageWidget = Image.network(
        imageUrl,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => _placeholder(),
      );
    }

    return GestureDetector(
      onTap: () => ReceiptImageViewerDialog.show(context, widget.receipt),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: p.accent.withValues(alpha: 0.8),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            alignment: Alignment.center,
            children: [
              imageWidget,
              Container(
                width: 52,
                height: 52,
                color: Colors.black.withValues(alpha: 0.35),
                child: const Icon(
                  Icons.zoom_in_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 52,
        height: 52,
        color: Colors.black.withValues(alpha: 0.3),
        child: const Icon(Icons.receipt_rounded, color: Colors.white70, size: 24),
      );

  @override
  Widget build(BuildContext context) {
    final r = widget.receipt;
    final p = widget.palette;
    final currencyFormatter = intl.NumberFormat('#,##0', 'ar');

    return AnimatedBuilder(
      animation: _vaultAnimController,
      builder: (context, child) {
        final shimmerValue = _vaultAnimController.value;
        final wheelRotationAngle = widget.isConfirming
            ? _vaultAnimController.value * 2 * math.pi
            : math.sin(_vaultAnimController.value * 2 * math.pi) * 0.15;

        return Container(
          height: 350,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: p.shadowColor.withValues(alpha: widget.isTopCard ? 0.60 : 0.25),
                blurRadius: widget.isTopCard ? 22 : 10,
                offset: Offset(0, widget.isTopCard ? 10 : 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: CustomPaint(
              painter: _PhotorealisticVaultChassisPainter(
                palette: p,
                isTopCard: widget.isTopCard,
              ),
              child: Stack(
                children: [
                  // 1. Heavy Inset Vault Door Body with Steel Bolts
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _VaultDoorPanelPainter(
                        palette: p,
                      ),
                    ),
                  ),

                  // 2. Holographic Specular Light Sweep on Steel Frame
                  Positioned.fill(
                    child: FractionallySizedBox(
                      widthFactor: 0.35,
                      alignment: Alignment(shimmerValue * 4 - 2, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.0),
                              p.lightAccent.withValues(alpha: 0.08),
                              Colors.white.withValues(alpha: 0.14),
                              Colors.transparent,
                            ],
                            transform: const GradientRotation(0.42),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 3. Vault UI Elements & Digital Display
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Top Header Bar: Vault Brand + 3D Rotating Steering Wheel + Method Pill
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                // 3D Rotary Vault Wheel
                                SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: CustomPaint(
                                    painter: _VaultSteeringWheelPainter(
                                      angle: wheelRotationAngle,
                                      accentColor: p.accent,
                                      lightAccent: p.lightAccent,
                                    ),
                                  ),
                                ),
                                const Gap(10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'مؤسسة الفجر الخيرية',
                                      style: TextStyle(
                                        color: p.lightAccent,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: p.accent,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: p.accent,
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Gap(4),
                                        Text(
                                          'خزنة الإيداع المصرفية المصفحة',
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.65),
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4.5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: p.accent.withValues(alpha: 0.5),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: p.accent.withValues(alpha: 0.2),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Text(
                                _formatMethod(r.paymentMethod),
                                style: TextStyle(
                                  color: p.lightAccent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Gap(10),

                        // OLED Vault Digital Screen for Amount
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF030712), Color(0xFF0F172A)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: p.accent.withValues(alpha: 0.55),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.6),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                              BoxShadow(
                                color: p.accent.withValues(alpha: 0.15),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                'المبلغ المستحق للإيداع في الخزنة',
                                style: TextStyle(
                                  color: p.lightAccent.withValues(alpha: 0.8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Gap(2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    currencyFormatter.format(r.amount),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const Gap(6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: p.accent.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: p.accent.withValues(alpha: 0.6),
                                      ),
                                    ),
                                    child: Text(
                                      'ج.م',
                                      style: TextStyle(
                                        color: p.lightAccent,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Gap(10),

                        // Vault Receipt Inspection Slot
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Row(
                            children: [
                              if (r.receiptImageUrl != null &&
                                  r.receiptImageUrl!.isNotEmpty) ...[
                                _buildThumbnail(r.receiptImageUrl!, p),
                                const Gap(12),
                              ],
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.tag_rounded,
                                          size: 13,
                                          color: p.lightAccent,
                                        ),
                                        const Gap(4),
                                        Expanded(
                                          child: Text(
                                            'رقم المرجع: ${r.referenceNumber}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Gap(3),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.account_balance_wallet_rounded,
                                          size: 13,
                                          color: p.lightAccent,
                                        ),
                                        const Gap(4),
                                        Text(
                                          'الوسيلة: ${_formatMethod(r.paymentMethod)}',
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.85),
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Gap(3),
                                    Text(
                                      'تاريخ الإرسال: ${AppFormatters.formatDateTime(r.timestamp, context: context)}',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.55),
                                        fontSize: 10.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // Electronic Vault Unlock Action Button
                        SizedBox(
                          height: 46,
                          child: ElevatedButton(
                            onPressed: widget.isConfirming ? null : widget.onConfirm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: p.btnBg,
                              foregroundColor: Colors.white,
                              elevation: 5,
                              shadowColor: p.btnBg.withValues(alpha: 0.65),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: widget.isConfirming
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.lock_open_rounded, size: 20),
                                      Gap(8),
                                      Text(
                                        'تأكيد استلام وإيداع في الخزنة',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatMethod(String method) {
    switch (method.toLowerCase()) {
      case 'instapay':
        return 'انستاباي ⚡';
      case 'vodafone_cash':
        return 'فودافون كاش 📱';
      case 'bank_transfer':
        return 'تحويل بنكي 🏦';
      case 'cash':
        return 'نقداً باليد 💵';
      default:
        return 'تحويل مالي 💳';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 🛡️ _PhotorealisticVaultChassisPainter: Outer Steel Frame with Corner Bolts
// ─────────────────────────────────────────────────────────────────────────────

class _PhotorealisticVaultChassisPainter extends CustomPainter {
  final CashVoucherPalette palette;
  final bool isTopCard;

  const _PhotorealisticVaultChassisPainter({
    required this.palette,
    required this.isTopCard,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(24));

    // 1. Chassis Outer Base Gradient (Heavy Brushed Steel & Titanium)
    final chassisPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          palette.gradientStart,
          palette.gradientEnd,
          const Color(0xFF030712),
        ],
        stops: const [0.0, 0.65, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);

    canvas.drawRRect(rrect, chassisPaint);

    // 2. Metallic Beveled Rim Border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..shader = LinearGradient(
        colors: [
          palette.lightAccent.withValues(alpha: 0.8),
          palette.accent.withValues(alpha: 0.4),
          Colors.black.withValues(alpha: 0.7),
          palette.accent.withValues(alpha: 0.6),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);

    canvas.drawRRect(rrect, borderPaint);

    // 3. Four 3D Metallic Corner Rivets / Bolts
    _drawRivet(canvas, const Offset(14, 14), palette);
    _drawRivet(canvas, Offset(size.width - 14, 14), palette);
    _drawRivet(canvas, Offset(14, size.height - 14), palette);
    _drawRivet(canvas, Offset(size.width - 14, size.height - 14), palette);
  }

  void _drawRivet(Canvas canvas, Offset center, CashVoucherPalette p) {
    const radius = 4.2;

    // Drop Shadow
    canvas.drawCircle(
      center.translate(0, 1),
      radius,
      Paint()..color = Colors.black.withValues(alpha: 0.6),
    );

    // Metallic Rim
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            p.lightAccent,
            p.accent,
            const Color(0xFF1E293B),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    // Center Recess
    canvas.drawCircle(
      center,
      radius * 0.45,
      Paint()..color = Colors.black.withValues(alpha: 0.8),
    );
  }

  @override
  bool shouldRepaint(covariant _PhotorealisticVaultChassisPainter oldDelegate) {
    return oldDelegate.palette != palette || oldDelegate.isTopCard != isTopCard;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 🚪 _VaultDoorPanelPainter: Inset Heavy Vault Door with Steel Locking Pins
// ─────────────────────────────────────────────────────────────────────────────

class _VaultDoorPanelPainter extends CustomPainter {
  final CashVoucherPalette palette;

  const _VaultDoorPanelPainter({required this.palette});

  @override
  void paint(Canvas canvas, Size size) {
    const margin = 8.0;
    final doorRect = Rect.fromLTWH(
      margin,
      margin,
      size.width - margin * 2,
      size.height - margin * 2,
    );
    final doorRRect = RRect.fromRectAndRadius(doorRect, const Radius.circular(18));

    // 1. Inset Door Shadow (Deep 3D Cutout)
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(doorRRect, shadowPaint);

    // 2. Steel Locking Pins on the side borders
    final pinPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          palette.lightAccent,
          palette.accent,
          const Color(0xFF0F172A),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(doorRect);

    // Left locking pins
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(margin - 4, size.height * 0.35, 4, 18),
        const Radius.circular(2),
      ),
      pinPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(margin - 4, size.height * 0.65, 4, 18),
        const Radius.circular(2),
      ),
      pinPaint,
    );

    // Right locking pins
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - margin, size.height * 0.35, 4, 18),
        const Radius.circular(2),
      ),
      pinPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - margin, size.height * 0.65, 4, 18),
        const Radius.circular(2),
      ),
      pinPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _VaultDoorPanelPainter oldDelegate) {
    return oldDelegate.palette != palette;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ⚙️ _VaultSteeringWheelPainter: 3D Rotary Vault Steering Wheel
// ─────────────────────────────────────────────────────────────────────────────

class _VaultSteeringWheelPainter extends CustomPainter {
  final double angle;
  final Color accentColor;
  final Color lightAccent;

  const _VaultSteeringWheelPainter({
    required this.angle,
    required this.accentColor,
    required this.lightAccent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.translate(-center.dx, -center.dy);

    // Drop Shadow
    canvas.drawCircle(
      center.translate(0, 2),
      radius - 2,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Outer Ring
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..shader = SweepGradient(
        colors: [
          lightAccent,
          accentColor,
          const Color(0xFF0F172A),
          lightAccent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius - 3, ringPaint);

    // 3 Spokes (Tri-spoke handles)
    final spokePaint = Paint()
      ..strokeWidth = 2.4
      ..shader = LinearGradient(
        colors: [lightAccent, accentColor],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    for (int i = 0; i < 3; i++) {
      final spokeAngle = (i * 2 * math.pi / 3);
      final spokeEnd = Offset(
        center.dx + (radius - 2) * math.cos(spokeAngle),
        center.dy + (radius - 2) * math.sin(spokeAngle),
      );
      canvas.drawLine(center, spokeEnd, spokePaint);

      // Spoke Handle Grips
      canvas.drawCircle(
        spokeEnd,
        2.2,
        Paint()..color = lightAccent,
      );
    }

    // Center Hub with 3D Specular Highlight
    canvas.drawCircle(
      center,
      radius * 0.35,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white,
            lightAccent,
            accentColor,
            const Color(0xFF0F172A),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 0.35)),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _VaultSteeringWheelPainter oldDelegate) {
    return oldDelegate.angle != angle ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.lightAccent != lightAccent;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 🎨 Luxury Vault Metallic Palettes
// ─────────────────────────────────────────────────────────────────────────────

class CashVoucherPalette {
  final Color gradientStart;
  final Color gradientEnd;
  final Color accent;
  final Color lightAccent;
  final Color badgeBg;
  final Color badgeBorder;
  final Color btnBg;
  final Color shadowColor;

  const CashVoucherPalette({
    required this.gradientStart,
    required this.gradientEnd,
    required this.accent,
    required this.lightAccent,
    required this.badgeBg,
    required this.badgeBorder,
    required this.btnBg,
    required this.shadowColor,
  });

  static const List<CashVoucherPalette> all = [
    // 1. Imperial Emerald Titanium Vault (خزنة الزمرد الفولاذية)
    CashVoucherPalette(
      gradientStart: Color(0xFF064E3B),
      gradientEnd: Color(0xFF022C22),
      accent: Color(0xFF10B981),
      lightAccent: Color(0xFF6EE7B7),
      badgeBg: Color(0x3310B981),
      badgeBorder: Color(0x6610B981),
      btnBg: Color(0xFF059669),
      shadowColor: Color(0x66064E3B),
    ),
    // 2. Royal Sapphire Cobalt Vault (خزنة الياقوت المصفحة)
    CashVoucherPalette(
      gradientStart: Color(0xFF1E3A8A),
      gradientEnd: Color(0xFF0F172A),
      accent: Color(0xFF3B82F6),
      lightAccent: Color(0xFF93C5FD),
      badgeBg: Color(0x333B82F6),
      badgeBorder: Color(0x663B82F6),
      btnBg: Color(0xFF2563EB),
      shadowColor: Color(0x661E3A8A),
    ),
    // 3. Royal Brass & Gold Vault (خزنة الذهب الإمبراطوري)
    CashVoucherPalette(
      gradientStart: Color(0xFF78350F),
      gradientEnd: Color(0xFF451A03),
      accent: Color(0xFFF59E0B),
      lightAccent: Color(0xFFFDE68A),
      badgeBg: Color(0x33F59E0B),
      badgeBorder: Color(0x66F59E0B),
      btnBg: Color(0xFFD97706),
      shadowColor: Color(0x6678350F),
    ),
    // 4. Imperial Amethyst Night Vault (خزنة التيتانيوم الأرجواني)
    CashVoucherPalette(
      gradientStart: Color(0xFF4C1D95),
      gradientEnd: Color(0xFF2E1065),
      accent: Color(0xFF8B5CF6),
      lightAccent: Color(0xFFDDD6FE),
      badgeBg: Color(0x338B5CF6),
      badgeBorder: Color(0x668B5CF6),
      btnBg: Color(0xFF7C3AED),
      shadowColor: Color(0x664C1D95),
    ),
    // 5. Cyber Teal Steel Vault (خزنة الفولاذ الليلي)
    CashVoucherPalette(
      gradientStart: Color(0xFF134E4A),
      gradientEnd: Color(0xFF042F2E),
      accent: Color(0xFF14B8A6),
      lightAccent: Color(0xFF99F6E4),
      badgeBg: Color(0x3314B8A6),
      badgeBorder: Color(0x6614B8A6),
      btnBg: Color(0xFF0D9488),
      shadowColor: Color(0x66134E4A),
    ),
  ];

  static CashVoucherPalette forReceipt(PaymentReceiptModel receipt) {
    return all[receipt.id.hashCode.abs() % all.length];
  }
}
