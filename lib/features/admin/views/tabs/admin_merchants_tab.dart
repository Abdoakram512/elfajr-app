import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../view_models/admin_cubit.dart';
import '../../view_models/admin_state.dart';

class AdminMerchantsTab extends StatelessWidget {
  const AdminMerchantsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,###');

    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        final cubit = context.read<AdminCubit>();

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: const Text('منافذ الصرف المعتمدة'),
            automaticallyImplyLeading: false,
          ),
          body: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: state.merchants.length,
            separatorBuilder: (context, index) => const Gap(14),
            itemBuilder: (context, index) {
              final merchant = state.merchants[index];

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
                            size: 24,
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
                              Text(
                                '${merchant.storeType} • ${merchant.city}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: merchant.isActive
                                ? AppColors.success.withValues(alpha: 0.12)
                                : AppColors.error.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            merchant.isActive ? 'نشط ومعتمد' : 'موقوف مؤقتاً',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: merchant.isActive
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
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
                              'السجل التجاري',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMutedLight,
                              ),
                            ),
                            const Gap(2),
                            Text(
                              merchant.commercialReg,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'العمليات المنفذة',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMutedLight,
                              ),
                            ),
                            const Gap(2),
                            Text(
                              '${merchant.totalTransactions} عملية',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'إجمالي المصروف',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMutedLight,
                              ),
                            ),
                            const Gap(2),
                            Text(
                              '${currencyFormatter.format(merchant.totalDisbursed)} ${'common.currency'.tr()}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Gap(14),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: OutlinedButton.icon(
                        onPressed: () => cubit.toggleMerchantStatus(merchant.id),
                        icon: Icon(
                          merchant.isActive
                              ? Icons.pause_circle_outline_rounded
                              : Icons.check_circle_outline_rounded,
                          size: 18,
                          color: merchant.isActive
                              ? AppColors.error
                              : AppColors.success,
                        ),
                        label: Text(
                          merchant.isActive
                              ? 'إيقاف الصرف مؤقتاً'
                              : 'تفعيل وتنشيط المنفذ',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: merchant.isActive
                                ? AppColors.error
                                : AppColors.success,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: merchant.isActive
                                ? AppColors.error.withValues(alpha: 0.5)
                                : AppColors.success.withValues(alpha: 0.5),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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
