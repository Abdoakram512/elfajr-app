import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../models/aid_card_model.dart';

enum BeneficiaryTimeframeFilter {
  thisMonth,
  lastMonth,
  today,
  thisWeek,
  last3Months,
  thisYear,
  allTime,
  custom;

  bool matches(DateTime txDate, {DateTimeRange? customRange}) {
    final now = DateTime.now();

    switch (this) {
      case BeneficiaryTimeframeFilter.thisMonth:
        return txDate.year == now.year && txDate.month == now.month;

      case BeneficiaryTimeframeFilter.lastMonth:
        final lastMonthDate = DateTime(now.year, now.month - 1, 1);
        return txDate.year == lastMonthDate.year &&
            txDate.month == lastMonthDate.month;

      case BeneficiaryTimeframeFilter.today:
        return txDate.year == now.year &&
            txDate.month == now.month &&
            txDate.day == now.day;

      case BeneficiaryTimeframeFilter.thisWeek:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final startOfDay = DateTime(
          startOfWeek.year,
          startOfWeek.month,
          startOfWeek.day,
        );
        return txDate.isAfter(startOfDay.subtract(const Duration(seconds: 1)));

      case BeneficiaryTimeframeFilter.last3Months:
        final threeMonthsAgo = now.subtract(const Duration(days: 90));
        return txDate.isAfter(threeMonthsAgo);

      case BeneficiaryTimeframeFilter.thisYear:
        return txDate.year == now.year;

      case BeneficiaryTimeframeFilter.allTime:
        return true;

      case BeneficiaryTimeframeFilter.custom:
        if (customRange == null) return true;
        final start = DateTime(
          customRange.start.year,
          customRange.start.month,
          customRange.start.day,
        );
        final end = DateTime(
          customRange.end.year,
          customRange.end.month,
          customRange.end.day,
          23,
          59,
          59,
        );
        return txDate.isAfter(start.subtract(const Duration(seconds: 1))) &&
            txDate.isBefore(end.add(const Duration(seconds: 1)));
    }
  }

  String getLabel({DateTimeRange? customRange}) {
    switch (this) {
      case BeneficiaryTimeframeFilter.thisMonth:
        return 'dashboard.beneficiary.filter_month'.tr();
      case BeneficiaryTimeframeFilter.lastMonth:
        return 'dashboard.beneficiary.filter_last_month'.tr();
      case BeneficiaryTimeframeFilter.today:
        return 'dashboard.beneficiary.filter_today'.tr();
      case BeneficiaryTimeframeFilter.thisWeek:
        return 'dashboard.beneficiary.filter_week'.tr();
      case BeneficiaryTimeframeFilter.last3Months:
        return 'dashboard.beneficiary.filter_last_3_months'.tr();
      case BeneficiaryTimeframeFilter.thisYear:
        return 'dashboard.beneficiary.filter_year'.tr();
      case BeneficiaryTimeframeFilter.allTime:
        return 'dashboard.beneficiary.filter_all'.tr();
      case BeneficiaryTimeframeFilter.custom:
        if (customRange != null) {
          final fmt = DateFormat('MM/dd');
          return '${fmt.format(customRange.start)} - ${fmt.format(customRange.end)}';
        }
        return 'dashboard.beneficiary.filter_custom_range'.tr();
    }
  }
}

class BeneficiaryRedemptionItem extends Equatable {
  final String transactionId;
  final String merchantStoreName;
  final double amountDeducted;
  final int foodBasketsDeducted;
  final double remainingBalance;
  final int remainingBaskets;
  final DateTime timestamp;
  final String? notes;

  const BeneficiaryRedemptionItem({
    required this.transactionId,
    required this.merchantStoreName,
    required this.amountDeducted,
    required this.foodBasketsDeducted,
    required this.remainingBalance,
    required this.remainingBaskets,
    required this.timestamp,
    this.notes,
  });

  @override
  List<Object?> get props => [
        transactionId,
        merchantStoreName,
        amountDeducted,
        foodBasketsDeducted,
        remainingBalance,
        remainingBaskets,
        timestamp,
        notes,
      ];
}

extension BeneficiaryRedemptionListX on List<BeneficiaryRedemptionItem> {
  double get totalDisbursed =>
      fold<double>(0.0, (sum, item) => sum + item.amountDeducted);

  int get totalBaskets =>
      fold<int>(0, (sum, item) => sum + item.foodBasketsDeducted);

  List<BeneficiaryRedemptionItem> filterByTimeframe(
    BeneficiaryTimeframeFilter filter, {
    DateTimeRange? customRange,
  }) {
    return where((item) => filter.matches(item.timestamp, customRange: customRange)).toList();
  }

  List<BeneficiaryRedemptionItem> forMonth(DateTime month) {
    return where((r) =>
        r.timestamp.year == month.year && r.timestamp.month == month.month).toList();
  }
}

class BeneficiaryState extends Equatable {
  final AidCardModel? activeCard;
  final List<BeneficiaryRedemptionItem> redemptions;
  final bool isLoading;
  final String? successMessage;

  const BeneficiaryState({
    this.activeCard,
    this.redemptions = const [],
    this.isLoading = false,
    this.successMessage,
  });

  BeneficiaryState copyWith({
    AidCardModel? activeCard,
    List<BeneficiaryRedemptionItem>? redemptions,
    bool? isLoading,
    String? successMessage,
  }) {
    return BeneficiaryState(
      activeCard: activeCard ?? this.activeCard,
      redemptions: redemptions ?? this.redemptions,
      isLoading: isLoading ?? this.isLoading,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        activeCard,
        redemptions,
        isLoading,
        successMessage,
      ];
}
