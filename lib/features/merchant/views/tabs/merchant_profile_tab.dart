import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:qout/app/service_locator.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/dialogs/logout_confirm_dialog.dart';
import '../../../../core/widgets/profile/profile_info_content_links.dart';
import '../../../../core/widgets/profile/profile_info_row.dart';
import '../../../../core/widgets/profile/profile_language_tile.dart';
import '../../../../core/widgets/profile/profile_section_card.dart';
import '../../../auth/view_models/auth_cubit.dart';
import '../../../auth/view_models/auth_state.dart';
import '../../view_models/merchant_dashboard_cubit.dart';
import '../../view_models/merchant_dashboard_state.dart';

class MerchantProfileTab extends StatelessWidget {
  const MerchantProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = getIt<AuthCubit>().state;
    final user = authState is Authenticated ? authState.user : null;
    final currencyFormatter = NumberFormat('#,###');

    final storeName = user?.storeName?.isNotEmpty == true
        ? user!.storeName!
        : (user?.name.isNotEmpty == true ? user!.name : 'منفذ معتمد');
    final displayEmail = user?.email.isNotEmpty == true ? user!.email : '-';
    final displayPhone = user?.phone?.isNotEmpty == true ? user!.phone! : '-';
    final displayCity =
        user?.city?.isNotEmpty == true ? user!.city! : 'المدينة';
    final commercialReg = user?.commercialReg?.isNotEmpty == true
        ? user!.commercialReg!
        : '-';

    return BlocBuilder<MerchantDashboardCubit, MerchantDashboardState>(
      builder: (context, state) {
        final totalBasketsDispensed = state.recentTransactions.fold<int>(
          0,
          (sum, item) => sum + item.foodBasketsDeducted,
        );

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: Text('profile.merchant_title'.tr()),
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                // 1. Merchant Header Card
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
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.accentLight,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.storefront_rounded,
                          size: 44,
                          color: AppColors.primary,
                        ),
                      ),
                      const Gap(14),
                      Text(
                        storeName,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        displayEmail,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const Gap(12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified_rounded,
                              size: 15,
                              color: AppColors.accentLight,
                            ),
                            const Gap(6),
                            Text(
                              'profile.merchant_role_badge'.tr(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Gap(20),

                // 2. Commercial & Registry Information
                ProfileSectionCard(
                  title: 'profile.merchant_license_title'.tr(),
                  icon: Icons.domain_rounded,
                  children: [
                    ProfileInfoRow(
                      label: 'auth.store_name_label'.tr(),
                      value: storeName,
                    ),
                    ProfileInfoRow(
                      label: 'profile.cr_number_label'.tr(),
                      value: commercialReg,
                    ),
                    ProfileInfoRow(
                      label: 'profile.license_status_label'.tr(),
                      value: 'profile.active_and_verified'.tr(),
                      valueColor: AppColors.success,
                    ),
                    ProfileInfoRow(
                      label: 'auth.city'.tr(),
                      value: displayCity,
                      showDivider: false,
                    ),
                  ],
                ),

                const Gap(16),

                // 3. Overall Operational Metrics
                ProfileSectionCard(
                  title: 'profile.merchant_stats_title'.tr(),
                  icon: Icons.insights_rounded,
                  children: [
                    ProfileInfoRow(
                      label: 'dashboard.admin.total_disbursed_label'.tr(),
                      value:
                          '${currencyFormatter.format(state.todayDispensedAmount)} ${'common.currency'.tr()}',
                      valueColor: AppColors.primaryDark,
                    ),
                    ProfileInfoRow(
                      label: 'profile.total_baskets_label'.tr(),
                      value: '$totalBasketsDispensed ${'profile.baskets_unit'.tr()}',
                      valueColor: AppColors.accentDark,
                    ),
                    ProfileInfoRow(
                      label: 'profile.transactions_count_label'.tr(),
                      value: '${state.recentTransactions.length} ${'profile.txns_unit'.tr()}',
                      showDivider: false,
                    ),
                  ],
                ),

                const Gap(16),

                // 4. Contact & Support
                ProfileSectionCard(
                  title: 'profile.contact_info_title'.tr(),
                  icon: Icons.contact_phone_outlined,
                  children: [
                    ProfileInfoRow(
                      label: 'auth.phone'.tr(),
                      value: displayPhone,
                    ),
                    ProfileInfoRow(
                      label: 'auth.email'.tr(),
                      value: displayEmail,
                      showDivider: false,
                    ),
                  ],
                ),

                const Gap(16),

                // 5. System Settings & Info Content Links
                ProfileSectionCard(
                  title: 'profile.system_info'.tr(),
                  icon: Icons.settings_outlined,
                  children: const [
                    ProfileLanguageTile(),
                    ProfileInfoContentLinks(wrapInSectionCard: false),
                  ],
                ),

                const Gap(24),

                // 6. Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () => LogoutConfirmDialog.show(context),
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.error,
                    ),
                    label: Text(
                      'common.logout'.tr(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.error,
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const Gap(20),
              ],
            ),
          ),
        );
      },
    );
  }
}
