import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../view_models/merchant_cubit.dart';
import '../../view_models/merchant_state.dart';

class MerchantHistoryTab extends StatelessWidget {
  const MerchantHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,###');
    final dateFormatter = DateFormat('HH:mm - yyyy/MM/dd');

    return BlocBuilder<MerchantCubit, MerchantState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: Text('merchant.recent_transactions'.tr()),
            automaticallyImplyLeading: false,
          ),
          body: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            itemCount: state.recentTransactions.length,
            separatorBuilder: (context, index) => const Gap(12),
            itemBuilder: (context, index) {
              final item = state.recentTransactions[index];

              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.borderLight,
                    width: 0.8,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.beneficiaryName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          '-${currencyFormatter.format(item.amountDeducted)} ${'common.currency'.tr()}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    const Gap(6),
                    Text(
                      '${'digital_card.card_number'.tr()}: ${item.cardId}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    if (item.foodBasketsDeducted > 0) ...[
                      const Gap(4),
                      Text(
                        'صرف: ${item.foodBasketsDeducted} سلة تموينية',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                    const Divider(height: 18, color: Colors.black12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dateFormatter.format(item.timestamp),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMutedLight,
                          ),
                        ),
                        Text(
                          item.transactionId,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
