import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../core/utils/haptic_feedback_helper.dart';
import '../models/payment_receipt_model.dart';
import 'receipt_image_viewer_dialog.dart';

class PaymentReceiptCardItem extends StatelessWidget {
  final PaymentReceiptModel receipt;
  final bool isConfirming;
  final VoidCallback onConfirm;

  const PaymentReceiptCardItem({
    super.key,
    required this.receipt,
    required this.isConfirming,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##0', 'ar');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: receipt.isConfirmed
              ? AppColors.borderLight
              : const Color(0xFFFDE68A),
          width: receipt.isConfirmed ? 1.0 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: receipt.isConfirmed
                ? Colors.black.withValues(alpha: 0.02)
                : const Color(0xFFD97706).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: Method Badge + Amount ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _PaymentMethodBadge(method: receipt.paymentMethod),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '+${currencyFormatter.format(receipt.amount)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0A734D),
                    ),
                  ),
                  const Gap(4),
                  Text(
                    'common.currency'.tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Gap(14),

          // ── Row 2: Status Pill & Formatted Date ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ReceiptStatusPill(isConfirmed: receipt.isConfirmed),
              if (receipt.timestamp != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 15,
                      color: AppColors.textMutedLight,
                    ),
                    const Gap(5),
                    Text(
                      AppFormatters.fullDate.format(receipt.timestamp!),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          const Gap(14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const Gap(12),

          // ── Row 3: Reference Number with Copy Action ──
          if (receipt.referenceNumber.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ReferenceNumberRow(referenceNumber: receipt.referenceNumber),
            ),

          // ── Row 4: Sender / Receiver Account Info ──
          if (receipt.senderAccountOrPhone != null &&
              receipt.senderAccountOrPhone!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 16,
                    color: AppColors.textMutedLight,
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      'الحساب المحول منه: ${receipt.senderAccountOrPhone}',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Row 5: Admin Notes ──
          if (receipt.notes != null && receipt.notes!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 2, bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.article_rounded,
                    size: 17,
                    color: Color(0xFF64748B),
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      'merchant.receipts.admin_notes_label'
                          .tr(namedArgs: {'notes': receipt.notes!}),
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF475569),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Row 6: Image Attachment Preview Card ──
          if (receipt.receiptImageUrl != null &&
              receipt.receiptImageUrl!.isNotEmpty)
            InkWell(
              onTap: () => ReceiptImageViewerDialog.show(context, receipt),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                margin: const EdgeInsets.only(top: 4, bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        receipt.receiptImageUrl!,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          width: 52,
                          height: 52,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image_rounded,
                              size: 24, color: Colors.grey),
                        ),
                      ),
                    ),
                    const Gap(14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'إشعار التحويل البنكي المرفق',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                          const Gap(3),
                          Text(
                            'merchant.receipts.tap_to_preview'.tr(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.fullscreen_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),

          // ── Row 7: Action / Confirmation Button ──
          if (!receipt.isConfirmed) ...[
            const Gap(8),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: isConfirming ? null : onConfirm,
                icon: isConfirming
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline_rounded,
                        size: 20, color: Colors.white),
                label: Text(
                  'merchant.receipts.confirm_button'.tr(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ] else if (receipt.confirmedAt != null) ...[
            const Gap(6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 16,
                  color: Color(0xFF059669),
                ),
                const Gap(5),
                Text(
                  'تم تأكيد الاستلام: ${AppFormatters.fullDate.format(receipt.confirmedAt!)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF059669),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PaymentMethodBadge extends StatelessWidget {
  final String method;

  const _PaymentMethodBadge({required this.method});

  @override
  Widget build(BuildContext context) {
    final (name, color, bgColor, icon) = _getMethodConfig(method);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const Gap(6),
          Text(
            name,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  (String, Color, Color, IconData) _getMethodConfig(String method) {
    switch (method.toLowerCase()) {
      case 'instapay':
        return (
          'merchant.receipts.method_instapay'.tr(),
          const Color(0xFF7C3AED),
          const Color(0xFFF5F3FF),
          Icons.account_balance_wallet_rounded,
        );
      case 'vodafone_cash':
        return (
          'merchant.receipts.method_vodafone_cash'.tr(),
          const Color(0xFFDC2626),
          const Color(0xFFFEF2F2),
          Icons.phone_android_rounded,
        );
      case 'bank_transfer':
        return (
          'merchant.receipts.method_bank_transfer'.tr(),
          const Color(0xFF2563EB),
          const Color(0xFFEFF6FF),
          Icons.account_balance_rounded,
        );
      default:
        return (
          'merchant.receipts.method_cash'.tr(),
          const Color(0xFF0A734D),
          const Color(0xFFECFDF5),
          Icons.payments_rounded,
        );
    }
  }
}

class _ReceiptStatusPill extends StatelessWidget {
  final bool isConfirmed;

  const _ReceiptStatusPill({required this.isConfirmed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: isConfirmed ? const Color(0xFFECFDF5) : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isConfirmed ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isConfirmed ? Icons.check_circle_outline_rounded : Icons.schedule_rounded,
            size: 15,
            color: isConfirmed ? const Color(0xFF059669) : const Color(0xFFD97706),
          ),
          const Gap(5),
          Text(
            isConfirmed
                ? 'merchant.receipts.status_confirmed'.tr()
                : 'merchant.receipts.status_pending'.tr(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isConfirmed ? const Color(0xFF065F46) : const Color(0xFF92400E),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferenceNumberRow extends StatelessWidget {
  final String referenceNumber;

  const _ReferenceNumberRow({required this.referenceNumber});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              const Icon(
                Icons.tag_rounded,
                size: 17,
                color: AppColors.textSecondaryLight,
              ),
              const Gap(6),
              Expanded(
                child: Text(
                  'merchant.receipts.ref_label'
                      .tr(namedArgs: {'ref': referenceNumber}),
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Gap(8),
        InkWell(
          onTap: () {
            Clipboard.setData(ClipboardData(text: referenceNumber));
            HapticHelper.light();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم نسخ رقم المرجع: $referenceNumber'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.copy_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
                const Gap(5),
                Text(
                  'نسخ',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
