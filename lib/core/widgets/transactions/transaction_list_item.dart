import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../constants/app_colors.dart';
import '../../services/card_printer_service.dart';
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
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,###');
    final dateFormatter = DateFormat('yyyy/MM/dd - HH:mm');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primarySubtle,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const Gap(10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          merchantStoreName ?? beneficiaryName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        if (merchantStoreName != null)
                          Text(
                            'المستفيد: $beneficiaryName',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '-${currencyFormatter.format(amount)} ${'common.currency'.tr()}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                    if (foodBaskets > 0)
                      Text(
                        '+$foodBaskets ${'digital_card.food_baskets'.tr()}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentDark,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const Gap(10),
            const Divider(height: 1, color: AppColors.borderLight),
            const Gap(8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '${'digital_card.card_number'.tr()}: $cardId${city != null ? ' • $city' : ''}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMutedLight,
                      ),
                    ),
                    if (showPrintButton) ...[
                      const Gap(6),
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
                              expiresAt: DateTime.now().add(const Duration(days: 180)),
                              securityHash: '',
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding: EdgeInsets.all(2.0),
                          child: Icon(
                            Icons.print_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  dateFormatter.format(timestamp),
                  style: const TextStyle(
                    fontSize: 11,
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
}
