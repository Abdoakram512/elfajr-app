import 'dart:convert';
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
  late AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  Widget _buildThumbnail(String imageUrl) {
    Widget imageWidget;
    if (imageUrl.startsWith('data:image')) {
      try {
        final commaIdx = imageUrl.indexOf(',');
        final base64Str = commaIdx != -1
            ? imageUrl.substring(commaIdx + 1)
            : imageUrl;
        final Uint8List bytes = base64Decode(base64Str);
        imageWidget = Image.memory(
          bytes,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        );
      } catch (_) {
        imageWidget = _placeholder();
      }
    } else {
      imageWidget = Image.network(
        imageUrl,
        width: 50,
        height: 50,
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
            color: Colors.white.withValues(alpha: 0.35),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
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
                width: 50,
                height: 50,
                color: Colors.black.withValues(alpha: 0.28),
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
    width: 50,
    height: 50,
    color: Colors.white.withValues(alpha: 0.1),
    child: const Icon(Icons.receipt_rounded, color: Colors.white70, size: 24),
  );

  Widget _buildEmvChip() {
    return Container(
      width: 38,
      height: 28,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFDE68A), Color(0xFFD97706), Color(0xFFF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFFEF3C7), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      child: CustomPaint(painter: _EmvChipLinesPainter()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.receipt;
    final p = widget.palette;
    final currencyFormatter = intl.NumberFormat('#,##0', 'ar');

    return Container(
      height: 350,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: p.shadowColor.withValues(
              alpha: widget.isTopCard ? 0.45 : 0.20,
            ),
            blurRadius: widget.isTopCard ? 18 : 8,
            offset: Offset(0, widget.isTopCard ? 8 : 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [p.gradientStart, p.gradientEnd],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            border: Border.all(
              color: p.accent.withValues(alpha: 0.40),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Stack(
            children: [
              // 1. Subtle Bank Guilloche Curves Background
              Positioned.fill(
                child: CustomPaint(
                  painter: _GuillocheSecurityPatternPainter(
                    strokeColor: p.lightAccent.withValues(alpha: 0.035),
                  ),
                ),
              ),

              // 2. Large Watermark Bank Crest
              Positioned(
                left: -20,
                bottom: -20,
                child: Icon(
                  Icons.account_balance_rounded,
                  size: 175,
                  color: Colors.white.withValues(alpha: 0.035),
                ),
              ),

              // 3. Diagonal Holographic Metallic Sheen
              AnimatedBuilder(
                animation: _shimmer,
                builder: (context, child) => Positioned.fill(
                  child: FractionallySizedBox(
                    widthFactor: 0.35,
                    alignment: Alignment(_shimmer.value * 4 - 2, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.0),
                            p.lightAccent.withValues(alpha: 0.09),
                            Colors.white.withValues(alpha: 0.16),
                            Colors.transparent,
                          ],
                          transform: const GradientRotation(0.42),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 4. Main Financial Card Content
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Bar: Foundation Crest + EMV Chip + Payment Method
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            _buildEmvChip(),
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
                                Text(
                                  'سند إيداع مصرفي إلكتروني',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.65),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
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
                            color: p.badgeBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: p.badgeBorder),
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
                    const Gap(12),

                    // Amount Hero Section
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'المبلغ المستحق للصرف',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.70),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Gap(1),
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
                              Text(
                                'ج.م',
                                style: TextStyle(
                                  color: p.lightAccent,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Gap(10),

                    // Frosted Glass Info Module
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                        ),
                      ),
                      child: Row(
                        children: [
                          if (r.receiptImageUrl != null &&
                              r.receiptImageUrl!.isNotEmpty) ...[
                            _buildThumbnail(r.receiptImageUrl!),
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
                                        color: Colors.white.withValues(
                                          alpha: 0.82,
                                        ),
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

                    // Primary Confirmation Action Button
                    SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: widget.isConfirming
                            ? null
                            : widget.onConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: p.btnBg,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: p.btnBg.withValues(alpha: 0.55),
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
                                  Icon(Icons.check_circle_rounded, size: 20),
                                  Gap(8),
                                  Text(
                                    'تأكيد استلام الحوالة الآن',
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
// 💳 _EmvChipLinesPainter: Metallic Smart Chip Circuit Micro-Patterns
// ─────────────────────────────────────────────────────────────────────────────

class _EmvChipLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF78350F).withValues(alpha: 0.55)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    // Horizontal divider
    canvas.drawLine(Offset(0, h * 0.5), Offset(w, h * 0.5), linePaint);
    // Vertical left & right lines
    canvas.drawLine(Offset(w * 0.35, 0), Offset(w * 0.35, h), linePaint);
    canvas.drawLine(Offset(w * 0.65, 0), Offset(w * 0.65, h), linePaint);

    // Inner rounded center contact
    final centerRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.5),
        width: w * 0.3,
        height: h * 0.45,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(centerRect, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// 📜 _GuillocheSecurityPatternPainter: Banknote Wave Curves
// ─────────────────────────────────────────────────────────────────────────────

class _GuillocheSecurityPatternPainter extends CustomPainter {
  final Color strokeColor;

  const _GuillocheSecurityPatternPainter({required this.strokeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path();
    for (double y = 20; y < size.height; y += 28) {
      path.moveTo(0, y);
      path.cubicTo(
        size.width * 0.25,
        y - 12,
        size.width * 0.75,
        y + 12,
        size.width,
        y,
      );
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _GuillocheSecurityPatternPainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 🎨 Luxury Color Palettes
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
    // Emerald
    CashVoucherPalette(
      gradientStart: Color(0xFF064E3B),
      gradientEnd: Color(0xFF043326),
      accent: Color(0xFF10B981),
      lightAccent: Color(0xFF6EE7B7),
      badgeBg: Color(0x3310B981),
      badgeBorder: Color(0x6610B981),
      btnBg: Color(0xFF10B981),
      shadowColor: Color(0x66064E3B),
    ),
    // Sapphire
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
    // Amber
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
    // Indigo
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
    // Teal
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
