import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:qout/app/service_locator.dart';
import 'package:qout/core/constants/app_colors.dart';
import 'package:qout/core/widgets/feedback/app_empty_state_widget.dart';
import 'package:qout/core/widgets/feedback/alfajr_refresh_indicator.dart';
import 'package:qout/core/widgets/transactions/transaction_list_item.dart';
import 'package:qout/features/auth/view_models/auth_cubit.dart';
import 'package:qout/features/auth/view_models/auth_state.dart';
import 'package:qout/features/merchant/view_models/merchant_dashboard_cubit.dart';
import 'package:qout/features/merchant/view_models/merchant_dashboard_state.dart';
import 'package:qout/features/merchant/view_models/redemption_cubit.dart';
import 'package:qout/features/merchant/views/merchant_scanner_view.dart';
import 'package:qout/features/merchant/widgets/extra_disbursement_request_sheet.dart';
import 'package:qout/features/merchant/widgets/manual_search_sheet.dart';
import 'package:qout/features/merchant/widgets/merchant_payment_receipts_sheet.dart';

class MerchantHomeTab extends StatelessWidget {
  final VoidCallback onSwitchToHistory;

  const MerchantHomeTab({super.key, required this.onSwitchToHistory});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##0', 'ar');
    final authState = getIt<AuthCubit>().state;
    final merchant = authState is Authenticated ? authState.user : null;

    return BlocBuilder<MerchantDashboardCubit, MerchantDashboardState>(
      builder: (context, state) {
        final allocatedBudget = merchant?.allocatedBudget ?? 0.0;
        final disbursedAmount = state.todayDispensedAmount;
        final remainingLiquidity = (allocatedBudget - disbursedAmount) > 0
            ? (allocatedBudget - disbursedAmount)
            : 0.0;
        final spentPct = allocatedBudget > 0
            ? (disbursedAmount / allocatedBudget).clamp(0.0, 1.0)
            : 0.0;
        final isLowLiquidity =
            allocatedBudget > 0 &&
            ((remainingLiquidity / allocatedBudget) <= 0.15);

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: AlfajrRefreshIndicator(
            onRefresh: () =>
                context.read<MerchantDashboardCubit>().refreshData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
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
                                  merchant?.storeName ??
                                      merchant?.name ??
                                      'منفذ مؤسسة الفجر',
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
                            isLowLiquidity
                                ? const Color(0xFFFEF2F2)
                                : const Color(0xFFECFDF5),
                            Colors.white,
                          ],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isLowLiquidity
                              ? Colors.red.withValues(alpha: 0.3)
                              : AppColors.primary.withValues(alpha: 0.2),
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
                                    color: isLowLiquidity
                                        ? Colors.red
                                        : AppColors.primary,
                                    size: 20,
                                  ),
                                  const Gap(8),
                                  Text(
                                    'dashboard.merchant.wallet_title'.tr(),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: isLowLiquidity
                                          ? Colors.red.shade900
                                          : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                ],
                              ),
                              if (isLowLiquidity)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.red.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    'merchant.critical_liquidity'.tr(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
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
                                      'dashboard.merchant.allocated_budget'
                                          .tr(),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondaryLight,
                                      ),
                                    ),
                                    const Gap(4),
                                    Text(
                                      '${currencyFormatter.format(allocatedBudget)} ${'common.currency'.tr()}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.textPrimaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'dashboard.merchant.remaining_liquidity'
                                          .tr(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isLowLiquidity
                                            ? Colors.red
                                            : AppColors.primary,
                                      ),
                                    ),
                                    const Gap(4),
                                    Text(
                                      '${currencyFormatter.format(remainingLiquidity)} ${'common.currency'.tr()}',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w900,
                                        color: isLowLiquidity
                                            ? Colors.red
                                            : AppColors.primary,
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
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade800,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const Gap(16),

                    // ── Action Buttons: QR Scan, Manual Search, Emergency Extra Request ──
                    // 1. Primary QR Scanner Button (Full width with perfectly centered text & icon)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MerchantScannerView(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          alignment: Alignment.center,
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: AppColors.primary.withValues(alpha: 0.3),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.qr_code_scanner_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                const Gap(10),
                                Text(
                                  'dashboard.merchant.scan_to_redeem'.tr(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const Gap(12),

                    // 2. Manual Search Button (Full width with perfectly centered text & icon)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          final cubit = getIt<RedemptionCubit>();
                          ManualSearchSheet.show(context, cubit);
                        },
                        style: OutlinedButton.styleFrom(
                          alignment: Alignment.center,
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          side: BorderSide(
                            color: AppColors.borderLight,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.search_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const Gap(8),
                                Text(
                                  'dashboard.merchant.manual_search'.tr(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 3. Emergency Extra Disbursement Request Button (Clear Label with perfectly centered text & icon)
                    if (merchant != null) ...[
                      const Gap(12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => ExtraDisbursementRequestSheet(
                                merchant: merchant,
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            alignment: Alignment.center,
                            backgroundColor: const Color(0xFFFFFBEB),
                            padding: EdgeInsets.zero,
                            side: const BorderSide(
                              color: Color(0xFFFDE68A),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.add_alert_rounded,
                                    color: Color(0xFFD97706),
                                    size: 20,
                                  ),
                                  const Gap(8),
                                  Text(
                                    'dashboard.merchant.request_extra_disbursement'
                                        .tr(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFB45309),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const Gap(12),

                      // 4. View Payment Receipts & Transfers Button (With Image Previews)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => MerchantPaymentReceiptsSheet(
                                merchant: merchant,
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            alignment: Alignment.center,
                            backgroundColor: const Color(0xFFF0FDF4),
                            padding: EdgeInsets.zero,
                            side: const BorderSide(
                              color: Color(0xFFBBF7D0),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child:  Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.receipt_long_rounded,
                                    color: Color(0xFF15803D),
                                    size: 20,
                                  ),
                                  const Gap(8),
                                  Text(
                                    'merchant.payment_receipts_action'.tr(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF15803D),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],

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
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                                const Gap(6),
                                Text(
                                  '${currencyFormatter.format(state.todayDispensedAmount)} ${'common.currency'.tr()}',
                                  style: const TextStyle(
                                    fontSize: 18,
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
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                                const Gap(6),
                                Text(
                                  '${state.todayTransactionsCount}',
                                  style: const TextStyle(
                                    fontSize: 18,
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

                    const Gap(24),

                    // Recent Redemptions Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'merchant.recent_redemptions_title'.tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        TextButton(
                          onPressed: onSwitchToHistory,
                          child: Text(
                            'merchant.full_history_btn'.tr(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(10),

                    if (state.recentTransactions.isEmpty)
                      AppEmptyStateWidget(
                        title: 'merchant.empty_today_title'.tr(),
                        description: 'merchant.empty_today_desc'.tr(),
                        icon: Icons.receipt_long_outlined,
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.recentTransactions.length,
                        separatorBuilder: (context, index) => const Gap(10),
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
