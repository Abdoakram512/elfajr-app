import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../beneficiary/models/aid_card_model.dart';
import 'enlarged_qr_dialog.dart';

class BeneficiaryCardSummary extends StatelessWidget {
  final AidCardModel card;

  const BeneficiaryCardSummary({super.key, required this.card});

  String _getMaskedNationalId(String natId) {
    if (natId.length <= 4) return natId;
    return '******${natId.substring(natId.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,###');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header: Beneficiary Name + Status Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.beneficiaryName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    if (card.socialStatus != null || card.nationality != null) ...[
                      const Gap(4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${card.socialStatus ?? ''}${card.socialStatus != null && card.nationality != null ? ' • ' : ''}${card.nationality == 'مصرية' ? 'مصري' : (card.nationality == 'سورية' ? 'سوري' : (card.nationality == 'سودانية' ? 'سوداني' : (card.nationality == 'يمنية' ? 'يمني' : (card.nationality == 'فلسطينية' ? 'فلسطيني' : (card.nationality == 'أردنية' ? 'أردني' : (card.nationality == 'عراقية' ? 'عراقي' : (card.nationality == 'لبنانية' ? 'لبناني' : (card.nationality ?? ''))))))))}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentLight,
                          ),
                        ),
                      ),
                    ],
                    const Gap(4),
                    Text(
                      '${'merchant.national_id'.tr()}: ${_getMaskedNationalId(card.nationalId)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.2),
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
            ],
          ),

          const Gap(14),
          const Divider(color: Colors.white24, height: 1),
          const Gap(14),

          // Center: Interactive QR Code + Balances Breakdown
          Row(
            children: [
              // Interactive QR Code Box
              GestureDetector(
                onTap: () => EnlargedQrDialog.show(context, card),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      QrImageView(
                        data: card.cardId,
                        version: QrVersions.auto,
                        size: 78,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: AppColors.primary,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const Gap(2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.fullscreen_rounded,
                            size: 11,
                            color: AppColors.primary,
                          ),
                          const Gap(2),
                          Text(
                            'digital_card.tap_to_enlarge'.tr(),
                            style: const TextStyle(
                              fontSize: 8.5,
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

              const Gap(14),

              // Balances Breakdown
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'digital_card.available_balance'.tr(),
                            style: TextStyle(
                              fontSize: 10.5,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          const Gap(2),
                          Text(
                            '${currencyFormatter.format(card.totalBalance)} ${'common.currency'.tr()}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.accentLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'digital_card.food_baskets'.tr(),
                            style: TextStyle(
                              fontSize: 10.5,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          const Gap(2),
                          Text(
                            '${card.foodBasketsQuota} ${'digital_card.baskets_unit'.tr()}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms);
  }
}
