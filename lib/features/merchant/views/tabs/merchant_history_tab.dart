import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/feedback/app_empty_state_widget.dart';
import '../../../../core/widgets/feedback/qout_refresh_indicator.dart';
import '../../../../core/widgets/transactions/transaction_list_item.dart';
import '../../view_models/merchant_dashboard_cubit.dart';
import '../../view_models/merchant_dashboard_state.dart';

class MerchantHistoryTab extends StatelessWidget {
  const MerchantHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MerchantDashboardCubit, MerchantDashboardState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: Text('merchant.recent_transactions'.tr()),
            automaticallyImplyLeading: false,
          ),
          body: QoutRefreshIndicator(
            onRefresh: () =>
                context.read<MerchantDashboardCubit>().refreshData(),
            child: state.recentTransactions.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 80,
                    ),
                    children: const [
                      AppEmptyStateWidget(
                        title: 'لا توجد معاملات مسجلة',
                        description:
                            'ستظهر هنا كافة عمليات الصرف والخصم التي تنفذها في متجرك',
                        icon: Icons.receipt_long_outlined,
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    itemCount: state.recentTransactions.length,
                    separatorBuilder: (context, index) => const Gap(12),
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
          ),
        );
      },
    );
  }
}
