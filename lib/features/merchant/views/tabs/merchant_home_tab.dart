import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:qout/app/service_locator.dart';
import 'package:qout/core/constants/app_colors.dart';
import 'package:qout/core/widgets/feedback/app_empty_state_widget.dart';
import 'package:qout/core/widgets/feedback/alfajr_refresh_indicator.dart';
import 'package:qout/core/widgets/transactions/transaction_list_item.dart';
import 'package:qout/core/widgets/notifications/notification_bell_button.dart';
import 'package:qout/features/auth/view_models/auth_cubit.dart';
import 'package:qout/features/auth/view_models/auth_state.dart';
import 'package:qout/features/merchant/view_models/merchant_dashboard_cubit.dart';
import 'package:qout/features/merchant/view_models/merchant_dashboard_state.dart';
import 'package:qout/features/merchant/widgets/merchant_action_bar_group.dart';
import 'package:qout/features/merchant/widgets/merchant_scanner_card.dart';

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
                    // ── Header Bar (Store info on Right, Language switch on Left) ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Store Info (Right in RTL)
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.storefront_rounded,
                                color: Color(0xFF0A734D),
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
                                      'app_name'.tr(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimaryLight,
                                  ),
                                ),
                                Text(
                                  'merchant.home_welcome'.tr(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Language & Notification Actions (Left in RTL)
                        Row(
                          children: [
                            const NotificationBellButton(),
                            const Gap(8),
                            OutlinedButton(
                              onPressed: () {
                                final currentLocale = context.locale;
                                if (currentLocale.languageCode == 'ar') {
                                  context.setLocale(const Locale('en'));
                                } else {
                                  context.setLocale(const Locale('ar'));
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textPrimaryLight,
                                side: const BorderSide(
                                  color: AppColors.borderLight,
                                  width: 1.2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                context.locale.languageCode == 'ar'
                                    ? 'English'
                                    : 'العربية',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Gap(20),

                    // ── Primary QR Scanner Card ─────────────────────────────
                    const MerchantScannerCard(),
                    const Gap(18),

                    // ── Summary KPI Cards (Side-by-Side) ────────────────────
                    Row(
                      children: [
                        // Card 1 (Right in RTL): Total Dispensed
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 18,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFF1F5F9),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'dashboard.merchant.today_dispensed'.tr(),
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                                const Gap(10),
                                Text(
                                  '${currencyFormatter.format(state.todayDispensedAmount)} ${'common.currency'.tr()}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0A734D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Gap(14),

                        // Card 2 (Left in RTL): Today's Count
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 18,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFF1F5F9),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'dashboard.merchant.today_txns'.tr(),
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                                const Gap(10),
                                Text(
                                  '${state.todayTransactionsCount}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFD97706),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(18),

                    // ── Critical Liquidity Alert Banner (if needed) ─────────
                    if (isLowLiquidity) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.red,
                              size: 20,
                            ),
                            const Gap(8),
                            Expanded(
                              child: Text(
                                'dashboard.merchant.low_liquidity_alert'.tr(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(14),
                    ],

                    // ── Quick Actions Group (Manual Search / Emergency Request) ─
                    MerchantActionBarGroup(merchant: merchant),
                    const Gap(24),

                    // ── Recent Redemptions Title ────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'merchant.recent_redemptions_title'.tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        InkWell(
                          onTap: onSwitchToHistory,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            child: Text(
                              'merchant.full_history_btn'.tr(),
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0A734D),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(12),

                    // ── Transactions List ───────────────────────────────────
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
                            foodBaskets: 0,
                            timestamp: item.timestamp,
                            showPrintButton: false,
                            isMinimalStyle: true,
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
