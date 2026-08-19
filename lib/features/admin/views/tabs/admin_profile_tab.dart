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
import '../../../auth/view_models/auth_cubit.dart';
import '../../../auth/view_models/auth_state.dart';
import '../../view_models/admin_cubit.dart';
import '../../view_models/admin_state.dart';

class AdminProfileTab extends StatelessWidget {
  const AdminProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final user = authState is Authenticated ? authState.user : null;
    final currencyFormatter = NumberFormat('#,###');

    final displayName = user?.name.isNotEmpty == true
        ? user!.name
        : 'المشرف العام';
    final displayEmail = user?.email.isNotEmpty == true ? user!.email : '-';
    final displayPhone = user?.phone?.isNotEmpty == true ? user!.phone! : '-';
    final displayCity = user?.city?.isNotEmpty == true
        ? user!.city!
        : 'المقر الرئيسي';

    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: const Text('الملف الإداري العام'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                onPressed: () => LogoutConfirmDialog.show(context),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                // 1. Admin Header Card
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
                          Icons.admin_panel_settings_rounded,
                          size: 44,
                          color: AppColors.primary,
                        ),
                      ),
                      const Gap(14),
                      Text(
                        displayName,
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
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.security_rounded,
                              size: 15,
                              color: AppColors.accentLight,
                            ),
                            Gap(6),
                            Text(
                              'إدارة الحوكمة والرقابة العليا',
                              style: TextStyle(
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

                // 2. Administrative Authority & Responsibilities
                ProfileSectionCard(
                  title: 'الصلاحيات والمسؤوليات الإدارية',
                  icon: Icons.shield_outlined,
                  children: const [
                    ProfileInfoRow(
                      label: 'الرتبة في المنظومة',
                      value: 'مشرف عام ومراقب مالي',
                      valueColor: AppColors.primary,
                    ),
                    ProfileInfoRow(
                      label: 'مستوى الوصول للبيانات',
                      value: 'وصول شامل (Full Superadmin Access)',
                    ),
                    ProfileInfoRow(
                      label: 'صلاحية منافذ الصرف',
                      value: 'اعتماد، تجميد، وإلغاء المنافذ',
                    ),
                    ProfileInfoRow(
                      label: 'صلاحية التتبع المالي',
                      value: 'متابعة الصرف والخصومات اللحظية',
                      showDivider: false,
                    ),
                  ],
                ),

                const Gap(16),

                // 3. Central System High-level KPIs
                ProfileSectionCard(
                  title: 'مؤشرات المنظومة المركزية',
                  icon: Icons.analytics_outlined,
                  children: [
                    ProfileInfoRow(
                      label: 'إجمالي أموال الدعم المصروفة',
                      value:
                          '${currencyFormatter.format(state.totalFundsDisbursed)} ${'common.currency'.tr()}',
                      valueColor: AppColors.primaryDark,
                    ),
                    ProfileInfoRow(
                      label: 'إجمالي الأسر المستفيدة المسجلة',
                      value: '${state.totalBeneficiariesCount} أسرة',
                    ),
                    ProfileInfoRow(
                      label: 'منافذ الصرف النشطة المعتمدة',
                      value: '${state.activeMerchantsCount} منفذ',
                    ),
                    ProfileInfoRow(
                      label: 'إجمالي عمليات الصرف الموثقة',
                      value: '${state.totalRedemptionsCount} عملية',
                      showDivider: false,
                    ),
                  ],
                ),

                const Gap(16),

                // 4. Contact & Headquarters
                ProfileSectionCard(
                  title: 'معلومات الإدارة والمقر',
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
                      label: 'المقر والفرع الإداري',
                      value: displayCity,
                      showDivider: false,
                    ),
                  ],
                ),

                const Gap(16),

                // 5. System Settings & Info Content Links
                ProfileSectionCard(
                  title: 'إعدادات النظام والدعم',
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
