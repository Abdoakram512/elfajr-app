import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../app/service_locator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../view_models/admin_merchants_cubit.dart';
import '../../view_models/admin_merchants_state.dart';

class AdminMerchantsTab extends StatelessWidget {
  const AdminMerchantsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminMerchantsCubit>(),
      child: const _AdminMerchantsTabBody(),
    );
  }
}

class _AdminMerchantsTabBody extends StatelessWidget {
  const _AdminMerchantsTabBody();

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,###');

    return BlocBuilder<AdminMerchantsCubit, AdminMerchantsState>(
      builder: (context, state) {
        final cubit = context.read<AdminMerchantsCubit>();
        final merchants = state.filteredMerchants;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: const Text('منافذ الصرف المعتمدة'),
            automaticallyImplyLeading: false,
          ),
          body: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: merchants.length,
            separatorBuilder: (context, index) => const Gap(14),
            itemBuilder: (context, index) {
              final merchant = merchants[index];

              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: merchant.isActive
                        ? AppColors.borderLight
                        : AppColors.error.withValues(alpha: 0.3),
                  ),
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: merchant.isActive
                                ? AppColors.primarySubtle
                                : AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.storefront_rounded,
                            color: merchant.isActive
                                ? AppColors.primary
                                : AppColors.error,
                            size: 22,
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                merchant.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimaryLight,
                                ),
                              ),
                              const Gap(2),
                              Row(
                                children: [
                                  Text(
                                    merchant.storeType,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondaryLight,
                                    ),
                                  ),
                                  const Text(
                                    ' • ',
                                    style: TextStyle(
                                      color: AppColors.textSecondaryLight,
                                    ),
                                  ),
                                  Text(
                                    merchant.city,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: merchant.isActive,
                          activeThumbColor: AppColors.success,
                          onChanged: (_) {
                            cubit.toggleMerchantStatus(merchant.id);
                          },
                        ),
                      ],
                    ),
                    const Gap(16),
                    const Divider(height: 1, color: AppColors.borderLight),
                    const Gap(14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'إجمالي العمليات المنفذة',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                            const Gap(4),
                            Text(
                              currencyFormatter.format(
                                merchant.totalTransactions,
                              ),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'إجمالي المبالغ المصروفة',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                            const Gap(4),
                            Text(
                              '${currencyFormatter.format(merchant.totalDisbursed)} ${'common.currency'.tr()}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Gap(10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.badge_outlined,
                            size: 14,
                            color: AppColors.textSecondaryLight,
                          ),
                          const Gap(6),
                          Text(
                            'سجل تجاري: ${merchant.commercialReg}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
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
