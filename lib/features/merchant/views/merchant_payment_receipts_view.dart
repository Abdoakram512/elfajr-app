import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../app/service_locator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/feedback/alfajr_refresh_indicator.dart';
import '../../../../core/widgets/feedback/app_empty_state_widget.dart';
import '../../auth/models/user_model.dart';
import '../../auth/view_models/auth_cubit.dart';
import '../../auth/view_models/auth_state.dart';
import '../models/payment_receipt_model.dart';
import '../widgets/payment_receipt_card_item.dart';
import '../widgets/receipts_filter_bar.dart';
import '../widgets/receipts_summary_header.dart';

class MerchantPaymentReceiptsView extends StatefulWidget {
  final UserModel? merchant;

  const MerchantPaymentReceiptsView({super.key, this.merchant});

  @override
  State<MerchantPaymentReceiptsView> createState() =>
      _MerchantPaymentReceiptsViewState();
}

class _MerchantPaymentReceiptsViewState
    extends State<MerchantPaymentReceiptsView> {
  final Set<String> _confirmingReceiptIds = {};
  ReceiptFilter _selectedFilter = ReceiptFilter.all;

  UserModel? get _effectiveMerchant {
    if (widget.merchant != null) return widget.merchant;
    final authState = getIt<AuthCubit>().state;
    return authState is Authenticated ? authState.user : null;
  }

  Future<void> _confirmReceipt(PaymentReceiptModel receipt) async {
    final merchant = _effectiveMerchant;
    if (merchant == null) return;

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
      final logRef = FirebaseFirestore.instance.collection('audit_logs').doc();
      batch.set(logRef, {
        'action': 'CONFIRM_PAYMENT_RECEIPT',
        'performedBy': merchant.uid,
        'performedByName': merchant.storeName ?? merchant.name,
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
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const Gap(10),
                Expanded(
                  child: Text(
                    'merchant.receipts.confirm_success'.tr(
                      namedArgs: {'amount': receipt.amount.toStringAsFixed(0)},
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white),
                const Gap(10),
                Expanded(
                  child: Text(
                    'merchant.receipts.confirm_error'.tr(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
    final merchant = _effectiveMerchant;

    if (merchant == null) {
      return Scaffold(
        appBar: AppBar(title: Text('merchant.receipts.sheet_title'.tr())),
        body: const Center(child: Text('يرجى تسجيل الدخول أولاً')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'merchant.receipts.sheet_title'.tr(),
          style: const TextStyle(
            fontSize: 19.5,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimaryLight,
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: AppColors.textPrimaryLight,
                ),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.borderLight, height: 1),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('payment_receipts')
            .where('merchantId', isEqualTo: merchant.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'merchant.receipts.confirm_error'.tr(),
                  style: const TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          final allReceipts =
              docs
                  .map(
                    (d) => PaymentReceiptModel.fromFirestore(
                      d.data() as Map<String, dynamic>,
                      d.id,
                    ),
                  )
                  .toList()
                ..sort((a, b) {
                  final aTime = a.timestamp ?? DateTime(2000);
                  final bTime = b.timestamp ?? DateTime(2000);
                  return bTime.compareTo(aTime);
                });

          // Metrics calculations
          final confirmedReceipts = allReceipts
              .where((r) => r.isConfirmed)
              .toList();
          final pendingReceipts = allReceipts
              .where((r) => !r.isConfirmed)
              .toList();

          final totalConfirmedAmount = confirmedReceipts.fold<double>(
            0.0,
            (acc, r) => acc + r.amount,
          );
          final totalPendingAmount = pendingReceipts.fold<double>(
            0.0,
            (acc, r) => acc + r.amount,
          );

          // Filtered list based on selected filter
          final filteredReceipts = _selectedFilter == ReceiptFilter.pending
              ? pendingReceipts
              : _selectedFilter == ReceiptFilter.confirmed
              ? confirmedReceipts
              : allReceipts;

          return AlfajrRefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              children: [
                // ── 1. Financial Overview Cards ──
                ReceiptsSummaryHeader(
                  totalConfirmed: totalConfirmedAmount,
                  totalPending: totalPendingAmount,
                  pendingCount: pendingReceipts.length,
                ),

                const Gap(16),

                // ── 2. Filter Tabs Bar ──
                ReceiptsFilterBar(
                  selectedFilter: _selectedFilter,
                  totalCount: allReceipts.length,
                  pendingCount: pendingReceipts.length,
                  confirmedCount: confirmedReceipts.length,
                  onFilterChanged: (filter) =>
                      setState(() => _selectedFilter = filter),
                ),

                const Gap(16),

                // ── 3. Receipts List / Empty State ──
                if (filteredReceipts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: AppEmptyStateWidget(
                      icon: Icons.receipt_long_outlined,
                      title: _selectedFilter == ReceiptFilter.pending
                          ? 'لا توجد وصولات بانتظار التأكيد'
                          : 'merchant.receipts.empty_title'.tr(),
                      description: _selectedFilter == ReceiptFilter.pending
                          ? 'تم تأكيد استلام جميع الحوالات المرسلة لحسابك بنجاح'
                          : 'merchant.receipts.empty_desc'.tr(),
                    ),
                  )
                else
                  ...filteredReceipts.map((receipt) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: PaymentReceiptCardItem(
                        receipt: receipt,
                        isConfirming: _confirmingReceiptIds.contains(
                          receipt.id,
                        ),
                        onConfirm: () => _confirmReceipt(receipt),
                      ),
                    );
                  }),
                const Gap(24),
              ],
            ),
          );
        },
      ),
    );
  }
}
