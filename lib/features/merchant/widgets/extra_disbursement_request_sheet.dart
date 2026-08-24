import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../app/service_locator.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/models/user_model.dart';
import '../models/extra_disbursement_request_model.dart';
import '../repositories/merchant_repository.dart';

class ExtraDisbursementRequestSheet extends StatefulWidget {
  final UserModel merchant;
  final String? initialCardId;

  const ExtraDisbursementRequestSheet({
    super.key,
    required this.merchant,
    this.initialCardId,
  });

  @override
  State<ExtraDisbursementRequestSheet> createState() => _ExtraDisbursementRequestSheetState();
}

class _ExtraDisbursementRequestSheetState extends State<ExtraDisbursementRequestSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _cardIdController;
  final _amountController = TextEditingController(text: '500');
  final _reasonController = TextEditingController();
  
  bool _isSubmitting = false;
  String? _requestId;
  String? _currentStatus; // 'pending', 'approved', 'rejected'

  @override
  void initState() {
    super.initState();
    _cardIdController = TextEditingController(text: widget.initialCardId ?? '');
  }

  @override
  void dispose() {
    _cardIdController.dispose();
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final reqId = 'EX-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      final request = ExtraDisbursementRequestModel(
        requestId: reqId,
        merchantId: widget.merchant.uid,
        merchantStoreName: widget.merchant.storeName ?? widget.merchant.name,
        cardId: _cardIdController.text.trim().toUpperCase(),
        beneficiaryId: '',
        beneficiaryName: 'مستفيد بطاقة ${_cardIdController.text.trim().toUpperCase()}',
        requestedAmount: double.tryParse(_amountController.text.trim()) ?? 500,
        reason: _reasonController.text.trim(),
        status: DisbursementRequestStatus.pending,
        timestamp: DateTime.now(),
      );

      await getIt<MerchantRepository>().submitExtraDisbursementRequest(request);

      if (mounted) {
        setState(() {
          _requestId = reqId;
          _currentStatus = 'pending';
          _isSubmitting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('merchant.extra_disbursement_ext.error_sending'.tr(namedArgs: {'error': '$e'}))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Handle
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

            // Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.emergency_outlined,
                    color: AppColors.accent,
                    size: 24,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'extra_disbursement.title'.tr(),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        'extra_disbursement.subtitle'.tr(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(20),

            if (_requestId != null) ...[
              // Live Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _currentStatus == 'approved'
                      ? AppColors.primarySubtle
                      : _currentStatus == 'rejected'
                          ? AppColors.error.withValues(alpha: 0.1)
                          : Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _currentStatus == 'approved'
                        ? AppColors.primary
                        : _currentStatus == 'rejected'
                            ? AppColors.error
                            : Colors.amber,
                    width: 1.2,
                  ),
                ),
                child: Column(
                  children: [
                    if (_currentStatus == 'pending') ...[
                      const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                      const Gap(12),
                      Text(
                        'extra_disbursement.waiting_approval'.tr(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        'merchant.extra_disbursement_ext.sent_to_admin'.tr(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                      ),
                    ] else if (_currentStatus == 'approved') ...[
                      const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 36),
                      const Gap(10),
                      Text(
                        'extra_disbursement.approved'.tr(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                      const Gap(14),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Center(
                          child: Text(
                            'merchant.extra_disbursement_ext.confirm_handover'.tr(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ] else if (_currentStatus == 'rejected') ...[
                      const Icon(Icons.cancel_rounded, color: AppColors.error, size: 36),
                      const Gap(10),
                      Text(
                        'extra_disbursement.rejected'.tr(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ] else ...[
              // Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _cardIdController,
                      decoration: InputDecoration(
                        labelText: 'extra_disbursement.card_id'.tr(),
                        prefixIcon: const Icon(Icons.credit_card),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'merchant.extra_disbursement_ext.card_id_required'.tr() : null,
                    ),
                    const Gap(14),

                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'extra_disbursement.amount'.tr(),
                        prefixIcon: const Icon(Icons.attach_money),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'merchant.extra_disbursement_ext.amount_required'.tr() : null,
                    ),
                    const Gap(14),

                    TextFormField(
                      controller: _reasonController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'extra_disbursement.reason'.tr(),
                        hintText: 'extra_disbursement.reason_hint'.tr(),
                        prefixIcon: const Icon(Icons.note_alt_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'merchant.extra_disbursement_ext.reason_required'.tr() : null,
                    ),
                    const Gap(20),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          elevation: 2,
                          shadowColor: AppColors.primary.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Center(
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  'extra_disbursement.submit'.tr(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
