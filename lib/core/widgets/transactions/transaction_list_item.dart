import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../constants/app_colors.dart';
import '../../services/card_printer_service.dart';
import '../../utils/app_formatters.dart';
import '../../../features/beneficiary/models/aid_card_model.dart';

class TransactionListItem extends StatelessWidget {
  final String cardId;
  final String beneficiaryName;
  final String? merchantStoreName;
  final double amount;
  final int foodBaskets;
  final String? city;
  final DateTime timestamp;
  final bool showPrintButton;
  final bool isMinimalStyle;
  final VoidCallback? onTap;

  const TransactionListItem({
    super.key,
    required this.cardId,
    required this.beneficiaryName,
    this.merchantStoreName,
    required this.amount,
    required this.foodBaskets,
    this.city,
    required this.timestamp,
    this.showPrintButton = true,
    this.isMinimalStyle = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##0', 'ar');

    if (isMinimalStyle) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // 1. Receipt Icon in pale green container (Far right in RTL)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: Color(0xFF0A734D),
                  size: 22,
                ),
              ),
              const Gap(12),

              // 2. Beneficiary Info + Date (Middle)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      beneficiaryName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(4),
                    Text(
                      AppFormatters.formatDateTime(timestamp, context: context),
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(12),

              // 3. Negative Red Amount (Far left in RTL)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '-${currencyFormatter.format(amount)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                  const Gap(2),
                  Text(
                    'common.currency'.tr(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
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
            // Top Row: Beneficiary Info + Amount
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primarySubtle,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.15),
                          ),
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const Gap(10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              beneficiaryName,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimaryLight,
                                height: 1.25,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Gap(4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                                border:
                                    Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.credit_card_rounded,
                                    size: 11,
                                    color: AppColors.primary,
                                  ),
                                  const Gap(4),
                                  Text(
                                    cardId,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '-${currencyFormatter.format(amount)} ${'common.currency'.tr()}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0A734D),
                      ),
                    ),
                    if (foodBaskets > 0) ...[
                      const Gap(2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Text(
                          '+$foodBaskets ${'digital_card.food_baskets'.tr()}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),

            const Gap(10),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const Gap(8),

            // Bottom Row: Date/Time + Outlet/City + Print Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 13,
                      color: AppColors.textMutedLight,
                    ),
                    const Gap(4),
                    Text(
                      AppFormatters.formatDateTime(
                        timestamp,
                        context: context,
                      ),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    if (city != null && city!.isNotEmpty) ...[
                      Text(
                        ' • $city',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMutedLight,
                        ),
                      ),
                    ],
                  ],
                ),
                if (showPrintButton) ...[
                  InkWell(
                    onTap: () {
                      CardPrinterService.printAidCard(
                        card: AidCardModel(
                          cardId: cardId,
                          beneficiaryId: '',
                          beneficiaryName: beneficiaryName,
                          nationalId: '1089283746',
                          familyCount: 5,
                          totalBalance: amount,
                          foodBasketsQuota: foodBaskets,
                          status: AidCardStatus.active,
                          expiresAt:
                              DateTime.now().add(const Duration(days: 180)),
                          securityHash: '',
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primarySubtle,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.print_rounded,
                            size: 13,
                            color: AppColors.primary,
                          ),
                          const Gap(4),
                          Text(
                            'common.print'.tr(),
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
