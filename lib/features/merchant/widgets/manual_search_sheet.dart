import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../view_models/redemption_cubit.dart';
import '../view_models/redemption_state.dart';
import 'beneficiary_card_summary.dart';
import 'redemption_receipt_card.dart';

class ManualSearchSheet extends StatefulWidget {
  final RedemptionCubit cubit;

  const ManualSearchSheet({super.key, required this.cubit});

  static Future<void> show(BuildContext context, RedemptionCubit cubit) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: ManualSearchSheet(cubit: cubit),
      ),
    );
  }

  @override
  State<ManualSearchSheet> createState() => _ManualSearchSheetState();
}

class _ManualSearchSheetState extends State<ManualSearchSheet> {
  final _searchController = TextEditingController();
  final _amountController = TextEditingController();
  final _pinController = TextEditingController();
  final _notesController = TextEditingController();
  bool _deductFoodBasket = false;

  @override
  void dispose() {
    _searchController.dispose();
    _amountController.dispose();
    _pinController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onSearch() {
    widget.cubit.searchCardManual(_searchController.text);
  }

  void _onConfirmRedemption() {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final baskets = _deductFoodBasket ? 1 : 0;

    widget.cubit.confirmRedemption(
      amount: amount,
      foodBaskets: baskets,
      enteredPin: _pinController.text,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );
  }

  void _onReset() {
    _searchController.clear();
    _amountController.clear();
    _pinController.clear();
    _notesController.clear();
    setState(() => _deductFoodBasket = false);
    widget.cubit.reset();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RedemptionCubit, RedemptionState>(
      builder: (context, state) {
        final isSuccess = state is RedemptionSuccess;
        final isSearching = state is RedemptionSearching;
        final isSubmitting = state is RedemptionSubmitting;
        final loadedCard = state is RedemptionCardLoaded
            ? state.card
            : (state is RedemptionSubmitting
                ? state.card
                : (state is RedemptionSuccess
                    ? state.card
                    : (state is RedemptionFailure ? state.card : null)));

        final pinError = state is RedemptionCardLoaded ? state.pinError : null;
        final searchError = state is RedemptionFailure && state.card == null
            ? state.errorMessage
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
                          isSuccess ? Icons.check_circle_rounded : Icons.person_search_rounded,
                          color: isSuccess ? AppColors.success : AppColors.primary,
                        ),
                        const Gap(8),
                        Text(
                          isSuccess
                              ? 'إيصال الصرف الموثق'
                              : (loadedCard == null
                                  ? 'merchant.search_manual_title'.tr()
                                  : 'merchant.beneficiary_details'.tr()),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                    if (loadedCard != null && !isSuccess)
                      TextButton.icon(
                        onPressed: _onReset,
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('بحث آخر'),
                      ),
                  ],
                ),

                const Gap(14),

                // CASE 1: Completed Transaction Receipt View
                if (state is RedemptionSuccess) ...[
                  RedemptionReceiptCard(
                    transaction: state.transaction,
                    card: state.card,
                    onNewRedemption: _onReset,
                    onDone: () => Navigator.pop(context),
                  ),
                ] else if (loadedCard == null) ...[
                  // CASE 2: Search Form
                  Text(
                    'إذا كان المستفيد لا يحمل هاتفاً ذكياً، أدخل رقم الهوية الوطنية (10 أرقام) أو رقم الكارت:',
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  const Gap(16),
                  CustomTextField(
                    controller: _searchController,
                    label: 'merchant.search_manual_label'.tr(),
                    hint: 'merchant.search_manual_hint'.tr(),
                    prefixIcon: Icons.badge_outlined,
                    keyboardType: TextInputType.text,
                    onSubmitted: (_) => _onSearch(),
                  ),
                  if (searchError != null) ...[
                    const Gap(8),
                    Text(
                      searchError.tr(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                  const Gap(20),
                  PrimaryButton(
                    text: 'common.search'.tr(),
                    isLoading: isSearching,
                    onPressed: _onSearch,
                  ),
                ] else ...[
                  // CASE 3: Card Found -> Summary + Deduction & In-Person PIN
                  BeneficiaryCardSummary(card: loadedCard),

                  const Gap(18),

                  CustomTextField(
                    controller: _amountController,
                    label: 'merchant.enter_deduction_amount'.tr(),
                    hint: '0.0',
                    prefixIcon: Icons.payments_outlined,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),

                  const Gap(12),

                  if (loadedCard.foodBasketsQuota > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primarySubtle,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.shopping_basket_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                          const Gap(12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'merchant.deduct_food_basket'.tr(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimaryLight,
                                  ),
                                ),
                                Text(
                                  'المتاح: ${loadedCard.foodBasketsQuota} سلة',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _deductFoodBasket,
                            activeThumbColor: AppColors.primary,
                            onChanged: (val) => setState(() => _deductFoodBasket = val),
                          ),
                        ],
                      ),
                    ),

                  const Gap(14),

                  // Anti-Fraud In-Person Security PIN
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

                  const Gap(18),

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
