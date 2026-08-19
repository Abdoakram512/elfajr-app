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
import '../../view_models/beneficiary_cubit.dart';
import '../../view_models/beneficiary_state.dart';

class BeneficiaryProfileTab extends StatelessWidget {
  const BeneficiaryProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = sl<AuthCubit>().state;
    final user = authState is Authenticated ? authState.user : null;
    final isArabic = context.locale.languageCode == 'ar';

    final displayName = user?.name.isNotEmpty == true
        ? user!.name
        : 'أحمد سعيد الغامدي';
    final displayEmail = user?.email.isNotEmpty == true
        ? user!.email
        : 'ahmed.alghamdi@qout.org';
    final displayPhone = user?.phone?.isNotEmpty == true
        ? user!.phone!
        : '+966 55 123 4567';
    final displayCity = user?.city?.isNotEmpty == true ? user!.city! : 'الرياض';

    return BlocBuilder<BeneficiaryCubit, BeneficiaryState>(
      builder: (context, state) {
        final card = state.activeCard;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: const Text('الملف الشخصي والبيانات'),
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
                // 1. User Header Profile Card
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
                          Icons.person_rounded,
                          size: 48,
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
                              Icons.verified_user_rounded,
                              size: 16,
                              color: AppColors.accentLight,
                            ),
                            Gap(6),
                            Text(
                              'مستفيد معتمد في منظومة قوت',
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

                // 2. Personal Information Card
                _buildSectionCard(
                  title: 'البيانات الشخصية والأسرة',
                  icon: Icons.badge_outlined,
                  children: [
                    _buildInfoRow(
                      icon: Icons.person_outline_rounded,
                      label: 'الاسم الكامل',
                      value: displayName,
                    ),
                    _buildDivider(),
                    _buildInfoRow(
                      icon: Icons.credit_card_outlined,
                      label: 'رقم الهوية الوطنية',
                      value: card?.nationalId ?? '1089283746',
                    ),
                    _buildDivider(),
                    _buildInfoRow(
                      icon: Icons.phone_outlined,
                      label: 'رقم الجوال',
                      value: displayPhone,
                    ),
                    _buildDivider(),
                    _buildInfoRow(
                      icon: Icons.location_on_outlined,
                      label: 'المدينة / المنطقة',
                      value: displayCity,
                    ),
                    _buildDivider(),
                    _buildInfoRow(
                      icon: Icons.family_restroom_outlined,
                      label: 'أفراد الأسرة المسجلين',
                      value: '${card?.familyCount ?? 5} أفراد',
                    ),
                  ],
                ),

                const Gap(16),

                // 3. Digital Aid Card Info Card
                if (card != null) ...[
                  _buildSectionCard(
                    title: 'بيانات كارت الإغاثة المربوط',
                    icon: Icons.qr_code_rounded,
                    children: [
                      _buildInfoRow(
                        icon: Icons.numbers_rounded,
                        label: 'رقم الكارت الذكي',
                        value: card.cardId,
                      ),
                      _buildDivider(),
                      _buildInfoRow(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'الرصيد الإجمالي المتاح',
                        value:
                            '${card.totalBalance.toInt()} ${'common.currency'.tr()}',
                        valueColor: AppColors.primary,
                      ),
                      _buildDivider(),
                      _buildInfoRow(
                        icon: Icons.shopping_basket_outlined,
                        label: 'حصة السلال التموينية',
                        value: '${card.foodBasketsQuota} سلال غذائية',
                        valueColor: AppColors.accentDark,
                      ),
                      _buildDivider(),
                      _buildInfoRow(
                        icon: Icons.event_available_outlined,
                        label: 'حالة الصلاحية',
                        value: 'صالح ومفعل للاستخدام',
                        valueColor: AppColors.success,
                      ),
                    ],
                  ),
                  const Gap(16),
                ],

                // 4. App & Support Settings
                _buildSectionCard(
                  title: 'إعدادات الحساب والدعم',
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
                              'لغة التطبيق (Language)',
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
                      onTap: () => _showHelpDialog(context),
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
                              'مركز الرعاية والدعم الإغاثي',
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
        children: [
          Icon(icon, size: 18, color: AppColors.textMutedLight),
          const Gap(10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryLight,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: AppColors.borderLight);
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.headset_mic_rounded, color: AppColors.primary),
            Gap(10),
            Text('مركز الرعاية والدعم'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'فريق الدعم الفني والإغاثي في قوت جاهز لخدمتك والرد على استفسارات الصرف على مدار الساعة.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            Gap(14),
            Text(
              '📞 الرقم الموحد: 8001234567\n✉️ البريد: support@qout.org',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'إغلاق',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تأكيد تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج من حسابك؟'),
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
