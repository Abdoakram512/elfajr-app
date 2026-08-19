import 'package:equatable/equatable.dart';
import '../models/redemption_transaction_model.dart';

class MerchantDashboardState extends Equatable {
  final double todayDispensedAmount;
  final int todayTransactionsCount;
  final List<RedemptionTransactionModel> recentTransactions;
  final bool isLoading;
  final String? errorMessage;

  const MerchantDashboardState({
    this.todayDispensedAmount = 0.0,
    this.todayTransactionsCount = 0,
    this.recentTransactions = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  MerchantDashboardState copyWith({
    double? todayDispensedAmount,
    int? todayTransactionsCount,
    List<RedemptionTransactionModel>? recentTransactions,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return MerchantDashboardState(
      todayDispensedAmount: todayDispensedAmount ?? this.todayDispensedAmount,
      todayTransactionsCount:
          todayTransactionsCount ?? this.todayTransactionsCount,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        todayDispensedAmount,
        todayTransactionsCount,
        recentTransactions,
        isLoading,
        errorMessage,
      ];
}
