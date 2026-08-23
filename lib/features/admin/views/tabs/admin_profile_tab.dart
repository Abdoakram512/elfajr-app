import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/dialogs/logout_confirm_dialog.dart';
import '../../../../core/widgets/profile/profile_info_content_links.dart';
import '../../../../core/widgets/profile/profile_info_row.dart';
import '../../../../core/widgets/profile/profile_language_tile.dart';
import '../../../../core/widgets/profile/profile_section_card.dart';
import '../../../../core/widgets/profile/unified_profile_header.dart';
import '../../../auth/view_models/auth_cubit.dart';
import '../../../auth/view_models/auth_state.dart';
import '../../../../app/service_locator.dart';
import '../../view_models/admin_overview_cubit.dart';
import '../../view_models/admin_overview_state.dart';

class AdminProfileTab extends StatelessWidget {
  const AdminProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminOverviewCubit>(),
      child: const _AdminProfileTabBody(),
    );
  }
}

class _AdminProfileTabBody extends StatelessWidget {
  const _AdminProfileTabBody();

  @override
  Widget build(BuildContext context) {
    final authState = getIt<AuthCubit>().state;
    final user = authState is Authenticated ? authState.user : null;
    final currencyFormatter = NumberFormat('#,###');

    final displayName = user?.name.isNotEmpty == true
        ? user!.name
        : 'profile.admin_role_badge'.tr();
    final displayEmail = user?.email.isNotEmpty == true ? user!.email : '-';
    final displayPhone = user?.phone?.isNotEmpty == true ? user!.phone! : '-';
    final displayCity = user?.city?.isNotEmpty == true
        ? user!.city!
        : 'info_content.headquarters'.tr();

    return BlocBuilder<AdminOverviewCubit, AdminOverviewState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: Text('profile.admin_title'.tr()),
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                // 1. Admin Header Card
                UnifiedProfileHeader(
                  name: displayName,
                  subtitle: displayEmail,
                  badgeText: 'profile.admin_role_badge'.tr(),
                  badgeIcon: Icons.security_rounded,
                  avatarIcon: Icons.admin_panel_settings_rounded,
                ),

                const Gap(20),

                // 2. Administrative Authority & Responsibilities
                ProfileSectionCard(
                  title: 'profile.admin_authority_title'.tr(),
                  icon: Icons.shield_outlined,
                  children: [
                    ProfileInfoRow(
                      label: 'profile.admin_role_label'.tr(),
                      value: 'profile.admin_role_value'.tr(),
                      valueColor: AppColors.primary,
                    ),
                    ProfileInfoRow(
                      label: 'profile.admin_access_label'.tr(),
                      value: 'profile.admin_access_value'.tr(),
                    ),
                    ProfileInfoRow(
                      label: 'profile.admin_merchants_perm'.tr(),
                      value: 'profile.admin_merchants_perm_val'.tr(),
                    ),
                    ProfileInfoRow(
                      label: 'profile.admin_finance_perm'.tr(),
                      value: 'profile.admin_finance_perm_val'.tr(),
                      showDivider: false,
                    ),
                  ],
                ),

                const Gap(16),

                // 3. Central System High-level KPIs
                ProfileSectionCard(
                  title: 'profile.system_kpis_title'.tr(),
                  icon: Icons.analytics_outlined,
                  children: [
                    ProfileInfoRow(
                      label: 'admin.stats.total_disbursed'.tr(),
                      value:
                          '${currencyFormatter.format(state.totalFundsDisbursed)} ${'common.currency'.tr()}',
                      valueColor: AppColors.primaryDark,
                    ),
                    ProfileInfoRow(
                      label: 'admin.stats.total_beneficiaries'.tr(),
                      value:
                          '${state.totalBeneficiariesCount} ${'profile.families_unit'.tr()}',
                    ),
                    ProfileInfoRow(
                      label: 'admin.stats.active_merchants'.tr(),
                      value:
                          '${state.activeMerchantsCount} ${'profile.stores_unit'.tr()}',
                    ),
                    ProfileInfoRow(
                      label: 'admin.stats.total_redemptions'.tr(),
                      value:
                          '${state.totalRedemptionsCount} ${'profile.txns_unit'.tr()}',
                      showDivider: false,
                    ),
                  ],
                ),

                const Gap(16),

                // 4. Contact & Headquarters
                ProfileSectionCard(
                  title: 'profile.contact_hq_title'.tr(),
                  icon: Icons.business_rounded,
                  children: [
                    ProfileInfoRow(
                      label: 'auth.phone'.tr(),
                      value: displayPhone,
                    ),
                    ProfileInfoRow(
                      label: 'auth.email'.tr(),
                      value: displayEmail,
                    ),
                    ProfileInfoRow(
                      label: 'info_content.headquarters'.tr(),
                      value: displayCity,
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
