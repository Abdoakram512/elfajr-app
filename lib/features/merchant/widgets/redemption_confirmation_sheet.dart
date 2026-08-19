import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/card_printer_service.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../beneficiary/models/aid_card_model.dart';

class RedemptionConfirmationSheet extends StatefulWidget {
  final AidCardModel card;
  final void Function(double amount, int foodBaskets, String? notes) onConfirm;

  const RedemptionConfirmationSheet({
    super.key,
    required this.card,
    required this.onConfirm,
  });

  @override
  State<RedemptionConfirmationSheet> createState() =>
      _RedemptionConfirmationSheetState();
}

class _RedemptionConfirmationSheetState
    extends State<RedemptionConfirmationSheet> {
  final _amountController = TextEditingController();
  final _pinController = TextEditingController();
  final _notesController = TextEditingController();
  bool _deductFoodBasket = false;
  String? _pinError;

  @override
  void dispose() {
    _amountController.dispose();
    _pinController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _getMaskedNationalId(String natId) {
    if (natId.length <= 4) return natId;
    return '******${natId.substring(natId.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,###');

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Gap(16),

            // Header Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'merchant.beneficiary_details'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.security_rounded, size: 13, color: AppColors.primary),
                      Gap(4),
                      Text(
                        'صرف آمن موثق',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Gap(14),

            // Beneficiary Info & Balance Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primarySubtle,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.card.beneficiaryName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'digital_card.status_active'.tr(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${'merchant.national_id'.tr()}: ${_getMaskedNationalId(widget.card.nationalId)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      Text(
                        '${widget.card.familyCount} ${'digital_card.persons'.tr()}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 18, color: Colors.black12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'digital_card.available_balance'.tr(),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                          Text(
                            '${currencyFormatter.format(widget.card.totalBalance)} ${'common.currency'.tr()}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'digital_card.food_baskets'.tr(),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                          Text(
                            '${widget.card.foodBasketsQuota} ${'digital_card.baskets_unit'.tr()}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Gap(16),

            // Amount to Deduct Input
            CustomTextField(
              controller: _amountController,
              label: 'merchant.enter_deduction_amount'.tr(),
              hint: '0.00',
              prefixIcon: Icons.payments_outlined,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),

            const Gap(12),

            // Food Basket checkbox if available
            if (widget.card.foodBasketsQuota > 0)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                title: Text(
                  'merchant.deduct_food_basket'.tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                value: _deductFoodBasket,
                onChanged: (val) {
                  setState(() {
                    _deductFoodBasket = val ?? false;
                  });
                },
              ),

            const Gap(12),

            // Security Anti-Fraud Verification: Last 4 digits of National ID
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _pinError != null ? AppColors.error : AppColors.borderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_user_rounded, size: 16, color: AppColors.primary),
                      const Gap(6),
                      Text(
                        'merchant.security_verification_title'.tr(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  const Gap(6),
                  Text(
                    'merchant.security_verification_desc'.tr(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondaryLight,
                      height: 1.3,
                    ),
                  ),
                  const Gap(8),
                  CustomTextField(
                    controller: _pinController,
                    label: 'merchant.security_pin_label'.tr(),
                    hint: 'merchant.security_pin_hint'.tr(),
                    prefixIcon: Icons.pin_outlined,
                    keyboardType: TextInputType.number,
                    onChanged: (_) {
                      if (_pinError != null) {
                        setState(() => _pinError = null);
                      }
                    },
                  ),
                  if (_pinError != null) ...[
                    const Gap(6),
                    Text(
                      _pinError!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const Gap(12),

            // Notes Input
            CustomTextField(
              controller: _notesController,
              label: 'merchant.notes_label'.tr(),
              hint: 'merchant.notes_hint'.tr(),
              prefixIcon: Icons.notes_rounded,
            ),

            const Gap(16),

            // Action Buttons: Confirm & Print
            PrimaryButton(
              text: 'merchant.confirm_redemption'.tr(),
              onPressed: () {
                final amount =
                    double.tryParse(_amountController.text.trim()) ?? 0.0;
                final baskets = _deductFoodBasket ? 1 : 0;

                if (amount <= 0 && baskets <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('merchant.enter_deduction_amount'.tr()),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                // Security Check: Match last 4 digits of National ID
                final enteredPin = _pinController.text.trim();
                final actualLast4 = widget.card.nationalId.length >= 4
                    ? widget.card.nationalId.substring(widget.card.nationalId.length - 4)
                    : widget.card.nationalId;

                if (enteredPin.isEmpty) {
                  setState(() {
                    _pinError = 'merchant.security_pin_error_empty'.tr();
                  });
                  return;
                }

                if (enteredPin != actualLast4) {
                  setState(() {
                    _pinError = 'merchant.security_pin_error_mismatch'.tr();
                  });
                  return;
                }

                widget.onConfirm(
                  amount,
                  baskets,
                  _notesController.text.trim().isEmpty
                      ? null
                      : _notesController.text.trim(),
                );
              },
            ),

            const Gap(10),

            // Print Physical Aid Card Button
            OutlinedButton.icon(
              onPressed: () => CardPrinterService.printAidCard(card: widget.card),
              icon: const Icon(Icons.print_rounded, size: 18, color: AppColors.primary),
              label: Text(
                'merchant.print_paper_card_button'.tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.primary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
