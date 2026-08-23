import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../beneficiary/models/aid_card_model.dart';
import '../view_models/redemption_cubit.dart';
import '../view_models/redemption_state.dart';
import 'beneficiary_card_summary.dart';
import 'redemption_receipt_card.dart';

class RedemptionConfirmationSheet extends StatefulWidget {
  final AidCardModel card;

  const RedemptionConfirmationSheet({
    super.key,
    required this.card,
  });

  @override
  State<RedemptionConfirmationSheet> createState() =>
      _RedemptionConfirmationSheetState();
}

class _RedemptionConfirmationSheetState
    extends State<RedemptionConfirmationSheet> {
  final _amountController = TextEditingController(text: '30');
  final _pinController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Default to 30 EGP automatically as per organization policy
    _amountController.text = '30';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _pinController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onConfirmRedemption() {
    final amount = double.tryParse(_amountController.text.trim()) ?? 30.0;

    context.read<RedemptionCubit>().confirmRedemption(
      amount: amount,
      foodBaskets: 0,
      enteredPin: _pinController.text,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RedemptionCubit, RedemptionState>(
      builder: (context, state) {
        final isSuccess = state is RedemptionSuccess;
        final isSubmitting = state is RedemptionSubmitting;
        final pinError = state is RedemptionCardLoaded ? state.pinError : null;
        final amountError = state is RedemptionCardLoaded ? state.amountError : null;

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
                    Row(
                      children: [
                        Icon(
                          isSuccess ? Icons.check_circle_rounded : Icons.person_rounded,
                          color: isSuccess ? AppColors.success : AppColors.primary,
                        ),
                        const Gap(8),
                        Text(
                          isSuccess
                              ? 'إيصال الصرف الموثق'
                              : 'merchant.beneficiary_details'.tr(),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isSuccess
                            ? AppColors.success.withValues(alpha: 0.15)
                            : AppColors.primarySubtle,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.security_rounded,
                            size: 13,
                            color: isSuccess ? AppColors.success : AppColors.primary,
                          ),
                          const Gap(4),
                          Text(
                            isSuccess ? 'عملية مكتملة وموثقة' : 'صرف آمن موثق',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isSuccess ? AppColors.success : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Gap(14),

                // CASE 1: Completed Transaction Receipt View
                if (state is RedemptionSuccess) ...[
                  RedemptionReceiptCard(
                    transaction: state.transaction,
                    card: state.card,
                    onDone: () => Navigator.pop(context),
                  ),
                ] else ...[
                  // CASE 2: Beneficiary Card Summary
                  BeneficiaryCardSummary(card: widget.card),

                  // Automatic Fixed Amount Policy Banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          color: Color(0xFF059669),
                          size: 18,
                        ),
                        const Gap(8),
                        Expanded(
                          child: Text(
                            'merchant.fixed_amount_badge'.tr(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF065F46),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(10),

                  CustomTextField(
                    controller: _amountController,
                    label: 'merchant.enter_deduction_amount'.tr(),
                    hint: '30.0',
                    prefixIcon: Icons.payments_outlined,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  if (amountError != null) ...[
                    const Gap(6),
                    Text(
                      amountError.tr(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                  ],

                  const Gap(14),

                  // Anti-Fraud In-Person Security PIN Check
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: pinError != null ? AppColors.error : AppColors.borderLight,
                        width: pinError != null ? 1.5 : 1.0,
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
                        ),
                        if (pinError != null) ...[
                          const Gap(6),
                          Text(
                            pinError.tr(),
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

                  CustomTextField(
                    controller: _notesController,
                    label: 'merchant.notes_label'.tr(),
                    hint: 'merchant.notes_hint'.tr(),
                    prefixIcon: Icons.notes_rounded,
                  ),

                  const Gap(16),

                  PrimaryButton(
                    text: 'merchant.confirm_redemption'.tr(),
                    isLoading: isSubmitting,
                    onPressed: _onConfirmRedemption,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
