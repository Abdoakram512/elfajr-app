import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../models/aid_card_model.dart';

class DigitalCardHeader extends StatelessWidget {
  final AidCardModel card;
  final VoidCallback onFlip;

  const DigitalCardHeader({
    super.key,
    required this.card,
    required this.onFlip,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Foundation Logo
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.accentLight, width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(19),
            child: Image.asset(
              AppImages.appLogo,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => const Icon(
                Icons.spa_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const Gap(10),
        // Foundation Titles
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'digital_card.foundation_name'.tr(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              Text(
                'digital_card.official_card'.tr(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        const Gap(8),
        // Status Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: card.isActive
                ? AppColors.emerald600.withValues(alpha: 0.25)
                : AppColors.warning.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: card.isActive ? const Color(0xFF34D399) : AppColors.warning,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      card.isActive ? const Color(0xFF34D399) : AppColors.warning,
                ),
              ),
              const Gap(5),
              Text(
                card.isActive
                    ? 'digital_card.status_active_short'.tr()
                    : 'digital_card.status_pending_short'.tr(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const Gap(6),
        // Flip Button
        IconButton(
          onPressed: onFlip,
          icon: const Icon(
            Icons.flip_to_back_rounded,
            color: Colors.white,
            size: 18,
          ),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            padding: const EdgeInsets.all(6),
            minimumSize: const Size(32, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }
}
