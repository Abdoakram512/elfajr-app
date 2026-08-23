import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
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

  String _getMethodDisplayName(String method) {
    switch (method.toLowerCase()) {
      case 'instapay':
        return 'merchant.receipts.method_instapay'.tr();
      case 'vodafone_cash':
        return 'merchant.receipts.method_vodafone'.tr();
      case 'bank_transfer':
        return 'merchant.receipts.method_bank'.tr();
      case 'cash':
        return 'merchant.receipts.method_cash'.tr();
      default:
        return method;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##0');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: receipt.isConfirmed
              ? AppColors.borderLight
              : const Color(0xFFFDE68A),
          width: receipt.isConfirmed ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Method Badge + Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: _getMethodColor(receipt.paymentMethod).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getMethodIcon(receipt.paymentMethod),
                      color: _getMethodColor(receipt.paymentMethod),
                      size: 18,
                    ),
                  ),
                  const Gap(10),
                  Text(
                    _getMethodDisplayName(receipt.paymentMethod),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    currencyFormatter.format(receipt.amount),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    'common.currency'.tr(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Gap(10),

          // Row 2: Status Pill & Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: receipt.isConfirmed
                      ? AppColors.success.withValues(alpha: 0.1)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  receipt.isConfirmed
                      ? 'merchant.receipts.status_confirmed'.tr()
                      : 'merchant.receipts.status_pending'.tr(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: receipt.isConfirmed
                        ? AppColors.success
                        : const Color(0xFFD97706),
                  ),
                ),
              ),
              if (receipt.timestamp != null)
                Text(
                  DateFormat('yyyy/MM/dd - hh:mm a').format(receipt.timestamp!),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
            ],
          ),

          const Gap(12),
          const Divider(height: 1),
          const Gap(10),

          // Row 3: Reference Number
          if (receipt.referenceNumber.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.tag_rounded,
                    size: 14,
                    color: AppColors.textSecondaryLight,
                  ),
                  const Gap(6),
                  Text(
                    'merchant.receipts.ref_label'.tr(namedArgs: {'ref': receipt.referenceNumber}),
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ),

          // Row 4: Notes
          if (receipt.notes != null && receipt.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.notes_rounded,
                    size: 14,
                    color: AppColors.textSecondaryLight,
                  ),
                  const Gap(6),
                  Expanded(
                    child: Text(
                      'merchant.receipts.admin_notes_label'.tr(namedArgs: {'notes': receipt.notes!}),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Row 5: Receipt Image Attachment
          if (receipt.receiptImageUrl != null && receipt.receiptImageUrl!.isNotEmpty)
            InkWell(
              onTap: () => ReceiptImageViewerDialog.show(context, receipt),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                margin: const EdgeInsets.only(top: 4, bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        receipt.receiptImageUrl!,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          width: 44,
                          height: 44,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image_rounded, size: 20),
                        ),
                      ),
                    ),
                    const Gap(10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'merchant.receipts.attachment_available'.tr(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                          Text(
                            'merchant.receipts.tap_to_view_fullscreen'.tr(),
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.fullscreen_rounded, color: AppColors.primary, size: 20),
                  ],
                ),
              ),
            ),

          // Confirm Button if pending
          if (!receipt.isConfirmed) ...[
            const Gap(8),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: isConfirming ? null : onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isConfirming
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'merchant.receipts.confirm_button'.tr(),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getMethodColor(String method) {
    switch (method.toLowerCase()) {
      case 'instapay':
        return const Color(0xFF7C3AED);
      case 'vodafone_cash':
        return const Color(0xFFDC2626);
      case 'bank_transfer':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFF0A734D);
    }
  }

  IconData _getMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'instapay':
        return Icons.flash_on_rounded;
      case 'vodafone_cash':
        return Icons.phone_android_rounded;
      case 'bank_transfer':
        return Icons.account_balance_rounded;
      default:
        return Icons.payments_rounded;
    }
  }
}
