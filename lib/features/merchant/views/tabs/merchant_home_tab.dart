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
        final effectiveBudget = state.allocatedBudget > 0
            ? state.allocatedBudget
            : (merchant?.allocatedBudget ?? 0.0);
        final disbursedAmount = state.todayDispensedAmount;
        final remainingLiquidity = (effectiveBudget - disbursedAmount) > 0
            ? (effectiveBudget - disbursedAmount)
            : 0.0;
        final burnPercentage = effectiveBudget > 0
            ? (disbursedAmount / effectiveBudget).clamp(0.0, 1.0)
            : 0.0;
        final isLowLiquidity =
            effectiveBudget > 0 && ((remainingLiquidity / effectiveBudget) <= 0.15);

        final monthYearStr = DateFormat('MMMM yyyy', context.locale.languageCode)
            .format(DateTime.now());

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
                    const Gap(18),

                    // ── Primary QR Scanner Card ─────────────────────────────
                    const MerchantScannerCard(),
                    const Gap(18),

                    // ── Official Financial Custody Card ─────────────────────
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Header: Title & Cycle Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0A734D).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.account_balance_wallet_rounded,
                                      color: Color(0xFF0A734D),
                                      size: 20,
                                    ),
                                  ),
                                  const Gap(10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'dashboard.merchant.wallet_title'.tr(),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.textPrimaryLight,
                                        ),
                                      ),
                                      Text(
                                        'dashboard.merchant.wallet_cycle_note'.tr(),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textSecondaryLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Text(
                                  monthYearStr,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Gap(16),

                          // Highlight Box: Remaining Liquidity
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF86EFAC), width: 1.2),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'dashboard.merchant.remaining_liquidity'.tr(),
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF166534),
                                      ),
                                    ),
                                    const Gap(4),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          currencyFormatter.format(remainingLiquidity),
                                          style: const TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF0A734D),
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        const Gap(6),
                                        Text(
                                          'common.currency'.tr(),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF15803D),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.04),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.check_circle_outline_rounded,
                                        size: 14,
                                        color: Color(0xFF0A734D),
                                      ),
                                      const Gap(4),
                                      Text(
                                        'dashboard.merchant.remaining_ready_hint'.tr(),
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0A734D),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Gap(14),

                          // Custody Breakdown (Allocated vs Disbursed)
                          Row(
                            children: [
                              // Allocated Budget Card
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'dashboard.merchant.allocated_budget'.tr(),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                      const Gap(6),
                                      Text(
                                        '${currencyFormatter.format(effectiveBudget)} ${'common.currency'.tr()}',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Gap(10),

                              // Disbursed Amount Card
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'dashboard.merchant.disbursed_amount'.tr(),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                      const Gap(6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${currencyFormatter.format(disbursedAmount)} ${'common.currency'.tr()}',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFFD97706),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFEF3C7),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '${state.todayTransactionsCount}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF92400E),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Gap(14),

                          // Custody Burn Rate Progress Bar
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'dashboard.merchant.custody_burn_rate'.tr(),
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  Text(
                                    '${(burnPercentage * 100).toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: burnPercentage > 0.85
                                          ? const Color(0xFFDC2626)
                                          : const Color(0xFF0A734D),
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: burnPercentage,
                                  minHeight: 7,
                                  backgroundColor: const Color(0xFFE2E8F0),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    burnPercentage > 0.85
                                        ? const Color(0xFFDC2626)
                                        : (burnPercentage > 0.6
                                            ? const Color(0xFFD97706)
                                            : const Color(0xFF0A734D)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Gap(16),

                    // ── Critical Liquidity Alert Banner (if needed) ─────────
                    if (isLowLiquidity) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Color(0xFFDC2626),
                              size: 22,
                            ),
                            const Gap(10),
                            Expanded(
                              child: Text(
                                'dashboard.merchant.low_liquidity_alert'.tr(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF991B1B),
                                  height: 1.3,
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
