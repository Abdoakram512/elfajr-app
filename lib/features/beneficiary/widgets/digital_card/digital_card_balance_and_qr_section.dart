import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../models/aid_card_model.dart';
import '../digital_card_enlarged_qr_dialog.dart';

class DigitalCardBalanceAndQrSection extends StatelessWidget {
  final AidCardModel card;

  const DigitalCardBalanceAndQrSection({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,###');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Balance Breakdown (Takes available space)
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'digital_card.available_balance'.tr(),
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const Gap(2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        currencyFormatter.format(card.totalBalance),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        'common.currency'.tr(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.accentLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(8),
                // Food Baskets Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        AppIcons.basket,
                        size: 13,
                        color: AppColors.accentLight,
                      ),
                      const Gap(5),
                      Flexible(
                        child: Text(
                          '${card.foodBasketsQuota} ${'digital_card.baskets_unit'.tr()} سلال غذائية',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const Gap(12),

        // QR Code Box (Fixed Compact Size)
        GestureDetector(
          onTap: () => DigitalCardEnlargedQrDialog.show(context, card),
          child: Container(
            width: 96,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
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
                  size: 84,
                  padding: EdgeInsets.zero,
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.fullscreen_rounded,
                      size: 12,
                      color: AppColors.primary,
                    ),
                    const Gap(2),
                    Text(
                      'digital_card.tap_to_enlarge_short'.tr(),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
