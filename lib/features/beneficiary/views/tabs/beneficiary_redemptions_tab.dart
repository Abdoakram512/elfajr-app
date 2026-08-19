import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/feedback/qout_refresh_indicator.dart';
import '../../view_models/beneficiary_cubit.dart';
import '../../view_models/beneficiary_state.dart';

class BeneficiaryRedemptionsTab extends StatelessWidget {
  const BeneficiaryRedemptionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,###');
    final dateFormatter = DateFormat('yyyy/MM/dd - HH:mm');

    return BlocBuilder<BeneficiaryCubit, BeneficiaryState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: const Text('سجل حركات الصرف'),
            automaticallyImplyLeading: false,
          ),
          body: QoutRefreshIndicator(
            onRefresh: () => context.read<BeneficiaryCubit>().refreshData(),
            child: state.redemptions.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: AppColors.textMutedLight,
                            ),
                            const Gap(16),
                            Text(
                              'لا توجد عمليات صرف مسجلة حتى الآن',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                            const Gap(6),
                            Text(
                              'عند زيارتك لأي منفذ صرف معتمد ستظهر فواتيرك هنا.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textMutedLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    itemCount: state.redemptions.length,
                    separatorBuilder: (context, index) => const Gap(12),
                  itemBuilder: (context, index) {
                    final item = state.redemptions[index];
                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderLight),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primarySubtle,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.storefront_rounded,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const Gap(10),
                                  Text(
                                    item.merchantStoreName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimaryLight,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '-${currencyFormatter.format(item.amountDeducted)} ${'common.currency'.tr()}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                          const Gap(14),
                          const Divider(height: 1, color: AppColors.borderLight),
                          const Gap(12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'رقم العملية: ${item.transactionId}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                              Text(
                                dateFormatter.format(item.timestamp),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                          if (item.notes != null && item.notes!.isNotEmpty) ...[
                            const Gap(8),
                            Text(
                              'البيان: ${item.notes}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textPrimaryLight.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
          ),
        );
      },
    );
  }
}
