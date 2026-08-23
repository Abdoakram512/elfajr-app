import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/feedback/app_empty_state_widget.dart';
import '../../auth/models/user_model.dart';
import '../models/payment_receipt_model.dart';
import 'receipt_image_viewer_dialog.dart';

class MerchantPaymentReceiptsSheet extends StatefulWidget {
  final UserModel merchant;

  const MerchantPaymentReceiptsSheet({
    super.key,
    required this.merchant,
  });

  @override
  State<MerchantPaymentReceiptsSheet> createState() =>
      _MerchantPaymentReceiptsSheetState();
}

class _MerchantPaymentReceiptsSheetState
    extends State<MerchantPaymentReceiptsSheet> {
  final Set<String> _confirmingIds = {};

  Future<void> _confirmReceipt(PaymentReceiptModel receipt) async {
    setState(() => _confirmingIds.add(receipt.id));

    try {
      await FirebaseFirestore.instance
          .collection('payment_receipts')
          .doc(receipt.id)
          .update({
        'status': 'confirmed_by_merchant',
        'confirmedAt': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم تأكيد استلام الحوالة بمبلغ ${receipt.amount.toStringAsFixed(0)} ج.م بنجاح ✅',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر تحديث حالة الاستلام، يرجى المحاولة لاحقاً'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _confirmingIds.remove(receipt.id));
      }
    }
  }

  String _getMethodLabel(String method) {
    switch (method) {
      case 'instapay':
        return '⚡ إنستا باي (InstaPay)';
      case 'vodafone_cash':
        return '📱 فودافون كاش';
      case 'bank_transfer':
        return '🏛️ تحويل بنكي';
      case 'cash':
        return '💵 نقدي باليد';
      default:
        return method;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##0', 'ar');

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const Gap(12),
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const Gap(16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.payments_rounded,
                        color: Color(0xFFD97706),
                        size: 24,
                      ),
                    ),
                    const Gap(12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'سجل وصولات الدفع والحوالات',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          'الحوالات والمبالغ المحولة من المؤسسة لحسابك',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                  ),
                ),
              ],
            ),
          ),

          const Gap(12),
          const Divider(height: 1),

          // Stream Content
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('payment_receipts')
                  .where('merchantId', isEqualTo: widget.merchant.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const SingleChildScrollView(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: AppEmptyStateWidget(
                      title: 'لا توجد وصولات دفع مرسلة حتى الآن',
                      description:
                          'ستظهر هنا كافة إيصالات التحويل البنكي وفودافون كاش وإنستاباي المرسلة لك من الإدارة مع صور الإيصالات',
                      icon: Icons.receipt_long_outlined,
                    ),
                  );
                }

                final receipts = snapshot.data!.docs.map((doc) {
                  return PaymentReceiptModel.fromFirestore(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  );
                }).toList();

                // Sort by timestamp descending
                receipts.sort((a, b) {
                  final tA = a.timestamp ?? DateTime(2000);
                  final tB = b.timestamp ?? DateTime(2000);
                  return tB.compareTo(tA);
                });

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  itemCount: receipts.length,
                  separatorBuilder: (context, index) => const Gap(14),
                  itemBuilder: (context, index) {
                    final r = receipts[index];
                    final isConfirming = _confirmingIds.contains(r.id);

                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: r.isConfirmed
                              ? const Color(0xFF10B981).withValues(alpha: 0.3)
                              : const Color(0xFFF59E0B).withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top row: Amount + Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '+${currencyFormatter.format(r.amount)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF0F766E),
                                    ),
                                  ),
                                  const Gap(4),
                                  const Text(
                                    'ج.م',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textSecondaryLight,
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
                                  color: r.isConfirmed
                                      ? const Color(0xFFECFDF5)
                                      : const Color(0xFFFFFBEB),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: r.isConfirmed
                                        ? const Color(0xFFA7F3D0)
                                        : const Color(0xFFFDE68A),
                                  ),
                                ),
                                child: Text(
                                  r.isConfirmed ? 'تم التأكيد ✅' : 'بانتظار تأكيدك ⏳',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: r.isConfirmed
                                        ? const Color(0xFF047857)
                                        : const Color(0xFFB45309),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const Gap(10),

                          // Method & Ref
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _getMethodLabel(r.paymentMethod),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimaryLight,
                                  ),
                                ),
                              ),
                              const Gap(8),
                              Text(
                                'مرجع: ${r.referenceNumber}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),

                          if (r.timestamp != null) ...[
                            const Gap(6),
                            Text(
                              DateFormat('yyyy/MM/dd - hh:mm a', 'ar')
                                  .format(r.timestamp!),
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          ],

                          if (r.notes != null && r.notes!.isNotEmpty) ...[
                            const Gap(8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'ملاحظة الإدارة: ${r.notes}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                          ],

                          // ── RECEIPT IMAGE CARD (CLICK TO VIEW FULL) ──
                          if (r.receiptImageUrl != null &&
                              r.receiptImageUrl!.isNotEmpty) ...[
                            const Gap(12),
                            InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => ReceiptImageViewerDialog(
                                    imageUrl: r.receiptImageUrl!,
                                    title: 'صورة إيصال تحويل ${r.amount.toStringAsFixed(0)} ج.م',
                                    amount: r.amount,
                                    referenceNumber: r.referenceNumber,
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFFCD34D),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.image_search_rounded,
                                      color: Color(0xFFD97706),
                                      size: 20,
                                    ),
                                    Gap(8),
                                    Expanded(
                                      child: Text(
                                        'اضغط هنا لمعاينة وتكبير صورة وصل التحويل 📸',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF92400E),
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 12,
                                      color: Color(0xFF92400E),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          // Confirm Button (if not yet confirmed)
                          if (!r.isConfirmed) ...[
                            const Gap(14),
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: ElevatedButton(
                                onPressed: isConfirming
                                    ? null
                                    : () => _confirmReceipt(r),
                                style: ElevatedButton.styleFrom(
                                  alignment: Alignment.center,
                                  backgroundColor: const Color(0xFF0A734D),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Center(
                                  child: isConfirming
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons
                                                    .check_circle_outline_rounded,
                                                size: 18,
                                                color: Colors.white,
                                              ),
                                              Gap(8),
                                              Text(
                                                'تأكيد استلام المبلغ في حسابي ✅',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
