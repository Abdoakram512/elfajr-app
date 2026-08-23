import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/card_printer_service.dart';
import '../../../../core/utils/haptic_feedback_helper.dart';
import '../models/aid_card_model.dart';

class DigitalCardEnlargedQrDialog extends StatelessWidget {
  final AidCardModel card;

  const DigitalCardEnlargedQrDialog({super.key, required this.card});

  static Future<void> show(BuildContext context, AidCardModel card) {
    HapticHelper.light();
    return showDialog(
      context: context,
      builder: (ctx) => DigitalCardEnlargedQrDialog(card: card),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cleanedNationalId = card.nationalId.replaceAll(RegExp(r'\s+'), '');

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'digital_card.title'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Gap(12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderLight, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: QrImageView(
                data: card.cardId,
                version: QrVersions.auto,
                size: 240,
                gapless: false,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppColors.primary,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            const Gap(16),
            Text(
              card.cardId,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const Gap(4),
            Text(
              card.beneficiaryName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondaryLight,
              ),
            ),
            if (cleanedNationalId.isNotEmpty) ...[
              const Gap(4),
              Text(
                '${'digital_card.national_id_label'.tr()}: $cleanedNationalId',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
            const Gap(16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticHelper.medium();
                      Navigator.pop(context);
                      CardPrinterService.printAidCard(card: card);
                    },
                    icon: const Icon(Icons.print_rounded, size: 18),
                    label: Text(
                      'digital_card.print_card_button'.tr(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticHelper.light();
                      Navigator.pop(context);
                      CardPrinterService.shareAidCard(card: card);
                    },
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: Text(
                      'digital_card.share_save_button'.tr(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
