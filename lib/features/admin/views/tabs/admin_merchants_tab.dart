import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../app/service_locator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/feedback/alfajr_refresh_indicator.dart';
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
        final isMerchantsSegment = state.selectedSegment == 0;
        final merchants = state.filteredMerchants;
        final beneficiaries = state.filteredBeneficiaries;

        final pendingBeneficiariesCount =
            state.beneficiaries.where((b) => !b.isApproved).length;
        final pendingMerchantsCount =
            state.merchants.where((m) => !m.isActive).length;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: Text('admin_mgmt.title'.tr()),
            automaticallyImplyLeading: false,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    // Merchants Segment Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () => cubit.setSegment(0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isMerchantsSegment
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.storefront_rounded,
                                  size: 16,
                                  color: isMerchantsSegment
                                      ? Colors.white
                                      : AppColors.textSecondaryLight,
                                ),
                                const Gap(6),
                                Text(
                                  'admin_mgmt.merchants_tab'.tr(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isMerchantsSegment
                                        ? Colors.white
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                                if (pendingMerchantsCount > 0) ...[
                                  const Gap(6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isMerchantsSegment
                                          ? Colors.white
                                          : Colors.amber[700],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '$pendingMerchantsCount',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isMerchantsSegment
                                            ? AppColors.primary
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Beneficiaries Segment Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () => cubit.setSegment(1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: !isMerchantsSegment
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_alt_rounded,
                                  size: 16,
                                  color: !isMerchantsSegment
                                      ? Colors.white
                                      : AppColors.textSecondaryLight,
                                ),
                                const Gap(6),
                                Text(
                                  'admin_mgmt.beneficiaries_tab'.tr(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: !isMerchantsSegment
                                        ? Colors.white
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                                if (pendingBeneficiariesCount > 0) ...[
                                  const Gap(6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: !isMerchantsSegment
                                          ? Colors.white
                                          : Colors.amber[700],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '$pendingBeneficiariesCount',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: !isMerchantsSegment
                                            ? AppColors.primary
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: AlfajrRefreshIndicator(
            onRefresh: () => cubit.refreshData(),
            child: isMerchantsSegment
                ? _buildMerchantsList(context, merchants, cubit, currencyFormatter)
                : _buildBeneficiariesList(context, beneficiaries, cubit),
          ),
        );
      },
    );
  }

  Widget _buildMerchantsList(
    BuildContext context,
    List<dynamic> merchants,
    AdminMerchantsCubit cubit,
    NumberFormat currencyFormatter,
  ) {
    if (merchants.isEmpty) {
      return Center(
        child: Text(
          'admin_mgmt.no_merchants'.tr(),
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondaryLight),
        ),
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
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
                  : Colors.amber[800]!.withValues(alpha: 0.4),
              width: merchant.isActive ? 1 : 1.5,
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
                          : Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.storefront_rounded,
                      color: merchant.isActive
                          ? AppColors.primary
                          : Colors.amber[800],
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        const Gap(2),
                        Text(
                          '${merchant.storeType} • ${merchant.city}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: merchant.isActive,
                    activeThumbColor: AppColors.success,
                    inactiveThumbColor: Colors.amber[800],
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
                      Text(
                        'dashboard.admin.total_transactions_label'.tr(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        currencyFormatter.format(merchant.totalTransactions),
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
                      Text(
                        'dashboard.admin.total_disbursed_label'.tr(),
                        style: const TextStyle(
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
                      '${'dashboard.admin.cr_label'.tr()}: ${merchant.commercialReg}',
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
    );
  }

  Widget _buildBeneficiariesList(
    BuildContext context,
    List<dynamic> beneficiaries,
    AdminMerchantsCubit cubit,
  ) {
    if (beneficiaries.isEmpty) {
      return Center(
        child: Text(
          'admin_mgmt.no_beneficiaries'.tr(),
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondaryLight),
        ),
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: beneficiaries.length,
      separatorBuilder: (context, index) => const Gap(14),
      itemBuilder: (context, index) {
        final b = beneficiaries[index];
        final isApproved = b.isApproved && b.isActive;

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isApproved
                  ? AppColors.borderLight
                  : Colors.amber[800]!.withValues(alpha: 0.4),
              width: isApproved ? 1 : 1.5,
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
                      color: isApproved
                          ? AppColors.primarySubtle
                          : Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isApproved
                          ? Icons.person_rounded
                          : Icons.hourglass_top_rounded,
                      color:
                          isApproved ? AppColors.primary : Colors.amber[800],
                      size: 22,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        const Gap(2),
                        Text(
                          '${b.phone} • ${b.city}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isApproved,
                    activeThumbColor: AppColors.success,
                    inactiveThumbColor: Colors.amber[800],
                    onChanged: (_) {
                      cubit.toggleBeneficiaryStatus(b.id, b.cardId);
                    },
                  ),
                ],
              ),
              const Gap(14),
              const Divider(height: 1, color: AppColors.borderLight),
              const Gap(12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.credit_card_rounded,
                        size: 14,
                        color: AppColors.textSecondaryLight,
                      ),
                      const Gap(6),
                      Text(
                        'admin_mgmt.card_label'.tr(namedArgs: {'cardId': b.cardId}),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isApproved
                          ? AppColors.success.withValues(alpha: 0.1)
                          : Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isApproved
                          ? 'admin_mgmt.approved_active'.tr()
                          : 'admin_mgmt.pending_review'.tr(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color:
                            isApproved ? AppColors.success : Colors.amber[800],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

