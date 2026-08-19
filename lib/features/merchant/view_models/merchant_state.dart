import 'package:equatable/equatable.dart';
import '../../beneficiary/models/aid_card_model.dart';
import '../models/redemption_transaction_model.dart';

class MerchantState extends Equatable {
  final int currentTabIndex;
  final double todayDispensedAmount;
  final int todayTransactionsCount;
  final List<RedemptionTransactionModel> recentTransactions;
  final AidCardModel? scannedCard;
  final bool isScanning;
  final bool isProcessingRedemption;
  final String? successMessage;
  final String? errorMessage;

  const MerchantState({
    this.currentTabIndex = 0,
    this.todayDispensedAmount = 1450.0,
    this.todayTransactionsCount = 6,
    this.recentTransactions = const [],
    this.scannedCard,
    this.isScanning = false,
    this.isProcessingRedemption = false,
    this.successMessage,
    this.errorMessage,
  });

  MerchantState copyWith({
    int? currentTabIndex,
    double? todayDispensedAmount,
    int? todayTransactionsCount,
    List<RedemptionTransactionModel>? recentTransactions,
    AidCardModel? scannedCard,
    bool? isScanning,
    bool? isProcessingRedemption,
    String? successMessage,
    String? errorMessage,
  }) {
    return MerchantState(
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      todayDispensedAmount: todayDispensedAmount ?? this.todayDispensedAmount,
      todayTransactionsCount:
          todayTransactionsCount ?? this.todayTransactionsCount,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      scannedCard: scannedCard,
      isScanning: isScanning ?? this.isScanning,
      isProcessingRedemption:
          isProcessingRedemption ?? this.isProcessingRedemption,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        currentTabIndex,
        todayDispensedAmount,
        todayTransactionsCount,
        recentTransactions,
        scannedCard,
        isScanning,
        isProcessingRedemption,
        successMessage,
        errorMessage,
      ];
}
