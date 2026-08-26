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

  Widget _buildThumbnail(String imageUrl, CashVoucherPalette p) {
    Widget imageWidget;
    if (imageUrl.startsWith('data:image')) {
      try {
        final commaIdx = imageUrl.indexOf(',');
        final base64Str = commaIdx != -1 ? imageUrl.substring(commaIdx + 1) : imageUrl;
        final Uint8List bytes = base64Decode(base64Str);
        imageWidget = Image.memory(bytes, width: 54, height: 54, fit: BoxFit.cover);
      } catch (_) {
        imageWidget = _placeholder();
      }
    } else {
      imageWidget = Image.network(
        imageUrl,
        width: 54,
        height: 54,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => _placeholder(),
      );
    }

    return GestureDetector(
      onTap: () => ReceiptImageViewerDialog.show(context, widget.receipt),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: p.accent.withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: p.accent.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              imageWidget,
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.4),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
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
        width: 54,
        height: 54,
        color: Colors.white.withValues(alpha: 0.1),
        child: const Icon(Icons.receipt_rounded, color: Colors.white70, size: 24),
      );

  @override
  Widget build(BuildContext context) {
    final r = widget.receipt;
    final p = widget.palette;
    final currencyFormatter = intl.NumberFormat('#,##0', 'ar');

    return Container(
      height: 350,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: p.shadowColor.withValues(alpha: widget.isTopCard ? 0.50 : 0.22),
            blurRadius: widget.isTopCard ? 20 : 9,
            offset: Offset(0, widget.isTopCard ? 8 : 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [p.gradientStart, p.gradientEnd],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            border: Border.all(
              color: p.accent.withValues(alpha: 0.45),
              width: 1.6,
            ),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Stack(
            children: [
              // 1. Bank Security Guilloche Wave Texture
              Positioned.fill(
                child: CustomPaint(
                  painter: _GuillocheSecurityPatternPainter(
                    strokeColor: p.lightAccent.withValues(alpha: 0.04),
                  ),
                ),
              ),

              // 2. Large Watermark Bank Emblem
              Positioned(
                left: -20,
                bottom: -20,
                child: Icon(
                  Icons.account_balance_rounded,
                  size: 180,
                  color: Colors.white.withValues(alpha: 0.035),
                ),
              ),

              // 3. Diagonal Frosted Glass Upper Layer
              Positioned.fill(
                child: ClipPath(
                  clipper: _DiagonalGlassClipper(),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.13),
                          Colors.white.withValues(alpha: 0.04),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withValues(alpha: 0.20),
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 4. Holographic Shimmer Beam across the glass
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
                            p.lightAccent.withValues(alpha: 0.12),
                            Colors.white.withValues(alpha: 0.18),
                            Colors.transparent,
                          ],
                          transform: const GradientRotation(0.42),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 5. Card Content Grid
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Bar: Charity Logo Pill + Glowing Status Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.25),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: p.accent.withValues(alpha: 0.5),
                                  width: 1.2,
                                ),
                              ),
                              child: Icon(
                                Icons.verified_rounded,
                                size: 14,
                                color: p.lightAccent,
                              ),
                            ),
                            const Gap(8),
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
                                  'سند تحويل مالي معتمد',
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4.5,
                          ),
                          decoration: BoxDecoration(
                            color: p.badgeBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: p.badgeBorder),
                            boxShadow: [
                              BoxShadow(
                                color: p.accent.withValues(alpha: 0.2),
                                blurRadius: 8,
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

                    // Amount Hero Section
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'المبلغ المستحق للصرف',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.72),
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
                                  fontSize: 33,
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
                                  color: p.badgeBg,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: p.accent.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Text(
                                  'ج.م',
                                  style: TextStyle(
                                    color: p.lightAccent,
                                    fontSize: 13,
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

                    // Frosted Glass Info Sleeve
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                          ),
                        ],
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

                    // High-Contrast Primary Confirmation Action Button
                    SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: widget.isConfirming ? null : widget.onConfirm,
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
// 📐 _DiagonalGlassClipper: Creates Angled Frosted Glass Overlay
// ─────────────────────────────────────────────────────────────────────────────

class _DiagonalGlassClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.62);
    path.lineTo(size.width, size.height * 0.48);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// 📜 _GuillocheSecurityPatternPainter: Bank Security Waves
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
// 🎨 Luxury Color Palettes for Layered Glass Vault
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
    // 1. Imperial Emerald Glass (الزمرد الإمبراطوري)
    CashVoucherPalette(
      gradientStart: Color(0xFF064E3B),
      gradientEnd: Color(0xFF022C22),
      accent: Color(0xFF10B981),
      lightAccent: Color(0xFF6EE7B7),
      badgeBg: Color(0x3310B981),
      badgeBorder: Color(0x6610B981),
      btnBg: Color(0xFF10B981),
      shadowColor: Color(0x66064E3B),
    ),
    // 2. Royal Sapphire Glass (الياقوت الأزرق الملكي)
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
    // 3. Deep Royal Amber Glass (الكهرمان الذهبي)
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
    // 4. Imperial Amethyst Glass (الأرجواني الوقور)
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
    // 5. Midnight Forest Teal Glass (التيل الليلي الملكي)
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
