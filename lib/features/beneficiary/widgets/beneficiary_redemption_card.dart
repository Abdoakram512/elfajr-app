import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../models/aid_card_model.dart';
import '../view_models/beneficiary_state.dart';
import 'beneficiary_transaction_detail_sheet.dart';

class BeneficiaryRedemptionCard extends StatelessWidget {
  final BeneficiaryRedemptionItem transaction;
  final AidCardModel? card;

  const BeneficiaryRedemptionCard({
    super.key,
    required this.transaction,
    this.card,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##0', 'ar');
    final isFoodBasketOnly =
        transaction.amountDeducted <= 0 && transaction.foodBasketsDeducted > 0;

    return InkWell(
      onTap: () => BeneficiaryTransactionDetailSheet.show(
        context,
        transaction: transaction,
        card: card,
      ),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Store Icon + Full Store Name + Date + Deduction Amount/Baskets
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isFoodBasketOnly
                        ? const Color(0xFFFEF3C7)
                        : AppColors.primarySubtle,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isFoodBasketOnly
                        ? Icons.shopping_basket_rounded
                        : Icons.storefront_rounded,
                    color: isFoodBasketOnly
                        ? const Color(0xFF92400E)
                        : AppColors.primary,
                    size: 22,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Store / Center Name (Full text, no ellipsis cutting it off)
                      Text(
                        transaction.merchantStoreName,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
                          height: 1.3,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        AppFormatters.fullDate.format(transaction.timestamp),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (isFoodBasketOnly) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Text(
                          '${transaction.foodBasketsDeducted} ${'digital_card.baskets_unit'.tr()}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ] else ...[
                      Text(
                        '-${currencyFormatter.format(transaction.amountDeducted)} ${'common.currency'.tr()}',
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                      if (transaction.foodBasketsDeducted > 0) ...[
                        const Gap(3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Text(
                            '+${transaction.foodBasketsDeducted} ${'digital_card.baskets_unit'.tr()}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF92400E),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ],
            ),
            const Gap(12),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const Gap(10),

            // Bottom Row: Status / Remaining + View Receipt Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        isFoodBasketOnly
                            ? Icons.check_circle_outline_rounded
                            : Icons.account_balance_wallet_outlined,
                        size: 14,
                        color: isFoodBasketOnly
                            ? const Color(0xFF059669)
                            : AppColors.primary,
                      ),
                      const Gap(6),
                      Expanded(
                        child: Text(
                          isFoodBasketOnly
                              ? 'dashboard.beneficiary.baskets_handover_badge'
                                    .tr()
                              : '${'dashboard.beneficiary.remaining_after_txn'.tr()}: ${currencyFormatter.format(transaction.remainingBalance)} ${'common.currency'.tr()}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isFoodBasketOnly
                                ? const Color(0xFF059669)
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.receipt_long_rounded,
                        size: 13,
                        color: AppColors.textSecondaryLight,
                      ),
                      const Gap(5),
                      Text(
                        'dashboard.beneficiary.view_receipt_btn'.tr(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
