import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../models/payment_receipt_model.dart';
import 'receipt_image_viewer_dialog.dart';

/// Compact receipt card displayed inside the vault interior.
/// Clean financial card design — no vault chrome (the vault is the container).
class CashVoucherCard extends StatelessWidget {
  final PaymentReceiptModel receipt;
  final bool isTopCard;
  final bool isConfirming;
  final VoidCallback onConfirm;

  const CashVoucherCard({
    super.key,
    required this.receipt,
    required this.isTopCard,
    required this.isConfirming,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final r = receipt;
    final currencyFormatter = intl.NumberFormat('#,##0', 'ar');
    final methodInfo = _methodInfo(r.paymentMethod);

    return Container(
      height: 265,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderLight.withValues(alpha: 0.8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isTopCard ? 0.12 : 0.05),
            blurRadius: isTopCard ? 16 : 6,
            offset: Offset(0, isTopCard ? 6 : 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 1. Amount Header Strip ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Amount
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      currencyFormatter.format(r.amount),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Gap(6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'ج.م',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                // Payment method pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    methodInfo.$1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── 2. Receipt Details Body ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail
                  if (r.receiptImageUrl != null &&
                      r.receiptImageUrl!.isNotEmpty) ...[
                    _Thumbnail(
                      imageUrl: r.receiptImageUrl!,
                      onTap: () =>
                          ReceiptImageViewerDialog.show(context, receipt),
                    ),
                    const Gap(12),
                  ],

                  // Info column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Reference number
                        Row(
                          children: [
                            Icon(Icons.tag_rounded,
                                size: 14, color: methodInfo.$2),
                            const Gap(4),
                            Expanded(
                              child: Text(
                                r.referenceNumber,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimaryLight,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Gap(6),

                        // Payment method detail
                        Row(
                          children: [
                            Icon(Icons.account_balance_wallet_rounded,
                                size: 13, color: AppColors.textMutedLight),
                            const Gap(4),
                            Text(
                              methodInfo.$1,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                        const Gap(4),

                        // Timestamp
                        Text(
                          AppFormatters.formatDateTime(r.timestamp,
                              context: context),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── 3. Confirm Button ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: SizedBox(
              height: 42,
              child: ElevatedButton(
                onPressed: isConfirming ? null : onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isConfirming
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded, size: 18),
                          Gap(6),
                          Text(
                            'تأكيد استلام المبلغ',
                            style: TextStyle(
                              fontSize: 13.5,
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
    );
  }

  (String, Color) _methodInfo(String method) {
    switch (method.toLowerCase()) {
      case 'instapay':
        return ('انستاباي ⚡', AppColors.instapayPurple);
      case 'vodafone_cash':
        return ('فودافون كاش 📱', AppColors.vodafoneCashRed);
      case 'bank_transfer':
        return ('تحويل بنكي 🏦', AppColors.bankTransferBlue);
      case 'cash':
        return ('نقداً 💵', AppColors.cashGreen);
      default:
        return ('تحويل مالي 💳', AppColors.primary);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Thumbnail extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onTap;

  const _Thumbnail({required this.imageUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (imageUrl.startsWith('data:image')) {
      try {
        final commaIdx = imageUrl.indexOf(',');
        final base64Str =
            commaIdx != -1 ? imageUrl.substring(commaIdx + 1) : imageUrl;
        final Uint8List bytes = base64Decode(base64Str);
        imageWidget =
            Image.memory(bytes, width: 56, height: 56, fit: BoxFit.cover);
      } catch (_) {
        imageWidget = _fallback();
      }
    } else {
      imageWidget = Image.network(
        imageUrl,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, e, s) => _fallback(),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
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
                width: 56,
                height: 56,
                color: Colors.black.withValues(alpha: 0.25),
                child: const Icon(Icons.zoom_in_rounded,
                    color: Colors.white, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallback() => Container(
        width: 56,
        height: 56,
        color: AppColors.slate100,
        child: const Icon(Icons.receipt_rounded,
            color: AppColors.textMutedLight, size: 24),
      );
}
