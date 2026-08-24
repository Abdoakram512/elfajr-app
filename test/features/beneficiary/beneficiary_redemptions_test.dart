import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qout/features/beneficiary/view_models/beneficiary_state.dart';

void main() {
  group('BeneficiaryTimeframeFilter & Extension Tests', () {
    final now = DateTime.now();

    final testItems = [
      BeneficiaryRedemptionItem(
        transactionId: 'TXN-01',
        merchantStoreName: 'تموينات الفجر',
        amountDeducted: 250.0,
        foodBasketsDeducted: 1,
        remainingBalance: 350.0,
        remainingBaskets: 1,
        timestamp: DateTime(now.year, now.month, 10, 14, 30),
      ),
      BeneficiaryRedemptionItem(
        transactionId: 'TXN-02',
        merchantStoreName: 'صيدلية النور',
        amountDeducted: 150.0,
        foodBasketsDeducted: 0,
        remainingBalance: 200.0,
        remainingBaskets: 1,
        timestamp: DateTime(now.year, now.month, 15, 10, 0),
      ),
      BeneficiaryRedemptionItem(
        transactionId: 'TXN-03',
        merchantStoreName: 'سوبرماركت المدينة',
        amountDeducted: 200.0,
        foodBasketsDeducted: 1,
        remainingBalance: 0.0,
        remainingBaskets: 0,
        timestamp: DateTime(now.year, now.month - 1, 5, 18, 0),
      ),
      // Pure food basket transaction (0 EGP, 1 basket)
      BeneficiaryRedemptionItem(
        transactionId: 'TXN-04',
        merchantStoreName: 'منفذ السلال المعتمد',
        amountDeducted: 0.0,
        foodBasketsDeducted: 1,
        remainingBalance: 350.0,
        remainingBaskets: 0,
        timestamp: DateTime(now.year, now.month, 18, 11, 0),
      ),
    ];

    test('totalDisbursed and totalBaskets calculate correctly including pure basket txns', () {
      expect(testItems.totalDisbursed, 600.0);
      expect(testItems.totalBaskets, 3);
    });

    test('forMonth filters current month items accurately', () {
      final thisMonthList = testItems.forMonth(now);
      expect(thisMonthList.length, 3);
      expect(thisMonthList.totalDisbursed, 400.0);
      expect(thisMonthList.totalBaskets, 2);
    });

    test('BeneficiaryTimeframeFilter.thisMonth matches current month only', () {
      final filtered = testItems.filterByTimeframe(BeneficiaryTimeframeFilter.thisMonth);
      expect(filtered.length, 3);
      expect(filtered.every((i) => i.timestamp.month == now.month), isTrue);
    });

    test('BeneficiaryTimeframeFilter.lastMonth matches previous month only', () {
      final filtered = testItems.filterByTimeframe(BeneficiaryTimeframeFilter.lastMonth);
      expect(filtered.length, 1);
      expect(filtered.first.transactionId, 'TXN-03');
    });

    test('BeneficiaryTimeframeFilter.allTime returns all items', () {
      final filtered = testItems.filterByTimeframe(BeneficiaryTimeframeFilter.allTime);
      expect(filtered.length, 4);
    });

    test('BeneficiaryTimeframeFilter.custom matches custom date range', () {
      final range = DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: DateTime(now.year, now.month, 12),
      );
      final filtered = testItems.filterByTimeframe(
        BeneficiaryTimeframeFilter.custom,
        customRange: range,
      );
      expect(filtered.length, 1);
      expect(filtered.first.transactionId, 'TXN-01');
    });
  });
}
