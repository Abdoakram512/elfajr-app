import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/services/card_printer_service.dart';
import '../../models/aid_card_model.dart';

class DigitalCardPrintButton extends StatelessWidget {
  final AidCardModel card;

  const DigitalCardPrintButton({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => CardPrinterService.printAidCard(card: card),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              AppIcons.print,
              color: Colors.white,
              size: 16,
            ),
            const Gap(8),
            Text(
              'digital_card.print_card_button'.tr(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
