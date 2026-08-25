import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:qout/core/widgets/notifications/notification_bell_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/feedback/alfajr_refresh_indicator.dart';
import '../../../../core/widgets/feedback/alfajr_shimmer.dart';
import '../../view_models/beneficiary_cubit.dart';
import '../../view_models/beneficiary_state.dart';
import '../../widgets/beneficiary_monthly_statement.dart';
import '../../widgets/digital_aid_card_widget.dart';

class BeneficiaryHomeTab extends StatelessWidget {
  final VoidCallback? onSwitchToHistory;

  const BeneficiaryHomeTab({super.key, this.onSwitchToHistory});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BeneficiaryCubit, BeneficiaryState>(
      builder: (context, state) {
        final card = state.activeCard;
        final now = DateTime.now();

        final thisMonthRedemptions = state.redemptions.forMonth(now);
        final thisMonthSpent = thisMonthRedemptions.totalDisbursed;
        final thisMonthBasketsSpent = thisMonthRedemptions.totalBaskets;

        final currentBalance = card?.totalBalance ?? 0.0;
        final initialMonthEstimate = currentBalance + thisMonthSpent;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: Text('app_name'.tr()),
            automaticallyImplyLeading: false,
            actions: const [
              NotificationBellButton(),
              Gap(16),
            ],
          ),
          body: AlfajrRefreshIndicator(
            onRefresh: () => context.read<BeneficiaryCubit>().refreshData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Digital Aid Card Widget
                  if (card != null)
                    DigitalAidCardWidget(card: card)
                  else if (state.isLoading)
                    const AlfajrShimmer.card()
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Center(
                        child: Text(
                          'dashboard.beneficiary.no_active_card'.tr(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                    ),

                  const Gap(20),

                  // 2. Smart Monthly Statement Breakdown
                  if (card != null)
                    BeneficiaryMonthlyStatement(
                      initialMonthEstimate: initialMonthEstimate,
                      thisMonthSpent: thisMonthSpent,
                      availableBalance: currentBalance,
                      foodBasketsQuota: card.foodBasketsQuota,
                      thisMonthBasketsSpent: thisMonthBasketsSpent,
                      now: now,
                      onOpenFullAnalytics: onSwitchToHistory,
                    ),

                  const Gap(20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
