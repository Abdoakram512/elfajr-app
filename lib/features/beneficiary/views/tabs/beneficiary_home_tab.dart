import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../view_models/beneficiary_cubit.dart';
import '../../view_models/beneficiary_state.dart';
import '../../widgets/digital_aid_card_widget.dart';

class BeneficiaryHomeTab extends StatelessWidget {
  const BeneficiaryHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,###');
    final dateFormatter = DateFormat('yyyy/MM/dd - HH:mm');
    final isArabic = context.locale.languageCode == 'ar';

    return BlocBuilder<BeneficiaryCubit, BeneficiaryState>(
      builder: (context, state) {
        final cubit = context.read<BeneficiaryCubit>();

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primarySubtle,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.handshake_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const Gap(10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'app_name'.tr(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                'dashboard.beneficiary.greeting'.tr(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Language Switcher Pill
                      InkWell(
                        onTap: () {
                          final newLocale = isArabic
                              ? AppConstants.englishLocale
                              : AppConstants.arabicLocale;
                          context.setLocale(newLocale);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Text(
                            isArabic ? 'English' : 'العربية',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Gap(22),

                  // Digital QR Aid Card
                  if (state.activeCard != null) ...[
                    DigitalAidCardWidget(card: state.activeCard!),
                    const Gap(22),
                  ],

                  // How to use QR Card Instructions Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.borderLight),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
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
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.info_outline_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const Gap(10),
                            const Text(
                              'كيف تصرف مستحقاتك من المنافذ؟',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                          ],
                        ),
                        const Gap(16),
                        _buildInstructionStep(
                          stepNumber: '1',
                          title: 'التوجه لمنفذ الصرف المعتمد',
                          desc: 'توجه لأي سوبرماركت أو صيدلية معتمدة تابعة لمنظومة قوت.',
                        ),
                        const Gap(12),
                        _buildInstructionStep(
                          stepNumber: '2',
                          title: 'إبراز باركود الـ QR من التطبيق',
                          desc: 'اعرض الكارت أعلاه للكاشير لمسحه مباشرة بكاميرا هاتفه.',
                        ),
                        const Gap(12),
                        _buildInstructionStep(
                          stepNumber: '3',
                          title: 'الخصم الفوري واستلام السلع',
                          desc: 'يتم خصم المبلغ أو السلة ويتحدث رصيدك اللحظي فوراً.',
                        ),
                      ],
                    ),
                  ),

                  const Gap(26),

                  // Recent Redemptions Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'سجل عمليات الصرف الأخيرة',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      TextButton(
                        onPressed: () => cubit.setTab(1),
                        child: const Text(
                          'عرض الكل',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Gap(12),

                  if (state.redemptions.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'لم تقم بأي عمليات صرف بعد.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textMutedLight,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.redemptions.length,
                      separatorBuilder: (context, index) => const Gap(12),
                      itemBuilder: (context, index) {
                        final item = state.redemptions[index];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.merchantStoreName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimaryLight,
                                    ),
                                  ),
                                  Text(
                                    '-${currencyFormatter.format(item.amountDeducted)} ${'common.currency'.tr()}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    dateFormatter.format(item.timestamp),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondaryLight,
                                    ),
                                  ),
                                  if (item.foodBasketsDeducted > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentLight.withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'تم صرف ${item.foodBasketsDeducted} سلة',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.accentDark,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInstructionStep({
    required String stepNumber,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primarySubtle,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 1.2),
          ),
          child: Center(
            child: Text(
              stepNumber,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const Gap(2),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondaryLight,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
