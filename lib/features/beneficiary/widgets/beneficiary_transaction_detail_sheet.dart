import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/card_printer_service.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../core/widgets/common/info_key_value_row.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/sheets/app_sheet_scaffold.dart';
import '../models/aid_card_model.dart';
import '../view_models/beneficiary_state.dart';

class BeneficiaryTransactionDetailSheet extends StatelessWidget {
  final BeneficiaryRedemptionItem transaction;
  final AidCardModel? card;

  const BeneficiaryTransactionDetailSheet({
    super.key,
    required this.transaction,
    this.card,
  });

  static Future<void> show(
    BuildContext context, {
    required BeneficiaryRedemptionItem transaction,
    AidCardModel? card,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BeneficiaryTransactionDetailSheet(
        transaction: transaction,
        card: card,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##0', 'ar');
    final isFoodBasketOnly =
        transaction.amountDeducted <= 0 && transaction.foodBasketsDeducted > 0;

    return AppSheetScaffold(
      title: 'dashboard.beneficiary.txn_detail_title'.tr(),
      subtitle: transaction.transactionId,
      icon: isFoodBasketOnly
          ? Icons.shopping_basket_rounded
          : Icons.receipt_long_rounded,
      iconColor: isFoodBasketOnly ? const Color(0xFF92400E) : AppColors.primary,
      iconBgColor: isFoodBasketOnly
          ? const Color(0xFFFEF3C7)
          : AppColors.primarySubtle,
      heightFactor: 0.82,
      contentPadding: const EdgeInsets.symmetric(horizontal: 22),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: ListView(
          padding: const EdgeInsets.only(top: 14, bottom: 28),
          children: [
            // 1. Amount & Baskets Highlight Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isFoodBasketOnly
                      ? [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7).withValues(alpha: 0.3)]
                      : [const Color(0xFFECFDF5), Colors.white],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isFoodBasketOnly
                      ? const Color(0xFFFDE68A)
                      : AppColors.primary.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isFoodBasketOnly
                          ? const Color(0xFFFEF3C7)
                          : AppColors.primarySubtle,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isFoodBasketOnly
                          ? 'dashboard.beneficiary.baskets_handover_badge'.tr()
                          : 'dashboard.beneficiary.monthly_spent'.tr(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isFoodBasketOnly
                            ? const Color(0xFF92400E)
                            : AppColors.primary,
                      ),
                    ),
                  ),
                  const Gap(10),
                  if (isFoodBasketOnly) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.shopping_basket_rounded,
                          color: Color(0xFF92400E),
                          size: 30,
                        ),
                        const Gap(10),
                        Text(
                          '${transaction.foodBasketsDeducted} ${'digital_card.baskets_unit'.tr()}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '-${currencyFormatter.format(transaction.amountDeducted)}',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0A734D),
                          ),
                        ),
                        const Gap(6),
                        Text(
                          'common.currency'.tr(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A734D),
                          ),
                        ),
                      ],
                    ),
                    if (transaction.foodBasketsDeducted > 0) ...[
                      const Gap(8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Text(
                          '+${transaction.foodBasketsDeducted} ${'digital_card.baskets_unit'.tr()}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),

            const Gap(16),

            // 2. Structured Detail Information Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Outlet / Center Name
                  InfoKeyValueRow(
                    label: 'dashboard.beneficiary.disbursement_party'.tr(),
                    value: transaction.merchantStoreName,
                    isBold: true,
                    showDivider: true,
                  ),

                  // Transaction ID
                  InfoKeyValueRow(
                    label: 'dashboard.beneficiary.txn_number'.tr(),
                    value: transaction.transactionId,
                    isBold: true,
                    showDivider: true,
                  ),

                  // Card ID
                  InfoKeyValueRow(
                    label: 'dashboard.beneficiary.card_number'.tr(),
                    value: card?.cardId ?? '-',
                    showDivider: true,
                  ),

                  // Date & Time
                  InfoKeyValueRow(
                    label: 'dashboard.beneficiary.txn_date'.tr(),
                    value: AppFormatters.fullDate.format(transaction.timestamp),
                    showDivider: !isFoodBasketOnly || transaction.notes?.isNotEmpty == true,
                  ),

                  // Remaining Balance (Only if money was deducted)
                  if (!isFoodBasketOnly) ...[
                    InfoKeyValueRow(
                      label: 'dashboard.beneficiary.remaining_after_txn'.tr(),
                      value:
                          '${currencyFormatter.format(transaction.remainingBalance)} ${'common.currency'.tr()}',
                      isBold: true,
                      valueColor: AppColors.primary,
                      showDivider: transaction.notes?.isNotEmpty == true,
                    ),
                  ],

                  // Notes (Optional)
                  if (transaction.notes != null &&
                      transaction.notes!.isNotEmpty) ...[
                    InfoKeyValueRow(
                      label: 'dashboard.beneficiary.notes'.tr(),
                      value: transaction.notes!,
                    ),
                  ],
                ],
              ),
            ),

            const Gap(22),

            // 3. Print / Card Button
            PrimaryButton(
              text: 'dashboard.beneficiary.print_receipt_btn'.tr(),
              leadingIcon: Icons.print_rounded,
              onPressed: () {
                if (card != null) {
                  CardPrinterService.printAidCard(card: card!);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
