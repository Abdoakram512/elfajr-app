import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../view_models/merchant_cubit.dart';
import '../../view_models/merchant_state.dart';
import '../merchant_scanner_view.dart';

class MerchantHomeTab extends StatelessWidget {
  const MerchantHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,###');
    final dateFormatter = DateFormat('HH:mm - yyyy/MM/dd');
    final isArabic = context.locale.languageCode == 'ar';

    return BlocBuilder<MerchantCubit, MerchantState>(
      builder: (context, state) {
        final cubit = context.read<MerchantCubit>();

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primarySubtle,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.storefront_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const Gap(10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'app_name'.tr(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                'merchant.greeting'.tr(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Language Switcher Pill
                      InkWell(
                        onTap: () {
                          final newLocale = isArabic
                              ? AppConstants.englishLocale
                              : AppConstants.arabicLocale;
                          context.setLocale(newLocale);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Text(
                            isArabic ? 'English' : 'العربية',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Gap(22),

                  // Hero CTA: Scan Beneficiary QR Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.qr_code_scanner_rounded,
                            color: AppColors.accentLight,
                            size: 42,
                          ),
                        ),
                        const Gap(14),
                        Text(
                          'merchant.scan_button'.tr(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Gap(6),
                        Text(
                          'merchant.scan_instruction'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        const Gap(18),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: cubit,
                                    child: const MerchantScannerView(),
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              alignment: Alignment.center,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 3,
                              shadowColor:
                                  AppColors.accent.withValues(alpha: 0.4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.camera_alt_outlined,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                const Gap(8),
                                Text(
                                  'merchant.scan_button'.tr(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Gap(24),

                  // Today Stats Summary
                  Row(
                    children: [
                      Expanded(
                        child: Container(
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
                              Text(
                                'merchant.total_amount_dispensed'.tr(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                              const Gap(8),
                              Text(
                                '${currencyFormatter.format(state.todayDispensedAmount)} ${'common.currency'.tr()}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Container(
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
                              Text(
                                'merchant.today_redemptions'.tr(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                              const Gap(8),
                              Text(
                                '${state.todayTransactionsCount}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Gap(28),

                  // Section Title: Recent Redemptions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'merchant.recent_transactions'.tr(),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      TextButton(
                        onPressed: () => cubit.setTab(1),
                        child: Text(
                          'dashboard.tabs.history'.tr(),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Gap(12),

                  // Redemptions List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.recentTransactions.length,
                    separatorBuilder: (context, index) => const Gap(12),
                    itemBuilder: (context, index) {
                      final item = state.recentTransactions[index];

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.borderLight,
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primarySubtle,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.receipt_long_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const Gap(14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.beneficiaryName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimaryLight,
                                    ),
                                  ),
                                  const Gap(4),
                                  Text(
                                    dateFormatter.format(item.timestamp),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMutedLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '-${currencyFormatter.format(item.amountDeducted)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.error,
                                  ),
                                ),
                                Text(
                                  'common.currency'.tr(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
