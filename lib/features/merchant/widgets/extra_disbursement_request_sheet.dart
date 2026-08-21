import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:qout/core/theme/app_colors.dart';
import 'package:qout/features/auth/models/user_model.dart';

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
      final docRef = FirebaseFirestore.instance.collection('extra_disbursement_requests').doc(reqId);

      await docRef.set({
        'id': reqId,
        'requestId': reqId,
        'merchantId': widget.merchant.uid,
        'merchantName': widget.merchant.name,
        'merchantStoreName': widget.merchant.storeName ?? widget.merchant.name,
        'cardId': _cardIdController.text.trim().toUpperCase(),
        'requestedAmount': double.tryParse(_amountController.text.trim()) ?? 500,
        'reason': _reasonController.text.trim(),
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': DateTime.now().toIso8601String(),
      });

      setState(() {
        _requestId = reqId;
        _currentStatus = 'pending';
        _isSubmitting = false;
      });

      // Listen for live admin response
      docRef.snapshots().listen((snap) {
        if (snap.exists && mounted) {
          final data = snap.data();
          if (data != null && data['status'] != null) {
            setState(() {
              _currentStatus = data['status'] as String;
            });
          }
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء إرسال الطلب: $e')),
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
                      const Text(
                        'تم إرسال الطلب إلى لوحة تحكم الأدمن للمراجعة الفورية',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('تأكيد تسليم المبلغ للمستفيد'),
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
                      validator: (v) => (v == null || v.isEmpty) ? 'يرجى إدخال رقم الكارت' : null,
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
                      validator: (v) => (v == null || v.isEmpty) ? 'يرجى إدخال المبلغ' : null,
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
                      validator: (v) => (v == null || v.isEmpty) ? 'يرجى ذكر سبب الصرف الاستثنائي' : null,
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'extra_disbursement.submit'.tr(),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
