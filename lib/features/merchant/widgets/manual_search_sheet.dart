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
import 'quota_exhausted_view.dart';
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
  final _notesController = TextEditingController();

  static const double _fixedRedemptionAmount = 30.0;

  @override
  void dispose() {
    _searchController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onSearch() {
    widget.cubit.searchCardManual(_searchController.text);
  }

  void _onConfirmRedemption() {
    widget.cubit.confirmRedemption(
      amount: _fixedRedemptionAmount,
      foodBaskets: 0,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );
  }

  void _onReset() {
    _searchController.clear();
    _notesController.clear();
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

        final isExhausted = loadedCard != null &&
            (loadedCard.hasRedeemedInCurrentMonth ||
                loadedCard.totalBalance < _fixedRedemptionAmount);

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
                          isSuccess
                              ? Icons.check_circle_rounded
                              : (isExhausted
                                  ? Icons.event_busy_rounded
                                  : (loadedCard == null
                                      ? Icons.person_search_rounded
                                      : Icons.person_rounded)),
                          color: isSuccess
                              ? AppColors.success
                              : (isExhausted
                                  ? const Color(0xFFD97706)
                                  : AppColors.primary),
                        ),
                        const Gap(8),
                        Text(
                          isSuccess
                              ? 'merchant.manual_search_ext.verified_receipt'.tr()
                              : (loadedCard == null
                                  ? 'merchant.search_manual_title'.tr()
                                  : (isExhausted
                                      ? 'merchant.quota_exhausted_title'.tr()
                                      : 'merchant.beneficiary_details'.tr())),
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
                        label: Text('merchant.manual_search_ext.another_search'.tr()),
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
                    'merchant.manual_search_ext.search_guidance'.tr(),
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
                ] else if (isExhausted) ...[
                  // CASE 3: Monthly Quota Already Redeemed / Exhausted
                  QuotaExhaustedView(
                    card: loadedCard,
                    onClose: () => Navigator.pop(context),
                    onSearchAnother: _onReset,
                  ),
                ] else ...[
                  // CASE 4: Active Card Found -> Summary + Fixed 30 EGP Redemption
                  BeneficiaryCardSummary(card: loadedCard),
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

                  if (state is RedemptionCardLoaded && state.amountError != null) ...[
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
                              state.amountError!.tr(),
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
