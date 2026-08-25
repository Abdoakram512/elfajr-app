import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../app/service_locator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../core/widgets/dialogs/logout_confirm_dialog.dart';
import '../../../../core/widgets/profile/profile_info_content_links.dart';
import '../../../../core/widgets/profile/profile_info_row.dart';
import '../../../../core/widgets/profile/profile_language_tile.dart';
import '../../../../core/widgets/profile/profile_section_card.dart';
import '../../../../core/widgets/profile/unified_profile_header.dart';
import '../../../auth/view_models/auth_cubit.dart';
import '../../../auth/view_models/auth_state.dart';
import '../../view_models/beneficiary_cubit.dart';
import '../../view_models/beneficiary_state.dart';

import '../../../beneficiary/models/aid_card_model.dart';

class BeneficiaryProfileTab extends StatelessWidget {
  const BeneficiaryProfileTab({super.key});

  String _resolveEligibilityText(AidCardModel? card) {
    if (card == null) {
      return 'profile.eligibility_pending'.tr();
    }
    switch (card.status) {
      case AidCardStatus.active:
        return 'profile.eligibility_eligible'.tr();
      case AidCardStatus.pendingActivation:
        return 'profile.eligibility_pending'.tr();
      case AidCardStatus.frozen:
        return 'profile.eligibility_frozen'.tr();
      case AidCardStatus.depleted:
        return 'digital_card.status_active_short'.tr();
      case AidCardStatus.expired:
        return 'profile.eligibility_expired'.tr();
    }
  }

  Color _resolveEligibilityColor(AidCardModel? card) {
    if (card == null) return AppColors.warning;
    switch (card.status) {
      case AidCardStatus.active:
        return AppColors.success;
      case AidCardStatus.pendingActivation:
        return AppColors.warning;
      case AidCardStatus.frozen:
      case AidCardStatus.expired:
        return AppColors.error;
      case AidCardStatus.depleted:
        return AppColors.textSecondaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = getIt<AuthCubit>().state;
    final user = authState is Authenticated ? authState.user : null;

    final displayName = user?.name.isNotEmpty == true
        ? user!.name
        : 'auth.role_beneficiary'.tr();
    final rawEmail = user?.email.isNotEmpty == true ? user!.email : '-';
    final displayEmail = rawEmail.endsWith('@alfajr.app')
        ? (user?.phone?.isNotEmpty == true ? user!.phone! : rawEmail)
        : rawEmail;
    final displayPhone = user?.phone?.isNotEmpty == true ? user!.phone! : '-';
    final displayCity = user?.city?.isNotEmpty == true ? user!.city! : '';

    return BlocBuilder<BeneficiaryCubit, BeneficiaryState>(
      builder: (context, state) {
        final card = state.activeCard;
        final rawNat = (user?.nationality?.isNotEmpty == true)
            ? user!.nationality!
            : (card?.nationality?.isNotEmpty == true
                  ? card!.nationality!
                  : '-');
        final displayNat = rawNat;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: Text('profile.beneficiary_title'.tr()),
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                // 1. User Header Profile Card
                UnifiedProfileHeader(
                  name: displayName,
                  subtitle: displayEmail,
                  badgeText: 'auth.role_beneficiary'.tr(),
                  badgeIcon: Icons.verified_user_rounded,
                  avatarIcon: Icons.person_rounded,
                ),

                const Gap(20),

                // 2. Beneficiary Official Card Details
                ProfileSectionCard(
                  title: 'profile.beneficiary_case_details'.tr(),
                  icon: Icons.badge_outlined,
                  children: [
                    ProfileInfoRow(
                      label: 'digital_card.card_number'.tr(),
                      value: card?.cardId ?? '-',
                    ),
                    ProfileInfoRow(
                      label: 'digital_card.passport_or_id'.tr(),
                      value: user?.nationalId ?? card?.nationalId ?? '-',
                    ),
                    ProfileInfoRow(
                      label: 'profile.social_status_label'.tr(),
                      value: user?.socialStatus ?? card?.socialStatus ?? '-',
                      valueColor: AppColors.primary,
                    ),
                    ProfileInfoRow(
                      label: 'profile.nationality_label'.tr(),
                      value: displayNat,
                    ),
                    ProfileInfoRow(
                      label: 'profile.field_research_label'.tr(),
                      value:
                          user?.fieldResearchStatus ??
                          card?.fieldResearchStatus ??
                          'profile.field_research_completed'.tr(),
                      valueColor: AppColors.success,
                    ),
                    ProfileInfoRow(
                      label: 'profile.eligibility_status_label'.tr(),
                      value: _resolveEligibilityText(card),
                      valueColor: _resolveEligibilityColor(card),
                    ),
                    ProfileInfoRow(
                      label: 'profile.expires_at_label'.tr(),
                      value: card != null
                          ? AppFormatters.formatDate(
                              card.expiresAt,
                              context: context,
                            )
                          : '-',
                      showDivider: false,
                    ),
                  ],
                ),

                if ((user?.medicalNotes?.isNotEmpty == true) ||
                    (user?.inKindNeeds?.isNotEmpty == true)) ...[
                  const Gap(16),
                  ProfileSectionCard(
                    title: 'profile.medical_and_needs_title'.tr(),
                    icon: Icons.health_and_safety_outlined,
                    children: [
                      if (user?.medicalNotes?.isNotEmpty == true)
                        ProfileInfoRow(
                          label: 'profile.medical_aid_label'.tr(),
                          value: user!.medicalNotes!,
                          valueColor: AppColors.primaryDark,
                        ),
                      if (user?.inKindNeeds?.isNotEmpty == true)
                        ProfileInfoRow(
                          label: 'profile.inkind_needs_label'.tr(),
                          value: user!.inKindNeeds!,
                          showDivider: false,
                        ),
                    ],
                  ),
                ],

                const Gap(16),

                // 3. Contact Details
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
                    ),
                    if (displayCity.isNotEmpty)
                      ProfileInfoRow(
                        label: 'auth.city'.tr(),
                        value: displayCity,
                        showDivider: false,
                      ),
                  ],
                ),

                const Gap(16),

                // 4. System Settings & Info Content Links
                ProfileSectionCard(
                  title: 'profile.system_info'.tr(),
                  icon: Icons.settings_outlined,
                  children: const [
                    ProfileLanguageTile(),
                    ProfileInfoContentLinks(wrapInSectionCard: false),
                  ],
                ),

                const Gap(24),

                // 5. Logout Button
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
