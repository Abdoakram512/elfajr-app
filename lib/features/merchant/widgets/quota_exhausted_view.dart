import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../beneficiary/models/aid_card_model.dart';
import 'beneficiary_card_summary.dart';

class QuotaExhaustedView extends StatelessWidget {
  final AidCardModel card;
  final VoidCallback onClose;
  final VoidCallback? onSearchAnother;

  const QuotaExhaustedView({
    super.key,
    required this.card,
    required this.onClose,
    this.onSearchAnother,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final nextMonthDate = DateTime(now.year, now.month + 1, 1);
    final nextMonthName = DateFormat('MMMM yyyy', context.locale.languageCode).format(nextMonthDate);
    final lastRedemptionFormatted = card.lastCashRedemptionDate != null
        ? DateFormat('dd MMMM yyyy - hh:mm a', context.locale.languageCode).format(card.lastCashRedemptionDate!)
        : 'تم الصرف خلال هذا الشهر';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── 1. Quota Exhausted Warning Alert ──────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.event_busy_rounded,
                  color: Color(0xFFD97706),
                  size: 22,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'merchant.quota_exhausted_title'.tr(),
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF92400E),
                      ),
                    ),
                    const Gap(3),
                    Text(
                      'merchant.quota_exhausted_desc'.tr(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFB45309),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Gap(14),

        // ── 2. Beneficiary Identity Card ──────────────────────────────────
        BeneficiaryCardSummary(card: card),
        const Gap(14),

        // ── 3. Redemption History & Next Renewal Details ───────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Previous Redemption Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.history_rounded, size: 16, color: Color(0xFF64748B)),
                      const Gap(6),
                      Text(
                        'merchant.last_redemption_date_label'.tr(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    lastRedemptionFormatted,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20, color: Color(0xFFF1F5F9)),

              // Current Balance
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined, size: 16, color: Color(0xFF64748B)),
                      const Gap(6),
                      Text(
                        'dashboard.merchant.remaining_liquidity'.tr(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '0.00 ${'common.currency'.tr()}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20, color: Color(0xFFF1F5F9)),

              // Next Renewal Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.restart_alt_rounded, size: 16, color: Color(0xFF0A734D)),
                      const Gap(6),
                      Text(
                        'merchant.next_quota_renewal_label'.tr(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0A734D),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF86EFAC)),
                    ),
                    child: Text(
                      '1 $nextMonthName',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF166534),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Gap(12),

        // ── 4. Policy Notice ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: AppColors.textSecondaryLight,
              ),
              const Gap(6),
              Expanded(
                child: Text(
                  'merchant.quota_policy_notice'.tr(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondaryLight,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Gap(18),

        // ── 5. Action Buttons ─────────────────────────────────────────────
        PrimaryButton(
          text: 'merchant.close_and_return_scanner'.tr(),
          onPressed: onClose,
        ),

        if (onSearchAnother != null) ...[
          const Gap(10),
          Center(
            child: TextButton(
              onPressed: onSearchAnother,
              child: Text(
                'merchant.manual_search_ext.another_search'.tr(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A734D),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
