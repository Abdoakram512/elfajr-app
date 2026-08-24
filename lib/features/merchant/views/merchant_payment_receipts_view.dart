import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../../../app/service_locator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/feedback/alfajr_refresh_indicator.dart';
import '../../../../core/widgets/feedback/app_empty_state_widget.dart';
import '../../auth/models/user_model.dart';
import '../view_models/merchant_receipts_cubit.dart';
import '../view_models/merchant_receipts_state.dart';
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
  ReceiptFilter _selectedFilter = ReceiptFilter.all;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MerchantReceiptsCubit>(),
      child: Scaffold(
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
        body: BlocConsumer<MerchantReceiptsCubit, MerchantReceiptsState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
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
            if (state.successMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Colors.white),
                      const Gap(10),
                      Expanded(
                        child: Text(
                          state.successMessage!.tr(),
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
          },
          builder: (context, state) {
            if (state.status == MerchantReceiptsStatus.loading &&
                state.receipts.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            final allReceipts = state.receipts;
            final confirmedReceipts =
                allReceipts.where((r) => r.isConfirmed).toList();
            final pendingReceipts =
                allReceipts.where((r) => !r.isConfirmed).toList();

            final totalConfirmedAmount = state.totalConfirmed;
            final totalPendingAmount = state.totalPending;

            // Filtered list based on selected filter
            final filteredReceipts = _selectedFilter == ReceiptFilter.pending
                ? pendingReceipts
                : _selectedFilter == ReceiptFilter.confirmed
                    ? confirmedReceipts
                    : allReceipts;

            return AlfajrRefreshIndicator(
              onRefresh: () async {
                // Realtime subscription automatically manages updates
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
                          isConfirming:
                              state.confirmingReceiptId == receipt.id,
                          onConfirm: () {
                            context.read<MerchantReceiptsCubit>().confirmReceipt(
                                  receiptId: receipt.id,
                                  adminId: receipt.sentByAdminId ?? '',
                                );
                          },
                        ),
                      );
                    }),
                  const Gap(24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
