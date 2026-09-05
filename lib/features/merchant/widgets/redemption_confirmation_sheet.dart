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

  const RedemptionConfirmationSheet({super.key, required this.card});

  @override
  State<RedemptionConfirmationSheet> createState() =>
      _RedemptionConfirmationSheetState();
}

class _RedemptionConfirmationSheetState
    extends State<RedemptionConfirmationSheet> {
  final _notesController = TextEditingController();

  static const double _fixedRedemptionAmount = 30.0;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _onConfirmRedemption() {
    context.read<RedemptionCubit>().confirmRedemption(
      amount: _fixedRedemptionAmount,
      foodBaskets: 0,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RedemptionCubit, RedemptionState>(
      builder: (context, state) {
        final isSuccess = state is RedemptionSuccess;
        final isSubmitting = state is RedemptionSubmitting;
        final amountError = state is RedemptionCardLoaded
            ? state.amountError
            : null;

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
                          isSuccess
                              ? Icons.check_circle_rounded
                              : Icons.person_rounded,
                          color: isSuccess
                              ? AppColors.success
                              : AppColors.primary,
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
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
                            color: isSuccess
                                ? AppColors.success
                                : AppColors.primary,
                          ),
                          const Gap(4),
                          Text(
                            isSuccess ? 'عملية مكتملة وموثقة' : 'صرف آمن موثق',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isSuccess
                                  ? AppColors.success
                                  : AppColors.primary,
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
                  const Gap(14),

                  // Fixed 30 EGP Amount Card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFBBF7D0), width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0A734D).withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.payments_rounded,
                                color: Color(0xFF0A734D),
                                size: 22,
                              ),
                            ),
                            const Gap(12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'merchant.fixed_amount_label'.tr(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF14532D),
                                  ),
                                ),
                                Text(
                                  'merchant.fixed_amount_desc'.tr(),
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF166534),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A734D),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                '30.00',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              const Gap(4),
                              Text(
                                'common.currency'.tr(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (amountError != null) ...[
                    const Gap(8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
                          const Gap(8),
                          Expanded(
                            child: Text(
                              amountError.tr(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const Gap(14),

                  CustomTextField(
                    controller: _notesController,
                    label: 'merchant.notes_label'.tr(),
                    hint: 'merchant.notes_hint'.tr(),
                    prefixIcon: Icons.notes_rounded,
                  ),

                  const Gap(18),

                  PrimaryButton(
                    text: 'merchant.confirm_redemption_fixed'.tr(),
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
