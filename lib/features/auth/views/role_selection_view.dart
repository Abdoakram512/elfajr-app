import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/widgets/primary_button.dart';
import '../models/user_role.dart';
import '../widgets/role_card.dart';

class RoleSelectionView extends StatefulWidget {
  const RoleSelectionView({super.key});

  @override
  State<RoleSelectionView> createState() => _RoleSelectionViewState();
}

class _RoleSelectionViewState extends State<RoleSelectionView> {
  UserRole _selectedRole = UserRole.beneficiary;

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Bar with Language Toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Brand Indicator
                          Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.accentLight,
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.15),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(17),
                                  child: Image.asset(
                                    AppAssets.appIcon,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(
                                      Icons.volunteer_activism_rounded,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              const Gap(10),
                              Text(
                                'app_name'.tr(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),

                          // Language Switcher
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
                                border: Border.all(
                                  color: AppColors.borderLight,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.language_rounded,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  const Gap(6),
                                  Text(
                                    isArabic ? 'English' : 'العربية',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Gap(28),

                      // Title & Subtitle
                      Text(
                            'auth.choose_role'.tr(),
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryLight,
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.2, end: 0, duration: 400.ms),

                      const Gap(8),

                      Text(
                            'auth.role_selection_subtitle'.tr(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondaryLight,
                            ),
                          )
                          .animate()
                          .fadeIn(delay: 100.ms, duration: 400.ms)
                          .slideY(begin: 0.2, end: 0, duration: 400.ms),

                      const Gap(24),

                      // 1. Beneficiary Card
                      RoleCard(
                            role: UserRole.beneficiary,
                            title: 'auth.role_beneficiary'.tr(),
                            description: 'auth.role_beneficiary_desc'.tr(),
                            icon: Icons.qr_code_rounded,
                            themeColor: AppColors.primary,
                            isSelected: _selectedRole == UserRole.beneficiary,
                            onSelect: () => setState(
                              () => _selectedRole = UserRole.beneficiary,
                            ),
                          )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 400.ms)
                          .slideX(begin: 0.1, end: 0),

                      const Gap(16),

                      // 2. Merchant / Aid Dispenser Card
                      RoleCard(
                            role: UserRole.merchant,
                            title: 'auth.role_merchant'.tr(),
                            description: 'auth.role_merchant_desc'.tr(),
                            icon: Icons.storefront_rounded,
                            themeColor: const Color(0xFFD97706),
                            isSelected: _selectedRole == UserRole.merchant,
                            onSelect: () => setState(
                              () => _selectedRole = UserRole.merchant,
                            ),
                          )
                          .animate()
                          .fadeIn(delay: 300.ms, duration: 400.ms)
                          .slideX(begin: 0.1, end: 0),

                      const Spacer(),
                      const Gap(24),

                      // Continue Button
                      PrimaryButton(
                        text: 'common.next'.tr(),
                        onPressed: () {
                          context.push(
                            RouteNames.register,
                            extra: _selectedRole,
                          );
                        },
                      ),

                      const Gap(16),

                      // Sign in Link
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'auth.already_have_account'.tr(),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go(RouteNames.login),
                              child: Text(
                                'auth.login'.tr(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
