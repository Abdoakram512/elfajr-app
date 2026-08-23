import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/arabic_normalizer.dart';
import '../../../../core/widgets/feedback/app_empty_state_widget.dart';
import '../../../../core/widgets/feedback/alfajr_refresh_indicator.dart';
import '../../../../core/widgets/transactions/transaction_list_item.dart';
import '../../models/redemption_transaction_model.dart';
import '../../view_models/merchant_dashboard_cubit.dart';
import '../../view_models/merchant_dashboard_state.dart';

enum MerchantTimeframeFilter { today, thisWeek, thisMonth, all, custom }

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
        final startOfDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
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
      List<RedemptionTransactionModel> transactions) {
    return transactions.where((tx) {
      final matchesTime = _matchesTimeframe(tx.timestamp);
      if (!matchesTime) return false;

      if (_searchQuery.trim().isEmpty) return true;

      return ArabicNormalizer.matches(tx.beneficiaryName, _searchQuery) ||
          ArabicNormalizer.matches(tx.cardId, _searchQuery) ||
          (tx.notes != null && ArabicNormalizer.matches(tx.notes, _searchQuery));
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

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##0', 'ar');

    return BlocBuilder<MerchantDashboardCubit, MerchantDashboardState>(
      builder: (context, state) {
        final filteredList = _getFilteredTransactions(state.recentTransactions);

        // Stats calculations
        final totalDisbursed =
            filteredList.fold<double>(0.0, (sum, item) => sum + item.amountDeducted);
        final totalBaskets =
            filteredList.fold<int>(0, (sum, item) => sum + item.foodBasketsDeducted);
        final opsCount = filteredList.length;
        final uniqueBeneficiaries =
            filteredList.map((t) => t.cardId).toSet().length;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: Text('merchant.history_page_title'.tr()),
            automaticallyImplyLeading: false,
          ),
          body: AlfajrRefreshIndicator(
            onRefresh: () =>
                context.read<MerchantDashboardCubit>().refreshData(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              children: [
                // 1. Timeframe Filter Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        MerchantTimeframeFilter.today,
                        'merchant.filter_today'.tr(),
                        Icons.today_rounded,
                      ),
                      const Gap(8),
                      _buildFilterChip(
                        MerchantTimeframeFilter.thisWeek,
                        'merchant.filter_week'.tr(),
                        Icons.calendar_view_week_rounded,
                      ),
                      const Gap(8),
                      _buildFilterChip(
                        MerchantTimeframeFilter.thisMonth,
                        'merchant.filter_month'.tr(),
                        Icons.calendar_month_rounded,
                      ),
                      const Gap(8),
                      _buildFilterChip(
                        MerchantTimeframeFilter.all,
                        'merchant.filter_all'.tr(),
                        Icons.all_inclusive_rounded,
                      ),
                      const Gap(8),
                      InkWell(
                        onTap: () => _selectCustomDate(context),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            color: _selectedFilter == MerchantTimeframeFilter.custom
                                ? AppColors.primary
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _selectedFilter == MerchantTimeframeFilter.custom
                                  ? AppColors.primary
                                  : AppColors.borderLight,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_calendar_rounded,
                                size: 16,
                                color: _selectedFilter == MerchantTimeframeFilter.custom
                                    ? Colors.white
                                    : AppColors.textSecondaryLight,
                              ),
                              const Gap(6),
                              Text(
                                _selectedFilter == MerchantTimeframeFilter.custom &&
                                        _customSelectedDate != null
                                    ? DateFormat('MM/dd').format(_customSelectedDate!)
                                    : 'merchant.filter_custom'.tr(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _selectedFilter == MerchantTimeframeFilter.custom
                                      ? Colors.white
                                      : AppColors.textPrimaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Gap(16),

                // 2. Summary KPI Cards
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildKpiBox(
                              label: 'merchant.stats_total_amount'.tr(),
                              value: '${currencyFormatter.format(totalDisbursed)} ${'common.currency'.tr()}',
                              icon: Icons.payments_rounded,
                              color: const Color(0xFF0A734D),
                              bgColor: const Color(0xFFECFDF5),
                            ),
                          ),
                          const Gap(10),
                          Expanded(
                            child: _buildKpiBox(
                              label: 'merchant.stats_total_baskets'.tr(),
                              value: '$totalBaskets ${'common.baskets_unit'.tr()}',
                              icon: Icons.inventory_2_rounded,
                              color: const Color(0xFFD97706),
                              bgColor: const Color(0xFFFEF3C7),
                            ),
                          ),
                        ],
                      ),
                      const Gap(10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildKpiBox(
                              label: 'merchant.stats_operations'.tr(),
                              value: '$opsCount ${'merchant.txns_unit_label'.tr()}',
                              icon: Icons.receipt_long_rounded,
                              color: const Color(0xFF2563EB),
                              bgColor: const Color(0xFFEFF6FF),
                            ),
                          ),
                          const Gap(10),
                          Expanded(
                            child: _buildKpiBox(
                              label: 'merchant.stats_beneficiaries'.tr(),
                              value: '$uniqueBeneficiaries ${'merchant.beneficiaries_cases_label'.tr()}',
                              icon: Icons.people_alt_rounded,
                              color: const Color(0xFF7C3AED),
                              bgColor: const Color(0xFFF5F3FF),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Gap(16),

                // 3. Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'merchant.search_placeholder'.tr(),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),

                const Gap(14),

                // 4. Transactions List
                if (filteredList.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
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
                        foodBaskets: item.foodBasketsDeducted,
                        timestamp: item.timestamp,
                        showPrintButton: true,
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

  Widget _buildFilterChip(
      MerchantTimeframeFilter filter, String label, IconData icon) {
    final isSelected = _selectedFilter == filter;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = filter),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textSecondaryLight,
            ),
            const Gap(6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiBox({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: color),
              const Gap(6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Gap(4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: color,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
