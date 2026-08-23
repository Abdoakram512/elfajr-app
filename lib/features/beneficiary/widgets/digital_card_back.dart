import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/aid_card_model.dart';
import 'digital_card_enlarged_qr_dialog.dart';

class DigitalCardBack extends StatelessWidget {
  final AidCardModel card;
  final VoidCallback onFlip;

  const DigitalCardBack({
    super.key,
    required this.card,
    required this.onFlip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.verified_user_rounded, color: AppColors.accentLight, size: 20),
                  const Gap(8),
                  Text(
                    'digital_card.usage_instructions_title'.tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: onFlip,
                icon: const Icon(Icons.flip_to_front_rounded, color: Colors.white, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  padding: const EdgeInsets.all(6),
                  minimumSize: const Size(34, 34),
                ),
              ),
            ],
          ),
          const Gap(12),
          _buildInstructionRow('1', 'digital_card.instruction_1'.tr()),
          const Gap(8),
          _buildInstructionRow('2', 'digital_card.instruction_2'.tr()),
          const Gap(8),
          _buildInstructionRow('3', 'digital_card.instruction_3'.tr()),
          const Gap(16),
          const Divider(color: Colors.white12, height: 1),
          const Gap(12),
          Center(
            child: GestureDetector(
              onTap: () => DigitalCardEnlargedQrDialog.show(context, card),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: QrImageView(
                  data: card.cardId,
                  version: QrVersions.auto,
                  size: 64,
                  eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                ),
              ),
            ),
          ),
          const Gap(6),
          Center(
            child: Text(
              card.cardId,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionRow(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.accentLight,
            ),
          ),
        ),
        const Gap(10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 11.5,
              color: Colors.white70,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
