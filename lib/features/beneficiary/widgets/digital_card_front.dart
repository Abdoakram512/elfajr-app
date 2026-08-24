import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/aid_card_model.dart';
import 'digital_card/digital_card_balance_and_qr_section.dart';
import 'digital_card/digital_card_beneficiary_details.dart';
import 'digital_card/digital_card_header.dart';
import 'digital_card/digital_card_print_button.dart';

class DigitalCardFront extends StatelessWidget {
  final AidCardModel card;
  final VoidCallback onFlip;

  const DigitalCardFront({super.key, required this.card, required this.onFlip});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── 1. Top Header Row (Logo + Foundation + Status Pill + Flip) ──
          DigitalCardHeader(card: card, onFlip: onFlip),

          const Gap(14),

          // ── 2. Middle Row: Balances on Left, Scannable QR on Right ──
          DigitalCardBalanceAndQrSection(card: card),

          const Gap(14),
          const Divider(color: Colors.white24, height: 1),
          const Gap(10),

          // ── 3. Beneficiary Details & Badges ──
          DigitalCardBeneficiaryDetails(card: card),

          const Gap(12),

          // ── 4. Print Card Action Button ──
          DigitalCardPrintButton(card: card),
        ],
      ),
    );
  }
}
