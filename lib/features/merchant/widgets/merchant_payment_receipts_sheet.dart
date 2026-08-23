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
              'merchant.receipts.confirm_success'.tr(namedArgs: {'amount': receipt.amount.toStringAsFixed(0)}),
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('merchant.receipts.confirm_error'.tr()),
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
        return 'merchant.receipts.method_instapay'.tr();
      case 'vodafone_cash':
        return 'merchant.receipts.method_vodafone_cash'.tr();
      case 'bank_transfer':
        return 'merchant.receipts.method_bank_transfer'.tr();
      case 'cash':
        return 'merchant.receipts.method_cash'.tr();
      default:
        return method;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##0');

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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'merchant.receipts.sheet_title'.tr(),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          'merchant.receipts.sheet_subtitle'.tr(),
                          style: const TextStyle(
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
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: AppEmptyStateWidget(
                      title: 'merchant.receipts.empty_title'.tr(),
                      description: 'merchant.receipts.empty_desc'.tr(),
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
                  padding: const EdgeInsets.all(20),
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
                              ? AppColors.success.withValues(alpha: 0.3)
                              : const Color(0xFFFDE68A),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row 1: Method Badge + Amount + Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _getMethodLabel(r.paymentMethod),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    currencyFormatter.format(r.amount),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                  const Gap(4),
                                  Text(
                                    'common.currency'.tr(),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const Gap(10),

                          // Row 2: Status Pill & Date
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: r.isConfirmed
                                      ? AppColors.success.withValues(alpha: 0.1)
                                      : const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  r.isConfirmed
                                      ? 'merchant.receipts.status_confirmed'.tr()
                                      : 'merchant.receipts.status_pending'.tr(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: r.isConfirmed
                                        ? AppColors.success
                                        : const Color(0xFFD97706),
                                  ),
                                ),
                              ),
                              if (r.timestamp != null)
                                Text(
                                  DateFormat('yyyy/MM/dd - hh:mm a')
                                      .format(r.timestamp!),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                            ],
                          ),

                          const Gap(12),
                          const Divider(height: 1),
                          const Gap(10),

                          // Row 3: Reference Number
                          if (r.referenceNumber.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.tag_rounded,
                                    size: 14,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                  const Gap(6),
                                  Text(
                                    'merchant.receipts.ref_label'.tr(namedArgs: {'ref': r.referenceNumber}),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Row 4: Notes
                          if (r.notes != null && r.notes!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.notes_rounded,
                                    size: 14,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                  const Gap(6),
                                  Expanded(
                                    child: Text(
                                      'merchant.receipts.admin_notes_label'.tr(namedArgs: {'notes': r.notes!}),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Row 5: Receipt Image Attachment (Click to View)
                          if (r.receiptImageUrl != null &&
                              r.receiptImageUrl!.isNotEmpty) ...[
                            const Gap(4),
                            InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => ReceiptImageViewerDialog(
                                    imageUrl: r.receiptImageUrl!,
                                    title: 'merchant.receipts.receipt_image_title'.tr(namedArgs: {'amount': r.amount.toStringAsFixed(0)}),
                                    amount: r.amount,
                                    referenceNumber: r.referenceNumber,
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0FDF4),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFBBF7D0),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.image_search_rounded,
                                      size: 18,
                                      color: Color(0xFF16A34A),
                                    ),
                                    const Gap(8),
                                    Expanded(
                                      child: Text(
                                        'merchant.receipts.tap_to_preview'.tr(),
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF16A34A),
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 12,
                                      color: Color(0xFF16A34A),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          // Action Button (Confirm Receipt if pending)
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
                                  backgroundColor: const Color(0xFF059669),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                                child: isConfirming
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'merchant.receipts.confirm_button'.tr(),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
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
