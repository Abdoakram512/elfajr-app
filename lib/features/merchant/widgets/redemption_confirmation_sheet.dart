import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
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
  final _notesController = TextEditingController();
  bool _deductFoodBasket = false;

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
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
          Text(
            'merchant.beneficiary_details'.tr(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
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
                      '${'merchant.national_id'.tr()}: ${widget.card.nationalId}',
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

          // Notes Input
          CustomTextField(
            controller: _notesController,
            label: 'ملاحظات الصرف (اختياري)',
            hint: 'مثال: مشتريات تموينية شهرية',
            prefixIcon: Icons.notes_rounded,
          ),

          const Gap(22),

          // Confirm Button
          PrimaryButton(
            text: 'merchant.confirm_redemption'.tr(),
            onPressed: () {
              final amount =
                  double.tryParse(_amountController.text.trim()) ?? 0.0;
              final baskets = _deductFoodBasket ? 1 : 0;

              if (amount > 0 || baskets > 0) {
                widget.onConfirm(
                  amount,
                  baskets,
                  _notesController.text.trim().isEmpty
                      ? null
                      : _notesController.text.trim(),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
