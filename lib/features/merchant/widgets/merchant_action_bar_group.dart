import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../app/service_locator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/haptic_feedback_helper.dart';
import '../../auth/models/user_model.dart';
import '../view_models/redemption_cubit.dart';
import 'extra_disbursement_request_sheet.dart';
import 'manual_search_sheet.dart';

class MerchantActionBarGroup extends StatelessWidget {
  final UserModel? merchant;

  const MerchantActionBarGroup({super.key, this.merchant});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Manual Search Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () {
              HapticHelper.light();
              final cubit = getIt<RedemptionCubit>();
              ManualSearchSheet.show(context, cubit);
            },
            style: OutlinedButton.styleFrom(
              alignment: Alignment.center,
              backgroundColor: Colors.white,
              padding: EdgeInsets.zero,
              side: const BorderSide(color: AppColors.borderLight, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                const Gap(8),
                Text(
                  'dashboard.merchant.manual_search'.tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. Extra Disbursement Request Button
        if (merchant != null) ...[
          const Gap(12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) =>
                      ExtraDisbursementRequestSheet(merchant: merchant!),
                );
              },
              style: OutlinedButton.styleFrom(
                alignment: Alignment.center,
                backgroundColor: const Color(0xFFFFFBEB),
                padding: EdgeInsets.zero,
                side: const BorderSide(color: Color(0xFFFDE68A), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_alert_rounded,
                    color: Color(0xFFD97706),
                    size: 20,
                  ),
                  const Gap(8),
                  Text(
                    'dashboard.merchant.request_extra_disbursement'.tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
