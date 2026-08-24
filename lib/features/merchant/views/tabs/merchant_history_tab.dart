import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/card_printer_service.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../core/utils/arabic_normalizer.dart';
import '../../../../core/widgets/common/info_key_value_row.dart';
import '../../../../core/widgets/feedback/alfajr_refresh_indicator.dart';
import '../../../../core/widgets/feedback/app_empty_state_widget.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/sheets/app_sheet_scaffold.dart';
import '../../../../core/widgets/transactions/transaction_list_item.dart';
import '../../../beneficiary/models/aid_card_model.dart';
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

  void _showTransactionDetails(
    BuildContext context,
    RedemptionTransactionModel tx,
  ) {
    final currencyFormatter = NumberFormat('#,##0', 'ar');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return AppSheetScaffold(
          title: 'تفاصيل عملية الصرف النقدي',
          subtitle: tx.cardId,
          icon: Icons.payments_rounded,
          iconColor: AppColors.primary,
          iconBgColor: AppColors.primarySubtle,
          heightFactor: 0.72,
          child: ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            children: [
              // Summary Amount Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFECFDF5), Colors.white],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'المبلغ المصروف نقداً',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      '${currencyFormatter.format(tx.amountDeducted)} ${'common.currency'.tr()}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0A734D),
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(16),

              // Detail Rows Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    InfoKeyValueRow(
                      label: 'اسم المستفيد',
                      value: tx.beneficiaryName,
                      isBold: true,
                    ),
                    const Gap(10),
                    InfoKeyValueRow(
                      label: 'كود الكارت',
                      value: tx.cardId,
                      isBold: true,
                    ),
                    const Gap(10),
                    InfoKeyValueRow(
                      label: 'تاريخ وتوقيت العملية',
                      value: AppFormatters.fullDate.format(tx.timestamp),
                    ),
                    if (tx.merchantStoreName.isNotEmpty) ...[
                      const Gap(10),
                      InfoKeyValueRow(
                        label: 'منفذ الصرف',
                        value: tx.merchantStoreName,
                      ),
                    ],
                    const Gap(10),
                    InfoKeyValueRow(
                      label: 'رقم المرجع',
                      value: tx.transactionId,
                    ),
                    if (tx.notes != null && tx.notes!.isNotEmpty) ...[
                      const Gap(10),
                      InfoKeyValueRow(
                        label: 'ملاحظات العملية',
                        value: tx.notes!,
                      ),
                    ],
                  ],
                ),
              ),

              const Gap(20),

              // Print / Export Button
              PrimaryButton(
                text: 'طباعة الإيصال / الكارت',
                leadingIcon: Icons.print_rounded,
                onPressed: () {
                  Navigator.pop(ctx);
                  CardPrinterService.printAidCard(
                    card: AidCardModel(
                      cardId: tx.cardId,
                      beneficiaryId: '',
                      beneficiaryName: tx.beneficiaryName,
                      nationalId: '1089283746',
                      familyCount: 5,
                      totalBalance: tx.amountDeducted,
                      foodBasketsQuota: 0,
                      status: AidCardStatus.active,
                      expiresAt: DateTime.now().add(const Duration(days: 180)),
                      securityHash: '',
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##0', 'ar');

    return BlocBuilder<MerchantDashboardCubit, MerchantDashboardState>(
      builder: (context, state) {
        final filteredList = _getFilteredTransactions(state.recentTransactions);

        // Stats calculations (Cash & Operations only - NO food baskets)
        final totalDisbursed = filteredList.fold<double>(
          0.0,
          (sum, item) => sum + item.amountDeducted,
        );
        final opsCount = filteredList.length;
        final uniqueBeneficiaries = filteredList
            .map((t) => t.cardId)
            .toSet()
            .length;

        final isFiltered =
            _searchQuery.trim().isNotEmpty ||
            _selectedFilter != MerchantTimeframeFilter.today;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: Text(
              'merchant.history_page_title'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimaryLight,
              ),
            ),
            automaticallyImplyLeading: false,
            elevation: 0,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: AppColors.borderLight, height: 1),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Gap(6),
                    Text(
                      '$opsCount عملية',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: AlfajrRefreshIndicator(
            onRefresh: () =>
                context.read<MerchantDashboardCubit>().refreshData(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              children: [
                // ── 1. Timeframe Filter Tabs ──
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
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
                      // Custom Date Chip
                      InkWell(
                        onTap: () => _selectCustomDate(context),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _selectedFilter ==
                                    MerchantTimeframeFilter.custom
                                ? AppColors.primary
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color:
                                  _selectedFilter ==
                                      MerchantTimeframeFilter.custom
                                  ? AppColors.primary
                                  : AppColors.borderLight,
                            ),
                            boxShadow:
                                _selectedFilter ==
                                    MerchantTimeframeFilter.custom
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.22,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit_calendar_rounded,
                                size: 15,
                                color:
                                    _selectedFilter ==
                                        MerchantTimeframeFilter.custom
                                    ? Colors.white
                                    : AppColors.textSecondaryLight,
                              ),
                              const Gap(6),
                              Text(
                                _selectedFilter ==
                                            MerchantTimeframeFilter.custom &&
                                        _customSelectedDate != null
                                    ? DateFormat(
                                        'MM/dd',
                                      ).format(_customSelectedDate!)
                                    : 'merchant.filter_custom'.tr(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      _selectedFilter ==
                                          MerchantTimeframeFilter.custom
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

                // ── 2. Hero Cash Card (Imperial Emerald Theme) ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF063A28),
                        Color(0xFF0A734D),
                        Color(0xFF0F8A5D),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0A734D).withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.payments_rounded,
                                  color: Color(0xFFFDE68A),
                                  size: 18,
                                ),
                              ),
                              const Gap(10),
                              Text(
                                'merchant.stats_total_amount'.tr(),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
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
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Text(
                              _getTimeframeLabel(),
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

                      // Main Amount Value
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            currencyFormatter.format(totalDisbursed),
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const Gap(6),
                          Text(
                            'common.currency'.tr(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),

                      const Gap(16),

                      // Bottom Sub-metric Bar
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 15,
                                  color: Color(0xFFFDE68A),
                                ),
                                const Gap(6),
                                Text(
                                  '$opsCount عملية صرف معتمدة بالمنفذ',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFFDE68A,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'محدّث لحظياً',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFDE68A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Gap(12),

                // ── 3. Secondary KPI Metric Grid (Beneficiaries & Operations) ──
                Row(
                  children: [
                    // Beneficiaries Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F9FF),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFBAE6FD)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0F2FE),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.groups_rounded,
                                    color: Color(0xFF0284C7),
                                    size: 18,
                                  ),
                                ),
                                Text(
                                  'merchant.stats_beneficiaries'.tr(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0369A1),
                                  ),
                                ),
                              ],
                            ),
                            const Gap(8),
                            Text(
                              '$uniqueBeneficiaries ${'merchant.beneficiaries_cases_label'.tr()}',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0369A1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Gap(10),

                    // Total Operations Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F3FF),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFDDD6FE)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEDE9FE),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.receipt_long_rounded,
                                    color: Color(0xFF7C3AED),
                                    size: 18,
                                  ),
                                ),
                                Text(
                                  'merchant.stats_operations'.tr(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5B21B6),
                                  ),
                                ),
                              ],
                            ),
                            const Gap(8),
                            Text(
                              '$opsCount ${'merchant.txns_unit_label'.tr()}',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF5B21B6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const Gap(18),

                // ── 4. Search Bar ──
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
                      Icons.search_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
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
                                Icons.refresh_rounded,
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

                // ── 5. Transactions List ──
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
                        onTap: () => _showTransactionDetails(context, item),
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
    MerchantTimeframeFilter filter,
    String label,
    IconData icon,
  ) {
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
                    color: AppColors.primary.withValues(alpha: 0.22),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
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
}
