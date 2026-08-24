import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../models/aid_card_model.dart';

class DigitalCardBeneficiaryDetails extends StatelessWidget {
  final AidCardModel card;

  const DigitalCardBeneficiaryDetails({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final cleanedNationalId = card.nationalId.replaceAll(RegExp(r'\s+'), '');
    final displayNat = card.nationality ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 1. Beneficiary Name & Expiry ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                card.beneficiaryName,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ),
            const Gap(8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${'digital_card.expires_at'.tr()}: ${AppFormatters.formatDate(card.expiresAt, context: context)}',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),
          ],
        ),

        const Gap(8),

        // ── 2. Badges (Social Status, Nationality, Family Count, Residence) ──
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            if (card.socialStatus != null || displayNat.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${card.socialStatus ?? ''}${card.socialStatus != null && displayNat.isNotEmpty ? ' • ' : ''}$displayNat',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accentLight,
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    AppIcons.family,
                    size: 12,
                    color: AppColors.accentLight,
                  ),
                  const Gap(4),
                  Text(
                    'digital_card.family_members_count'.tr(
                      namedArgs: {'count': '${card.familyCount}'},
                    ),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            if (card.residence != null && card.residence!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      AppIcons.location,
                      size: 12,
                      color: AppColors.accentLight,
                    ),
                    const Gap(4),
                    Text(
                      card.residence!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),

        const Gap(10),

        // ── 3. Clean Identifiers (Card ID + National ID) ──
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Card ID
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.accentLight.withValues(alpha: 0.3),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${'digital_card.card_id_prefix'.tr()} ',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  Text(
                    card.cardId,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      color: AppColors.accentLight,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            // National ID
            if (cleanedNationalId.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${'digital_card.national_id_prefix'.tr()} ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    Text(
                      cleanedNationalId,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
