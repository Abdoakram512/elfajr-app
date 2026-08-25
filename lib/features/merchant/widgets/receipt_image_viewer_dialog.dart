import 'dart:convert';
import 'dart:typed_data';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';

class ReceiptImageViewerDialog extends StatelessWidget {
  final String imageUrl;
  final String title;
  final double amount;
  final String referenceNumber;

  const ReceiptImageViewerDialog({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.amount,
    required this.referenceNumber,
  });

  static Future<void> show(BuildContext context, dynamic receipt) {
    return showDialog(
      context: context,
      builder: (ctx) => ReceiptImageViewerDialog(
        imageUrl: receipt.receiptImageUrl ?? '',
        title: receipt.merchantStoreName ?? receipt.merchantName,
        amount: receipt.amount,
        referenceNumber: receipt.referenceNumber,
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl.startsWith('data:image')) {
      try {
        final commaIdx = imageUrl.indexOf(',');
        final base64Str =
            commaIdx != -1 ? imageUrl.substring(commaIdx + 1) : imageUrl;
        final Uint8List bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildFallback(),
        );
      } catch (e) {
        return _buildFallback();
      }
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      },
      errorBuilder: (context, error, stackTrace) => _buildFallback(),
    );
  }

  Widget _buildFallback() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFC8E6C9),
                  width: 2,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: 42,
                  color: Color(0xFF0A734D),
                ),
              ),
            ),
            const Gap(14),
            Text(
              'merchant.receipts.sheet_title'.tr(),
              style: const TextStyle(
                color: AppColors.textPrimaryLight,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Gap(4),
            Text(
              'merchant.receipts.sheet_subtitle'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondaryLight,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##0', 'ar');

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 650, maxWidth: 500),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.borderLight, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── 1. Branded Header (Imperial Emerald & Gold) ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          color: AppColors.accentLight,
                          size: 20,
                        ),
                      ),
                      const Gap(10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (referenceNumber.isNotEmpty)
                            Text(
                              'merchant.receipt_viewer.ref_label'
                                  .tr(namedArgs: {'ref': referenceNumber}),
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'monospace',
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),
            ),

            // ── 2. Zoomable Image Container ──
            Expanded(
              child: Container(
                color: AppColors.slate50,
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _buildImage(),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const Divider(color: AppColors.borderLight, height: 1),

            // ── 3. Bottom Info Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'merchant.receipt_viewer.amount_label'.tr(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      Text(
                        '${currencyFormatter.format(amount)} ${'common.currency'.tr()}',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.check_rounded,
                        size: 18, color: Colors.white),
                    label: Text(
                      'merchant.receipt_viewer.close'.tr(),
                      style: const TextStyle(
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
