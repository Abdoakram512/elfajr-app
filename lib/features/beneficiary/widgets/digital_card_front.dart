import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/card_printer_service.dart';
import '../../../../core/utils/nationality_formatter.dart';
import '../models/aid_card_model.dart';
import 'digital_card_enlarged_qr_dialog.dart';

class DigitalCardFront extends StatelessWidget {
  final AidCardModel card;
  final VoidCallback onFlip;

  const DigitalCardFront({
    super.key,
    required this.card,
    required this.onFlip,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,###');
    final dateFormatter = DateFormat('yyyy/MM/dd');
    final cleanedNationalId = card.nationalId.replaceAll(RegExp(r'\s+'), '');
    final displayNat = card.nationality.toMasculineNationality();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: App Logo + Foundation Name + Status Pill + Flip Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.accentLight.withValues(alpha: 0.9),
                          width: 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => const Icon(
                            Icons.spa_rounded,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const Gap(10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'digital_card.foundation_name'.tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'digital_card.official_card'.tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white30),
                ),
                child: Text(
                  card.isActive
                      ? 'digital_card.status_active'.tr()
                      : 'digital_card.status_pending'.tr(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Gap(6),
              IconButton(
                onPressed: onFlip,
                icon: const Icon(Icons.flip_to_back_rounded, color: Colors.white, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  padding: const EdgeInsets.all(6),
                  minimumSize: const Size(34, 34),
                ),
              ),
            ],
          ),

          const Gap(14),

          // Center: QR + Balances
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => DigitalCardEnlargedQrDialog.show(context, card),
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      QrImageView(
                        data: card.cardId,
                        version: QrVersions.auto,
                        size: 96,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: AppColors.primary,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const Gap(4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.fullscreen_rounded, size: 12, color: AppColors.primary),
                          const Gap(2),
                          Text(
                            'digital_card.tap_to_enlarge'.tr(),
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const Gap(16),

              // Balances Breakdown
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'digital_card.available_balance'.tr(),
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const Gap(2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              currencyFormatter.format(card.totalBalance),
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const Gap(5),
                        Text(
                          'common.currency'.tr(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentLight,
                          ),
                        ),
                      ],
                    ),
                    const Gap(8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.shopping_basket_rounded,
                            size: 14,
                            color: AppColors.accentLight,
                          ),
                        ),
                        const Gap(8),
                        Expanded(
                          child: Text(
                            '${card.foodBasketsQuota} ${'digital_card.baskets_unit'.tr()} ${'digital_card.food_baskets'.tr()}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Gap(14),
          const Divider(color: Colors.white24, height: 1),
          const Gap(10),

          // Footer: Name + Expiry + Badges
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      card.beneficiaryName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Gap(8),
                  Text(
                    '${'digital_card.expires_at'.tr()} ${dateFormatter.format(card.expiresAt)}',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),

              const Gap(6),

              // Badges
              Wrap(
                spacing: 6,
                runSpacing: 4,
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
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentLight,
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.people_alt_rounded, size: 12, color: AppColors.accentLight),
                        const Gap(4),
                        Text(
                          'digital_card.family_members_count'.tr(namedArgs: {'count': '${card.familyCount}'}),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
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
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_rounded, size: 12, color: AppColors.accentLight),
                          const Gap(4),
                          Text(
                            card.residence!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const Gap(10),

              // Card / National ID
              Row(
                children: [
                  Text(
                    '${'digital_card.card_number'.tr()}: ',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    card.cardId,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: AppColors.accentLight,
                      letterSpacing: 0.8,
                    ),
                  ),
                  if (cleanedNationalId.isNotEmpty) ...[
                    const Text('   •   ', style: TextStyle(color: Colors.white54)),
                    Text(
                      cleanedNationalId,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          const Gap(12),

          // Print Button Bar
          InkWell(
            onTap: () => CardPrinterService.printAidCard(card: card),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.28),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.print_rounded, color: Colors.white, size: 16),
                  const Gap(8),
                  Text(
                    'digital_card.print_card_button'.tr(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
