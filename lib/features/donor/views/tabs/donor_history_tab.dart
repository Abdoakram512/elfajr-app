import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../view_models/donor_cubit.dart';
import '../../view_models/donor_state.dart';

class DonorHistoryTab extends StatelessWidget {
  const DonorHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,###');
    final dateFormatter = DateFormat('yyyy/MM/dd');

    return BlocBuilder<DonorCubit, DonorState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: Text('dashboard.tabs.my_donations'.tr()),
            automaticallyImplyLeading: false,
          ),
          body: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            itemCount: state.donationHistory.length,
            separatorBuilder: (context, index) => const Gap(12),
            itemBuilder: (context, index) {
              final item = state.donationHistory[index];

              return Container(
                padding: const EdgeInsets.all(18),
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primarySubtle,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.volunteer_activism_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const Gap(14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.campaignTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            '${dateFormatter.format(item.date)} • ${item.transactionId}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '+${currencyFormatter.format(item.amount)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
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
        );
      },
    );
  }
}
