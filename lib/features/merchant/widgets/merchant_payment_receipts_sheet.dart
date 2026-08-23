import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/feedback/app_empty_state_widget.dart';
import '../../../../core/widgets/sheets/app_sheet_scaffold.dart';
import '../../auth/models/user_model.dart';
import '../models/payment_receipt_model.dart';
import 'payment_receipt_card_item.dart';

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
  final Set<String> _confirmingReceiptIds = {};

  Future<void> _confirmReceipt(PaymentReceiptModel receipt) async {
    setState(() => _confirmingReceiptIds.add(receipt.id));

    try {
      final batch = FirebaseFirestore.instance.batch();

      // 1. Mark receipt as confirmed
      final receiptRef = FirebaseFirestore.instance
          .collection('payment_receipts')
          .doc(receipt.id);
      batch.update(receiptRef, {
        'status': 'confirmed_by_merchant',
        'isConfirmed': true,
        'confirmedAt': FieldValue.serverTimestamp(),
      });

      // 2. Add audit log
      final logRef =
          FirebaseFirestore.instance.collection('audit_logs').doc();
      batch.set(logRef, {
        'action': 'CONFIRM_PAYMENT_RECEIPT',
        'performedBy': widget.merchant.uid,
        'performedByName': widget.merchant.storeName ?? widget.merchant.name,
        'role': 'merchant',
        'timestamp': FieldValue.serverTimestamp(),
        'details': {
          'receiptId': receipt.id,
          'amount': receipt.amount,
          'method': receipt.paymentMethod,
          'referenceNumber': receipt.referenceNumber,
        },
      });

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('merchant.receipts.confirmed_success'.tr()),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('merchant.receipts.confirmed_failed'.tr(namedArgs: {'error': '$e'})),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _confirmingReceiptIds.remove(receipt.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppSheetScaffold(
      title: 'merchant.receipts.sheet_title'.tr(),
      subtitle: 'merchant.receipts.sheet_subtitle'.tr(),
      icon: Icons.payments_rounded,
      iconColor: const Color(0xFFD97706),
      iconBgColor: const Color(0xFFFEF3C7),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('payment_receipts')
            .where('merchantId', isEqualTo: widget.merchant.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'merchant.receipts.stream_error'.tr(namedArgs: {'error': '${snapshot.error}'}),
                style: const TextStyle(color: AppColors.error),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return AppEmptyStateWidget(
              icon: Icons.receipt_long_outlined,
              title: 'merchant.receipts.empty_title'.tr(),
              description: 'merchant.receipts.empty_desc'.tr(),
            );
          }

          final receipts = docs
              .map((d) => PaymentReceiptModel.fromFirestore(d.data() as Map<String, dynamic>, d.id))
              .toList()
            ..sort((a, b) {
              final aTime = a.timestamp ?? DateTime(2000);
              final bTime = b.timestamp ?? DateTime(2000);
              return bTime.compareTo(aTime);
            });

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: receipts.length,
            separatorBuilder: (ctx, i) => const Gap(14),
            itemBuilder: (context, index) {
              final receipt = receipts[index];
              return PaymentReceiptCardItem(
                receipt: receipt,
                isConfirming: _confirmingReceiptIds.contains(receipt.id),
                onConfirm: () => _confirmReceipt(receipt),
              );
            },
          );
        },
      ),
    );
  }
}
