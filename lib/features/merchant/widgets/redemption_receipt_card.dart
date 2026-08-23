import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/card_printer_service.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../beneficiary/models/aid_card_model.dart';
import '../models/redemption_transaction_model.dart';

class RedemptionReceiptCard extends StatelessWidget {
  final RedemptionTransactionModel transaction;
  final AidCardModel? card;
  final VoidCallback? onNewRedemption;
  final VoidCallback? onDone;

  const RedemptionReceiptCard({
    super.key,
    required this.transaction,
    this.card,
    this.onNewRedemption,
    this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,###');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.success.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const Gap(12),
              Text(
                'merchant.redemption_receipt.success_title'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const Gap(4),
              Text(
                'merchant.redemption_receipt.txn_number'.tr(namedArgs: {'txn': transaction.transactionId}),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(16),
              const Divider(height: 1, color: Colors.black12),
              const Gap(16),

              _buildRow('merchant.redemption_receipt.beneficiary_label'.tr(), transaction.beneficiaryName),
              const Gap(8),
              _buildRow('merchant.redemption_receipt.outlet_label'.tr(), transaction.merchantStoreName),
              const Gap(8),
              _buildRow(
                'merchant.redemption_receipt.deducted_amount'.tr(),
                '${currencyFormatter.format(transaction.amountDeducted)} ${'common.currency'.tr()}',
                isBold: true,
                color: AppColors.error,
              ),
              if (transaction.foodBasketsDeducted > 0) ...[
                const Gap(8),
                _buildRow(
                  'merchant.redemption_receipt.deducted_baskets'.tr(),
                  '${transaction.foodBasketsDeducted} ${'common.baskets_unit'.tr()}',
                  isBold: true,
                ),
              ],
              const Gap(8),
              _buildRow(
                'merchant.redemption_receipt.remaining_balance'.tr(),
                '${currencyFormatter.format(transaction.remainingBalance)} ${'common.currency'.tr()}',
                isBold: true,
                color: AppColors.primary,
              ),
              const Gap(8),
              _buildRow(
                'merchant.redemption_receipt.remaining_baskets'.tr(),
                '${transaction.remainingBaskets} ${'common.baskets_unit'.tr()}',
              ),
            ],
          ),
        ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),

        const Gap(20),

        // Action 1: Print Receipt / Card
        PrimaryButton(
          text: 'merchant.redemption_receipt.print_receipt_btn'.tr(),
          leadingIcon: Icons.print_rounded,
          onPressed: () {
            if (card != null) {
              CardPrinterService.printAidCard(card: card!);
            }
          },
        ),

        if (onNewRedemption != null) ...[
          const Gap(10),
          OutlinedButton.icon(
            onPressed: onNewRedemption,
            icon: const Icon(Icons.add_circle_outline_rounded, size: 18, color: AppColors.primary),
            label: Text(
              'merchant.redemption_receipt.new_redemption_btn'.tr(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.primary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],

        if (onDone != null) ...[
          const Gap(8),
          Center(
            child: TextButton(
              onPressed: onDone,
              child: Text(
                'merchant.redemption_receipt.done_and_return'.tr(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            color: AppColors.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 14 : 12.5,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}
