import 'dart:convert';
import 'dart:typed_data';

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

  Widget _buildReceiptThumbnail(String imageUrl) {
    if (imageUrl.startsWith('data:image')) {
      try {
        final commaIdx = imageUrl.indexOf(',');
        final base64Str =
            commaIdx != -1 ? imageUrl.substring(commaIdx + 1) : imageUrl;
        final Uint8List bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          width: 58,
          height: 58,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => _buildPlaceholder(),
        );
      } catch (_) {
        return _buildPlaceholder();
      }
    }

    return Image.network(
      imageUrl,
      width: 58,
      height: 58,
      fit: BoxFit.cover,
      loadingBuilder: (ctx, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.slate100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
        );
      },
      errorBuilder: (ctx, err, stack) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFC8E6C9),
          width: 1.2,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.receipt_long_rounded,
          color: Color(0xFF0A734D),
          size: 28,
        ),
      ),
    );
  }

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
          width: receipt.isConfirmed ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: receipt.isConfirmed
                ? Colors.black.withValues(alpha: 0.02)
                : const Color(0xFFF59E0B).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: Amount & Status Badge ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '+${currencyFormatter.format(receipt.amount)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: receipt.isConfirmed
                          ? AppColors.primary
                          : const Color(0xFFD97706),
                    ),
                  ),
                  const Gap(4),
                  Text(
                    'common.currency'.tr(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              ReceiptStatusBadge(isConfirmed: receipt.isConfirmed),
            ],
          ),

          const Gap(12),
          const Divider(height: 1, color: AppColors.slate100),
          const Gap(12),

          // ── Row 2: Reference Number & Copy Button ──
          if (receipt.referenceNumber.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ReceiptReferenceNumberRow(
                referenceNumber: receipt.referenceNumber,
              ),
            ),

          // ── Row 3: Payment Method Chip ──
          ReceiptPaymentMethodChip(method: receipt.paymentMethod),

          // ── Row 4: Account Details (Sender / Receiver) ──
          if (receipt.senderAccountOrPhone != null ||
              receipt.receiverAccountOrPhone != null) ...[
            const Gap(10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.slate50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Column(
                children: [
                  if (receipt.senderAccountOrPhone != null &&
                      receipt.senderAccountOrPhone!.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          Icons.account_balance_outlined,
                          size: 13,
                          color: AppColors.slate400,
                        ),
                        const Gap(6),
                        Expanded(
                          child: Text(
                            'الحساب المحول منه: ${receipt.senderAccountOrPhone}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.slate600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (receipt.receiverAccountOrPhone != null &&
                      receipt.receiverAccountOrPhone!.isNotEmpty) ...[
                    if (receipt.senderAccountOrPhone != null) const Gap(4),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_pin_circle_outlined,
                          size: 13,
                          color: AppColors.slate400,
                        ),
                        const Gap(6),
                        Expanded(
                          child: Text(
                            'الحساب المستلم: ${receipt.receiverAccountOrPhone}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.slate600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],

          // ── Row 5: Admin Notes (if any) ──
          if (receipt.notes != null && receipt.notes!.trim().isNotEmpty) ...[
            const Gap(10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: Color(0xFFD97706),
                  ),
                  const Gap(6),
                  Expanded(
                    child: Text(
                      'merchant.receipts.admin_notes_label'
                          .tr(namedArgs: {'notes': receipt.notes!}),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Row 6: Image Attachment Preview Card ──
          if (receipt.receiptImageUrl != null &&
              receipt.receiptImageUrl!.isNotEmpty)
            InkWell(
              onTap: () => ReceiptImageViewerDialog.show(context, receipt),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 4),
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
                      child: _buildReceiptThumbnail(receipt.receiptImageUrl!),
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
              child: ElevatedButton(
                onPressed: isConfirming ? null : onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if (isConfirming)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    else
                      const Icon(
                        AppIcons.checkCircleOutline,
                        color: Colors.white,
                        size: 20,
                      ),
                    const Gap(8),
                    Text(
                      isConfirming
                          ? 'merchant.receipts.confirming_btn'.tr()
                          : 'merchant.receipts.confirm_btn'.tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ],
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
