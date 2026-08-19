import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../../../app/service_locator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/card_printer_service.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../beneficiary/models/aid_card_model.dart';
import '../repositories/merchant_repository.dart';
import '../view_models/merchant_cubit.dart';

class ManualSearchSheet extends StatefulWidget {
  final MerchantCubit cubit;

  const ManualSearchSheet({super.key, required this.cubit});

  static Future<void> show(BuildContext context, MerchantCubit cubit) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => ManualSearchSheet(cubit: cubit),
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

  bool _isSearching = false;
  String? _searchError;
  String? _pinError;
  AidCardModel? _foundCard;
  bool _deductFoodBasket = false;

  @override
  void dispose() {
    _searchController.dispose();
    _amountController.dispose();
    _pinController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _getMaskedNationalId(String natId) {
    if (natId.length <= 4) return natId;
    return '******${natId.substring(natId.length - 4)}';
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() => _searchError = 'يرجى إدخال رقم الهوية الوطنية أو رقم الكارت');
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      final repo = sl<MerchantRepository>();
      final card = await repo.searchCardByIdOrNationalId(query);

      if (!mounted) return;

      if (card != null) {
        setState(() {
          _isSearching = false;
          _foundCard = card;
          _searchError = null;
        });
      } else {
        setState(() {
          _isSearching = false;
          _searchError = 'لم يتم العثور على أي كارت برقم الهوية أو الكارت المدخل';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _searchError = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  void _confirmRedemption() {
    if (_foundCard == null) return;

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
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
    final actualLast4 = _foundCard!.nationalId.length >= 4
        ? _foundCard!.nationalId.substring(_foundCard!.nationalId.length - 4)
        : _foundCard!.nationalId;

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

    Navigator.pop(context);
    widget.cubit.redeemAid(
      amount: amount,
      foodBaskets: baskets,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
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
                Row(
                  children: [
                    const Icon(Icons.person_search_rounded, color: AppColors.primary),
                    const Gap(8),
                    Text(
                      _foundCard == null
                          ? 'merchant.search_manual_title'.tr()
                          : 'merchant.beneficiary_details'.tr(),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                if (_foundCard != null)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _foundCard = null;
                        _pinError = null;
                        _pinController.clear();
                        _amountController.clear();
                      });
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('بحث آخر'),
                  ),
              ],
            ),

            const Gap(14),

            // Step 1: Search Form (if no card selected yet)
            if (_foundCard == null) ...[
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
                onSubmitted: (_) => _performSearch(),
              ),
              if (_searchError != null) ...[
                const Gap(8),
                Text(
                  _searchError!,
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
                isLoading: _isSearching,
                onPressed: _performSearch,
              ),
            ] else ...[
              // Step 2: Card Found -> Full Beneficiary Verification & Deduction Details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _foundCard!.beneficiaryName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Gap(4),
                            Text(
                              '${'merchant.national_id'.tr()}: ${_getMaskedNationalId(_foundCard!.nationalId)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white30),
                          ),
                          child: Text(
                            _foundCard!.isActive
                                ? 'digital_card.status_active'.tr()
                                : 'digital_card.status_pending'.tr(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(14),
                    const Divider(color: Colors.white24, height: 1),
                    const Gap(14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              'digital_card.available_balance'.tr(),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            const Gap(2),
                            Text(
                              '${currencyFormatter.format(_foundCard!.totalBalance)} ${'common.currency'.tr()}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColors.accentLight,
                              ),
                            ),
                          ],
                        ),
                        Container(width: 1, height: 30, color: Colors.white24),
                        Column(
                          children: [
                            Text(
                              'digital_card.food_baskets'.tr(),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            const Gap(2),
                            Text(
                              '${_foundCard!.foodBasketsQuota} ${'digital_card.baskets_unit'.tr()}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 250.ms),

              const Gap(18),

              // Deduction Input
              CustomTextField(
                controller: _amountController,
                label: 'merchant.enter_deduction_amount'.tr(),
                hint: '0.0',
                prefixIcon: Icons.payments_outlined,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),

              const Gap(12),

              // Food Basket Toggle
              if (_foundCard!.foodBasketsQuota > 0)
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
                              'المتاح: ${_foundCard!.foodBasketsQuota} سلة',
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

              // In-Person Anti-Fraud Security PIN
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _pinError != null ? AppColors.error : AppColors.borderLight,
                    width: _pinError != null ? 1.5 : 1.0,
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

              const Gap(18),

              // Action Buttons: Confirm & Print
              PrimaryButton(
                text: 'merchant.confirm_redemption'.tr(),
                onPressed: _confirmRedemption,
              ),

              const Gap(10),

              // Print Physical Aid Card Button
              OutlinedButton.icon(
                onPressed: () => CardPrinterService.printAidCard(card: _foundCard!),
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
          ],
        ),
      ),
    );
  }
}
