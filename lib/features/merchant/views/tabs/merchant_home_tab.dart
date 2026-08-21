import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:qout/core/theme/app_colors.dart';
import 'package:qout/core/widgets/app_empty_state_widget.dart';
import 'package:qout/core/widgets/qout_refresh_indicator.dart';
import 'package:qout/core/widgets/transaction_list_item.dart';
import 'package:qout/features/merchant/view_models/merchant_dashboard_cubit.dart';
import 'package:qout/features/merchant/view_models/merchant_dashboard_state.dart';
import 'package:qout/features/merchant/widgets/extra_disbursement_request_sheet.dart';
import 'package:qout/features/merchant/widgets/manual_search_sheet.dart';

class MerchantHomeTab extends StatelessWidget {
  final VoidCallback onOpenScanner;
  final VoidCallback onSwitchToHistory;

  const MerchantHomeTab({
    super.key,
    required this.onOpenScanner,
    required this.onSwitchToHistory,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##0', 'ar');

    return BlocBuilder<MerchantDashboardCubit, MerchantDashboardState>(
      builder: (context, state) {
        final merchant = state.merchant;
        final allocatedBudget = merchant?.allocatedBudget ?? 0.0;
        final disbursedAmount = merchant?.totalDisbursed ?? 0.0;
        final remainingLiquidity = (allocatedBudget - disbursedAmount) > 0 ? (allocatedBudget - disbursedAmount) : 0.0;
        final spentPct = allocatedBudget > 0 ? (disbursedAmount / allocatedBudget).clamp(0.0, 1.0) : 0.0;
        final isLowLiquidity = allocatedBudget > 0 && ((remainingLiquidity / allocatedBudget) <= 0.15);

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: QoutRefreshIndicator(
            onRefresh: () => context.read<MerchantDashboardCubit>().refreshDashboard(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primarySubtle,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.storefront_rounded,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ),
                            const Gap(12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  merchant?.storeName ?? merchant?.name ?? 'منفذ مؤسسة الفجر',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimaryLight,
                                  ),
                                ),
                                Text(
                                  'app_name'.tr(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Gap(20),

                    // ── Merchant Liquidity & Budget Card (CORE NEW FEATURE) ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            isLowLiquidity ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5),
                            Colors.white,
                          ],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isLowLiquidity ? Colors.red.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
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
                                  Icon(
                                    Icons.account_balance_wallet_rounded,
                                    color: isLowLiquidity ? Colors.red : AppColors.primary,
                                    size: 20,
                                  ),
                                  const Gap(8),
                                  Text(
                                    'dashboard.merchant.wallet_title'.tr(),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: isLowLiquidity ? Colors.red.shade900 : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                ],
                              ),
                              if (isLowLiquidity)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.red.shade300),
                                  ),
                                  child: const Text(
                                    '⚠️ سيولة حرجة',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red),
                                  ),
                                ),
                            ],
                          ),
                          const Gap(14),

                          // Amounts row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'dashboard.merchant.allocated_budget'.tr(),
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                                    ),
                                    const Gap(4),
                                    Text(
                                      '${currencyFormatter.format(allocatedBudget)} ${'common.currency'.tr()}',
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimaryLight),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'dashboard.merchant.remaining_liquidity'.tr(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isLowLiquidity ? Colors.red : AppColors.primary,
                                      ),
                                    ),
                                    const Gap(4),
                                    Text(
                                      '${currencyFormatter.format(remainingLiquidity)} ${'common.currency'.tr()}',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w900,
                                        color: isLowLiquidity ? Colors.red : AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Gap(12),

                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: spentPct,
                              minHeight: 8,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isLowLiquidity ? Colors.red : AppColors.primary,
                              ),
                            ),
                          ),

                          if (isLowLiquidity) ...[
                            const Gap(10),
                            Text(
                              'dashboard.merchant.low_liquidity_alert'.tr(),
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red.shade800),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const Gap(16),

                    // ── Action Buttons: QR Scan & Emergency Extra Disbursement ──
                    Row(
                      children: [
                        // QR Scanner Button
                        Expanded(
                          flex: 3,
                          child: ElevatedButton.icon(
                            onPressed: onOpenScanner,
                            icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
                            label: Text(
                              'dashboard.merchant.scan_to_redeem'.tr(),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                        const Gap(10),

                        // Emergency Extra Request Button
                        if (merchant != null)
                          ElevatedButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => ExtraDisbursementRequestSheet(merchant: merchant),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber.shade50,
                              foregroundColor: Colors.amber.shade900,
                              elevation: 0,
                              side: BorderSide(color: Colors.amber.shade300),
                              padding: const EdgeInsets.all(14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Icon(Icons.emergency_rounded, color: Colors.amber, size: 24),
                          ),
                      ],
                    ),

                    const Gap(12),

                    // Manual Search Button
                    OutlinedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const ManualSearchSheet(),
                        );
                      },
                      icon: const Icon(Icons.search_rounded, size: 20),
                      label: Text('dashboard.merchant.manual_search'.tr()),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        foregroundColor: AppColors.textPrimaryLight,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),

                    const Gap(24),

                    // Today Summary
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'dashboard.merchant.today_dispensed'.tr(),
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                                ),
                                const Gap(6),
                                Text(
                                  '${currencyFormatter.format(state.todayDispensedAmount)} ${'common.currency'.tr()}',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'dashboard.merchant.today_txns'.tr(),
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                                ),
                                const Gap(6),
                                Text(
                                  '${state.todayTransactionsCount}',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.accent),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Gap(24),

                    // Recent Redemptions Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'آخر عمليات الصرف',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
                        ),
                        TextButton(
                          onPressed: onSwitchToHistory,
                          child: const Text(
                            'عرض السجل الكامل',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                    const Gap(10),

                    if (state.recentTransactions.isEmpty)
                      const AppEmptyStateWidget(
                        title: 'لا توجد عمليات صرف مسجلة اليوم',
                        description: 'ستظهر هنا كافة عمليات الخصم وسحب الإعانات فور تنفيذها',
                        icon: Icons.receipt_long_outlined,
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.recentTransactions.length,
                        separatorBuilder: (_, __) => const Gap(10),
                        itemBuilder: (context, index) {
                          final item = state.recentTransactions[index];
                          return TransactionListItem(
                            cardId: item.cardId,
                            beneficiaryName: item.beneficiaryName,
                            amount: item.amountDeducted,
                            foodBaskets: item.foodBasketsDeducted,
                            timestamp: item.timestamp,
                            showPrintButton: true,
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
