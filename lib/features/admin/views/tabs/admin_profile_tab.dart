import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/service_locator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/route_names.dart';
import '../../../auth/view_models/auth_cubit.dart';
import '../../../auth/view_models/auth_state.dart';
import '../../view_models/admin_cubit.dart';
import '../../view_models/admin_state.dart';

class AdminProfileTab extends StatelessWidget {
  const AdminProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = sl<AuthCubit>().state;
    final user = authState is Authenticated ? authState.user : null;
    final isArabic = context.locale.languageCode == 'ar';

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
                onPressed: () => _confirmLogout(context),
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
                          size: 46,
                          color: AppColors.primary,
                        ),
                      ),
                      const Gap(14),
                      Text(
                        displayName,
                        textAlign: TextAlign.center,
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
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      const Gap(14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.security_rounded,
                              size: 16,
                              color: AppColors.accentLight,
                            ),
                            Gap(6),
                            Text(
                              'المشرف العام ومدير المنظومة',
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

                // 2. Administrative Credentials Card
                _buildSectionCard(
                  title: 'بيانات الحساب الإداري الرسمي',
                  icon: Icons.badge_outlined,
                  children: [
                    _buildInfoRow(
                      icon: Icons.person_outline_rounded,
                      label: 'الاسم الكامل',
                      value: displayName,
                    ),
                    _buildDivider(),
                    _buildInfoRow(
                      icon: Icons.work_outline_rounded,
                      label: 'المسمى الوظيفي',
                      value: 'مدير عام الرقابة والعمليات الإغاثية',
                    ),
                    _buildDivider(),
                    _buildInfoRow(
                      icon: Icons.email_outlined,
                      label: 'البريد الرسمي',
                      value: displayEmail,
                    ),
                    _buildDivider(),
                    _buildInfoRow(
                      icon: Icons.phone_outlined,
                      label: 'رقم هاتف المسؤول',
                      value: displayPhone,
                    ),
                    _buildDivider(),
                    _buildInfoRow(
                      icon: Icons.location_city_outlined,
                      label: 'مقر الإشراف',
                      value: displayCity,
                    ),
                  ],
                ),

                const Gap(16),

                // 3. System Permissions & Governance Scope
                _buildSectionCard(
                  title: 'نطاق الصلاحيات والحوكمة',
                  icon: Icons.verified_user_outlined,
                  children: [
                    _buildInfoRow(
                      icon: Icons.qr_code_2_rounded,
                      label: 'إدارة وتفعيل كروت المستفيدين',
                      value: 'صلاحية كاملة (Full Access)',
                      valueColor: AppColors.success,
                    ),
                    _buildDivider(),
                    _buildInfoRow(
                      icon: Icons.storefront_rounded,
                      label: 'اعتماد وإيقاف منافذ الصرف',
                      value: 'صلاحية كاملة (Full Access)',
                      valueColor: AppColors.success,
                    ),
                    _buildDivider(),
                    _buildInfoRow(
                      icon: Icons.insights_rounded,
                      label: 'التقارير المالية والسيولة',
                      value: 'صلاحية كاملة (Full Access)',
                      valueColor: AppColors.success,
                    ),
                    _buildDivider(),
                    _buildInfoRow(
                      icon: Icons.shield_rounded,
                      label: 'مستوى الأمان وحماية البيانات',
                      value: 'مشرف أول (Root Admin)',
                      valueColor: AppColors.primary,
                    ),
                  ],
                ),

                const Gap(16),

                // 4. System Settings
                _buildSectionCard(
                  title: 'إعدادات النظام واللغة',
                  icon: Icons.settings_outlined,
                  children: [
                    InkWell(
                      onTap: () {
                        final newLocale = isArabic
                            ? AppConstants.englishLocale
                            : AppConstants.arabicLocale;
                        context.setLocale(newLocale);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primarySubtle,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.language_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                            ),
                            const Gap(12),
                            const Text(
                              'لغة لوحة التحكم (Language)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              isArabic ? 'العربية (AR)' : 'English (EN)',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const Gap(6),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: AppColors.textMutedLight,
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildDivider(),
                    InkWell(
                      onTap: () => context.push(RouteNames.aboutUs),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primarySubtle,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.info_outline_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                            ),
                            const Gap(12),
                            const Text(
                              'عن منصة قُوت',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: AppColors.textMutedLight,
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildDivider(),
                    InkWell(
                      onTap: () => context.push(RouteNames.faq),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primarySubtle,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.quiz_outlined,
                                size: 18,
                                color: AppColors.primary,
                              ),
                            ),
                            const Gap(12),
                            const Text(
                              'الأسئلة الشائعة',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: AppColors.textMutedLight,
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildDivider(),
                    InkWell(
                      onTap: () => context.push(RouteNames.termsPrivacy),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primarySubtle,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.verified_user_outlined,
                                size: 18,
                                color: AppColors.primary,
                              ),
                            ),
                            const Gap(12),
                            const Text(
                              'الشروط واللوائح والخصوصية',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: AppColors.textMutedLight,
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildDivider(),
                    InkWell(
                      onTap: () => context.push(RouteNames.contactSupport),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primarySubtle,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.headset_mic_outlined,
                                size: 18,
                                color: AppColors.primary,
                              ),
                            ),
                            const Gap(12),
                            const Text(
                              'مركز الدعم وغرفة العمليات',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: AppColors.textMutedLight,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const Gap(24),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmLogout(context),
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

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const Gap(10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          const Gap(12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 18, color: AppColors.textMutedLight),
          ),
          const Gap(10),
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondaryLight,
                height: 1.3,
              ),
            ),
          ),
          const Gap(10),
          Flexible(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: valueColor ?? AppColors.textPrimaryLight,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: AppColors.borderLight);
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تأكيد تسجيل الخروج'),
        content: const Text(
          'هل أنت متأكد من رغبتك في تسجيل الخروج من لوحة الإدارة؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              sl<AuthCubit>().signOut();
              context.go(RouteNames.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}
