import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/utils/arabic_normalizer.dart';
import '../../../../core/widgets/feedback/alfajr_refresh_indicator.dart';
import '../../../../core/widgets/feedback/app_empty_state_widget.dart';
import '../../../../core/widgets/transactions/transaction_list_item.dart';
import '../../models/redemption_transaction_model.dart';
import '../../view_models/merchant_dashboard_cubit.dart';
import '../../view_models/merchant_dashboard_state.dart';
import '../../widgets/history/merchant_history_metrics_card.dart';
import '../../widgets/history/merchant_history_timeframe_selector.dart';
import '../../widgets/history/merchant_transaction_detail_modal.dart';

class MerchantHistoryTab extends StatefulWidget {
  const MerchantHistoryTab({super.key});

  @override
  State<MerchantHistoryTab> createState() => _MerchantHistoryTabState();
}

class _MerchantHistoryTabState extends State<MerchantHistoryTab> {
  MerchantTimeframeFilter _selectedFilter = MerchantTimeframeFilter.today;
  DateTime? _customSelectedDate;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesTimeframe(DateTime txDate) {
    final now = DateTime.now();

    switch (_selectedFilter) {
      case MerchantTimeframeFilter.today:
        return txDate.year == now.year &&
            txDate.month == now.month &&
            txDate.day == now.day;

      case MerchantTimeframeFilter.thisWeek:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final startOfDay = DateTime(
          startOfWeek.year,
          startOfWeek.month,
          startOfWeek.day,
        );
        return txDate.isAfter(startOfDay.subtract(const Duration(seconds: 1)));

      case MerchantTimeframeFilter.thisMonth:
        return txDate.year == now.year && txDate.month == now.month;

      case MerchantTimeframeFilter.custom:
        if (_customSelectedDate == null) return true;
        return txDate.year == _customSelectedDate!.year &&
            txDate.month == _customSelectedDate!.month &&
            txDate.day == _customSelectedDate!.day;

      case MerchantTimeframeFilter.all:
        return true;
    }
  }

  List<RedemptionTransactionModel> _getFilteredTransactions(
    List<RedemptionTransactionModel> transactions,
  ) {
    return transactions.where((tx) {
      final matchesTime = _matchesTimeframe(tx.timestamp);
      if (!matchesTime) return false;

      if (_searchQuery.trim().isEmpty) return true;

      return ArabicNormalizer.matches(tx.beneficiaryName, _searchQuery) ||
          ArabicNormalizer.matches(tx.cardId, _searchQuery) ||
          (tx.notes != null &&
              ArabicNormalizer.matches(tx.notes, _searchQuery));
    }).toList();
  }

  Future<void> _selectCustomDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _customSelectedDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimaryLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customSelectedDate = picked;
        _selectedFilter = MerchantTimeframeFilter.custom;
      });
    }
  }

  String _getTimeframeLabel() {
    switch (_selectedFilter) {
      case MerchantTimeframeFilter.today:
        return 'merchant.filter_today'.tr();
      case MerchantTimeframeFilter.thisWeek:
        return 'merchant.filter_week'.tr();
      case MerchantTimeframeFilter.thisMonth:
        return 'merchant.filter_month'.tr();
      case MerchantTimeframeFilter.all:
        return 'merchant.filter_all'.tr();
      case MerchantTimeframeFilter.custom:
        return _customSelectedDate != null
            ? DateFormat('dd/MM/yyyy').format(_customSelectedDate!)
            : 'merchant.filter_custom'.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MerchantDashboardCubit, MerchantDashboardState>(
      builder: (context, state) {
        final filteredList = _getFilteredTransactions(state.recentTransactions);

        final totalDisbursed = filteredList.fold<double>(
          0.0,
          (sum, item) => sum + item.amountDeducted,
        );
        final opsCount = filteredList.length;
        final uniqueBeneficiaries =
            filteredList.map((t) => t.cardId).toSet().length;

        final isFiltered =
            _searchQuery.trim().isNotEmpty ||
            _selectedFilter != MerchantTimeframeFilter.today;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: Text(
              'merchant.history_app_bar_title'.tr(),
              style: const TextStyle(
                fontSize: 19.5,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimaryLight,
              ),
            ),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: AppColors.borderLight, height: 1),
            ),
          ),
          body: AlfajrRefreshIndicator(
            onRefresh: () async {
              context.read<MerchantDashboardCubit>().refreshData();
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // ── 1. Timeframe Filter Selector Bar ──
                MerchantHistoryTimeframeSelector(
                  selectedFilter: _selectedFilter,
                  customSelectedDate: _customSelectedDate,
                  onFilterChanged: (filter) =>
                      setState(() => _selectedFilter = filter),
                  onSelectCustomDate: () => _selectCustomDate(context),
                ),

                const Gap(16),

                // ── 2. Revenue & Operations Metrics Card ──
                MerchantHistoryMetricsCard(
                  totalDisbursed: totalDisbursed,
                  opsCount: opsCount,
                  uniqueBeneficiaries: uniqueBeneficiaries,
                  timeframeLabel: _getTimeframeLabel(),
                ),

                const Gap(18),

                // ── 3. Search Bar ──
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                  decoration: InputDecoration(
                    hintText: 'بحث باسم المستفيد، كود الكارت، أو الملاحظات...',
                    hintStyle: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textMutedLight,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: const Icon(
                      AppIcons.search,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(AppIcons.close, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.borderLight,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.borderLight,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                // Active Filter Summary Row
                if (isFiltered) ...[
                  const Gap(10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'عرض $opsCount حركة مطابقة',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                              _selectedFilter = MerchantTimeframeFilter.today;
                              _customSelectedDate = null;
                            });
                          },
                          child: const Row(
                            children: [
                              Icon(
                                AppIcons.refresh,
                                size: 13,
                                color: AppColors.error,
                              ),
                              Gap(4),
                              Text(
                                'إعادة تعيين الفلاتر',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const Gap(14),

                // ── 4. Transactions List / Empty State ──
                if (filteredList.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    child: AppEmptyStateWidget(
                      title: 'merchant.no_matching_txns_title'.tr(),
                      description: 'merchant.no_matching_txns_desc'.tr(),
                      icon: Icons.receipt_long_outlined,
                    ),
                  )
                else
                  ...filteredList.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TransactionListItem(
                        cardId: item.cardId,
                        beneficiaryName: item.beneficiaryName,
                        amount: item.amountDeducted,
                        foodBaskets: 0,
                        timestamp: item.timestamp,
                        showPrintButton: true,
                        onTap: () =>
                            MerchantTransactionDetailModal.show(context, item),
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }
}
