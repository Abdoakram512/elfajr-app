import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/utils/app_formatters.dart';
import '../models/payment_receipt_model.dart';
import 'receipt_image_viewer_dialog.dart';
import 'receipts/receipt_payment_method_chip.dart';
import 'receipts/receipt_reference_number_row.dart';
import 'receipts/receipt_status_badge.dart';

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
              : AppColors.accentLight,
          width: receipt.isConfirmed ? 1.0 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: receipt.isConfirmed
                ? Colors.black.withValues(alpha: 0.02)
                : AppColors.accentDark.withValues(alpha: 0.06),
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
              ReceiptPaymentMethodChip(method: receipt.paymentMethod),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '+${currencyFormatter.format(receipt.amount)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
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

          // ── Row 2: Status Badge & Formatted Date ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ReceiptStatusBadge(isConfirmed: receipt.isConfirmed),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    AppIcons.schedule,
                    size: 15,
                    color: AppColors.textMutedLight,
                  ),
                  const Gap(5),
                  Text(
                    AppFormatters.formatDateTime(
                      receipt.timestamp,
                      context: context,
                    ),
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
          const Divider(height: 1, color: AppColors.slate100),
          const Gap(12),

          // ── Row 3: Reference Number with Copy Action ──
          if (receipt.referenceNumber.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ReceiptReferenceNumberRow(
                referenceNumber: receipt.referenceNumber,
              ),
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
                color: AppColors.slate50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.article_rounded,
                    size: 17,
                    color: AppColors.slate500,
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      'merchant.receipts.admin_notes_label'
                          .tr(namedArgs: {'notes': receipt.notes!}),
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: AppColors.slate600,
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
                  color: AppColors.slate50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.slate200),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        receipt.receiptImageUrl!,
                        width: 58,
                        height: 58,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          width: 58,
                          height: 58,
                          color: AppColors.slate200,
                          child: const Icon(
                            Icons.broken_image_rounded,
                            color: AppColors.textMutedLight,
                          ),
                        ),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'merchant.receipts.image_attached_title'.tr(),
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                          const Gap(2),
                          Text(
                            'merchant.receipts.image_attached_hint'.tr(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.fullscreen_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),

          // ── Row 7: Action Button (Confirm or Confirmed Badge) ──
          const Gap(4),
          if (!receipt.isConfirmed) ...[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: isConfirming ? null : onConfirm,
                icon: isConfirming
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        AppIcons.checkCircleOutline,
                        color: Colors.white,
                        size: 20,
                      ),
                label: Text(
                  isConfirming
                      ? 'merchant.receipts.confirming_btn'.tr()
                      : 'merchant.receipts.confirm_btn'.tr(),
                  style: const TextStyle(
                    fontSize: 14.5,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  AppIcons.checkCircleOutline,
                  size: 16,
                  color: AppColors.emerald600,
                ),
                const Gap(5),
                Text(
                  'تم تأكيد الاستلام: ${AppFormatters.formatDateTime(receipt.confirmedAt!, context: context)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.emerald600,
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
