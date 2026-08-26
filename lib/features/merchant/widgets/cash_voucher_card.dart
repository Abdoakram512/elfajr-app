import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/utils/app_formatters.dart';
import '../models/payment_receipt_model.dart';
import 'receipt_image_viewer_dialog.dart';

/// Premium financial voucher card rendered with ClipPath + CustomPaint.
/// Uses diagonal-cut edges and guilloche security patterns.
class CashVoucherCard extends StatelessWidget {
  final PaymentReceiptModel receipt;
  final VoucherPalette palette;
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
  Widget build(BuildContext context) {
    final r = receipt;
    final p = palette;
    final currencyFormatter = intl.NumberFormat('#,##0', 'ar');
    final methodLabel = _methodLabel(r.paymentMethod);

    return Container(
      height: 255,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: p.shadowColor.withValues(alpha: isTopCard ? 0.45 : 0.15),
            blurRadius: isTopCard ? 18 : 6,
            offset: Offset(0, isTopCard ? 8 : 3),
          ),
        ],
      ),
      child: ClipPath(
        clipper: _VoucherShapeClipper(),
        child: CustomPaint(
          painter: _VoucherBackgroundPainter(palette: p),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── 1. Top: Amount + Method Pill ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Amount
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          currencyFormatter.format(r.amount),
                          style: TextStyle(
                            color: p.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Gap(6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: p.accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: p.accentColor.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            'ج.م',
                            style: TextStyle(
                              color: p.accentColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Payment method pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: p.pillBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: p.pillBorder),
                      ),
                      child: Text(
                        methodLabel,
                        style: TextStyle(
                          color: p.textPrimary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Security separator line ──
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: CustomPaint(
                    painter: _SecurityLinePainter(color: p.accentColor),
                    size: const Size(double.infinity, 2),
                  ),
                ),

                // ── 2. Details Row ──
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Thumbnail
                      if (r.receiptImageUrl != null &&
                          r.receiptImageUrl!.isNotEmpty) ...[
                        _VoucherThumbnail(
                          imageUrl: r.receiptImageUrl!,
                          accentColor: p.accentColor,
                          onTap: () =>
                              ReceiptImageViewerDialog.show(context, receipt),
                        ),
                        const Gap(12),
                      ],
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.tag_rounded,
                                  size: 13,
                                  color: p.accentColor,
                                ),
                                const Gap(4),
                                Expanded(
                                  child: Text(
                                    r.referenceNumber,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: p.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(5),
                            Row(
                              children: [
                                Icon(
                                  Icons.account_balance_wallet_rounded,
                                  size: 12,
                                  color: p.textSecondary,
                                ),
                                const Gap(4),
                                Text(
                                  methodLabel,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: p.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(4),
                            Text(
                              AppFormatters.formatDateTime(
                                r.timestamp,
                                context: context,
                              ),
                              style: TextStyle(
                                fontSize: 10.5,
                                color: p.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── 3. Confirm Button ──
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: isConfirming ? null : onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: p.btnColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      alignment: Alignment.center,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isConfirming
                        ? const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_rounded, size: 17),
                                Gap(6),
                                Text(
                                  'تأكيد استلام المبلغ',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _methodLabel(String method) {
    switch (method.toLowerCase()) {
      case 'instapay':
        return 'انستاباي ⚡';
      case 'vodafone_cash':
        return 'فودافون كاش 📱';
      case 'bank_transfer':
        return 'تحويل بنكي 🏦';
      case 'cash':
        return 'نقداً 💵';
      default:
        return 'تحويل مالي 💳';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ✂️ _VoucherShapeClipper: Diagonal-cut voucher edges
// ─────────────────────────────────────────────────────────────────────────────

class _VoucherShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const cut = 22.0; // diagonal cut size
    const r = 14.0; // corner radius

    final path = Path();

    // Start at top-left, after the diagonal cut
    path.moveTo(cut, 0);

    // Top edge → top-right corner (rounded)
    path.lineTo(size.width - r, 0);
    path.quadraticBezierTo(size.width, 0, size.width, r);

    // Right edge → bottom-right corner (rounded)
    path.lineTo(size.width, size.height - r);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - r,
      size.height,
    );

    // Bottom edge → bottom-left with diagonal cut
    path.lineTo(cut, size.height);

    // Bottom-left diagonal cut (mirror of top-left)
    path.lineTo(0, size.height - cut);

    // Left edge going up
    path.lineTo(0, cut);

    // Top-left diagonal cut
    path.lineTo(cut, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// 🎨 _VoucherBackgroundPainter: Rich gradient + guilloche security patterns
// ─────────────────────────────────────────────────────────────────────────────

class _VoucherBackgroundPainter extends CustomPainter {
  final VoucherPalette palette;

  const _VoucherBackgroundPainter({required this.palette});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Rich gradient background
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: [palette.gradStart, palette.gradMid, palette.gradEnd],
          stops: const [0.0, 0.55, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect),
    );

    // 2. Guilloche security wave pattern (subtle)
    final wavePaint = Paint()
      ..color = palette.guillocheColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    for (int row = 0; row < 12; row++) {
      final y = row * (size.height / 11);
      final wavePath = Path();
      wavePath.moveTo(0, y);
      for (double x = 0; x < size.width; x += 20) {
        wavePath.quadraticBezierTo(
          x + 5,
          y + 4 * math.sin(row * 0.8),
          x + 10,
          y,
        );
        wavePath.quadraticBezierTo(
          x + 15,
          y - 4 * math.sin(row * 0.8),
          x + 20,
          y,
        );
      }
      canvas.drawPath(wavePath, wavePaint);
    }

    // 3. Concentric circle watermark (center-right)
    final wmCenter = Offset(size.width * 0.75, size.height * 0.4);
    final wmPaint = Paint()
      ..color = palette.guillocheColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4;
    for (double r = 10; r < 60; r += 5) {
      canvas.drawCircle(wmCenter, r, wmPaint);
    }

    // 4. Beveled metallic border (follows the clipped shape)
    const cut = 22.0;
    const cr = 14.0;
    final borderPath = Path()
      ..moveTo(cut + 1, 1)
      ..lineTo(size.width - cr, 1)
      ..quadraticBezierTo(size.width - 1, 1, size.width - 1, cr)
      ..lineTo(size.width - 1, size.height - cr)
      ..quadraticBezierTo(
        size.width - 1,
        size.height - 1,
        size.width - cr,
        size.height - 1,
      )
      ..lineTo(cut + 1, size.height - 1)
      ..lineTo(1, size.height - cut - 1)
      ..lineTo(1, cut + 1)
      ..lineTo(cut + 1, 1);

    canvas.drawPath(
      borderPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..shader = LinearGradient(
          colors: [
            palette.borderHighlight,
            palette.borderMid,
            palette.borderHighlight.withValues(alpha: 0.3),
            palette.borderMid,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect),
    );

    // 5. Corner accent marks (small diagonal dashes at the cut corners)
    final accentPaint = Paint()
      ..color = palette.accentColor.withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Top-left cut accent
    canvas.drawLine(
      const Offset(cut - 6, 6),
      const Offset(cut + 2, 6),
      accentPaint,
    );
    canvas.drawLine(
      const Offset(6, cut - 6),
      const Offset(6, cut + 2),
      accentPaint,
    );

    // Bottom-left cut accent
    canvas.drawLine(
      Offset(cut - 6, size.height - 6),
      Offset(cut + 2, size.height - 6),
      accentPaint,
    );
    canvas.drawLine(
      Offset(6, size.height - cut - 2),
      Offset(6, size.height - cut + 6),
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _VoucherBackgroundPainter oldDelegate) {
    return oldDelegate.palette != palette;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 〰️ _SecurityLinePainter: Wavy dashed security separator
// ─────────────────────────────────────────────────────────────────────────────

class _SecurityLinePainter extends CustomPainter {
  final Color color;

  const _SecurityLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final path = Path();
    path.moveTo(0, size.height / 2);
    for (double x = 0; x < size.width; x += 8) {
      path.quadraticBezierTo(x + 2, 0, x + 4, size.height / 2);
      path.quadraticBezierTo(x + 6, size.height, x + 8, size.height / 2);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SecurityLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// 📸 _VoucherThumbnail
// ─────────────────────────────────────────────────────────────────────────────

class _VoucherThumbnail extends StatelessWidget {
  final String imageUrl;
  final Color accentColor;
  final VoidCallback onTap;

  const _VoucherThumbnail({
    required this.imageUrl,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
          width: 52,
          height: 52,
          fit: BoxFit.cover,
        );
      } catch (_) {
        imageWidget = _fallback();
      }
    } else {
      imageWidget = Image.network(
        imageUrl,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        errorBuilder: (_, e, s) => _fallback(),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.6),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              imageWidget,
              Container(
                width: 52,
                height: 52,
                color: Colors.black.withValues(alpha: 0.3),
                child: const Icon(
                  Icons.zoom_in_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallback() => Container(
    width: 52,
    height: 52,
    color: Colors.black.withValues(alpha: 0.3),
    child: const Icon(Icons.receipt_rounded, color: Colors.white70, size: 22),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// 🎨 VoucherPalette: Rich color schemes for voucher cards
// ─────────────────────────────────────────────────────────────────────────────

class VoucherPalette {
  final Color gradStart;
  final Color gradMid;
  final Color gradEnd;
  final Color accentColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color pillBg;
  final Color pillBorder;
  final Color btnColor;
  final Color shadowColor;
  final Color guillocheColor;
  final Color borderHighlight;
  final Color borderMid;

  const VoucherPalette({
    required this.gradStart,
    required this.gradMid,
    required this.gradEnd,
    required this.accentColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.pillBg,
    required this.pillBorder,
    required this.btnColor,
    required this.shadowColor,
    required this.guillocheColor,
    required this.borderHighlight,
    required this.borderMid,
  });

  // 1. Imperial Emerald (الزمرد الإمبراطوري)
  static const emerald = VoucherPalette(
    gradStart: Color(0xFF064E3B),
    gradMid: Color(0xFF043A2C),
    gradEnd: Color(0xFF022C22),
    accentColor: Color(0xFF6EE7B7),
    textPrimary: Color(0xFFF0FDF9),
    textSecondary: Color(0xFFA7F3D0),
    textMuted: Color(0xFF6EE7B7),
    pillBg: Color(0x2210B981),
    pillBorder: Color(0x4410B981),
    btnColor: Color(0xFF059669),
    shadowColor: Color(0xFF064E3B),
    guillocheColor: Color(0x1A6EE7B7),
    borderHighlight: Color(0xFF6EE7B7),
    borderMid: Color(0xFF064E3B),
  );

  // 2. Royal Sapphire (الياقوت الملكي)
  static const sapphire = VoucherPalette(
    gradStart: Color(0xFF1E3A8A),
    gradMid: Color(0xFF172554),
    gradEnd: Color(0xFF0F172A),
    accentColor: Color(0xFF93C5FD),
    textPrimary: Color(0xFFEFF6FF),
    textSecondary: Color(0xFFBFDBFE),
    textMuted: Color(0xFF93C5FD),
    pillBg: Color(0x223B82F6),
    pillBorder: Color(0x443B82F6),
    btnColor: Color(0xFF2563EB),
    shadowColor: Color(0xFF1E3A8A),
    guillocheColor: Color(0x1A93C5FD),
    borderHighlight: Color(0xFF93C5FD),
    borderMid: Color(0xFF1E3A8A),
  );

  // 3. Royal Gold (الذهب الملكي)
  static const gold = VoucherPalette(
    gradStart: Color(0xFF78350F),
    gradMid: Color(0xFF5C2A0A),
    gradEnd: Color(0xFF451A03),
    accentColor: Color(0xFFFDE68A),
    textPrimary: Color(0xFFFFFBEB),
    textSecondary: Color(0xFFFEF3C7),
    textMuted: Color(0xFFFDE68A),
    pillBg: Color(0x22F59E0B),
    pillBorder: Color(0x44F59E0B),
    btnColor: Color(0xFFD97706),
    shadowColor: Color(0xFF78350F),
    guillocheColor: Color(0x1AFDE68A),
    borderHighlight: Color(0xFFFDE68A),
    borderMid: Color(0xFF78350F),
  );

  // 4. Imperial Amethyst (الأرجواني الإمبراطوري)
  static const amethyst = VoucherPalette(
    gradStart: Color(0xFF4C1D95),
    gradMid: Color(0xFF3B1578),
    gradEnd: Color(0xFF2E1065),
    accentColor: Color(0xFFDDD6FE),
    textPrimary: Color(0xFFF5F3FF),
    textSecondary: Color(0xFFEDE9FE),
    textMuted: Color(0xFFDDD6FE),
    pillBg: Color(0x228B5CF6),
    pillBorder: Color(0x448B5CF6),
    btnColor: Color(0xFF7C3AED),
    shadowColor: Color(0xFF4C1D95),
    guillocheColor: Color(0x1ADDD6FE),
    borderHighlight: Color(0xFFDDD6FE),
    borderMid: Color(0xFF4C1D95),
  );

  // 5. Cyber Teal (الفولاذ الليلي)
  static const teal = VoucherPalette(
    gradStart: Color(0xFF134E4A),
    gradMid: Color(0xFF0D3D38),
    gradEnd: Color(0xFF042F2E),
    accentColor: Color(0xFF99F6E4),
    textPrimary: Color(0xFFF0FDFA),
    textSecondary: Color(0xFFCCFBF1),
    textMuted: Color(0xFF99F6E4),
    pillBg: Color(0x2214B8A6),
    pillBorder: Color(0x4414B8A6),
    btnColor: Color(0xFF0D9488),
    shadowColor: Color(0xFF134E4A),
    guillocheColor: Color(0x1A99F6E4),
    borderHighlight: Color(0xFF99F6E4),
    borderMid: Color(0xFF134E4A),
  );

  static const List<VoucherPalette> all = [
    emerald,
    sapphire,
    gold,
    amethyst,
    teal,
  ];

  static VoucherPalette forReceipt(PaymentReceiptModel receipt) {
    return all[receipt.id.hashCode.abs() % all.length];
  }
}
