import 'package:equatable/equatable.dart';
import '../models/redemption_transaction_model.dart';

class MerchantDashboardState extends Equatable {
  final double allocatedBudget;
  final double todayDispensedAmount;
  final int todayTransactionsCount;
  final List<RedemptionTransactionModel> recentTransactions;
  final bool isLoading;
  final String? errorMessage;

  const MerchantDashboardState({
    this.allocatedBudget = 0.0,
    this.todayDispensedAmount = 0.0,
    this.todayTransactionsCount = 0,
    this.recentTransactions = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  double get remainingLiquidity =>
      (allocatedBudget - todayDispensedAmount) > 0
          ? (allocatedBudget - todayDispensedAmount)
          : 0.0;

  double get burnPercentage => allocatedBudget > 0
      ? (todayDispensedAmount / allocatedBudget).clamp(0.0, 1.0)
      : 0.0;

  bool get isLowLiquidity =>
      allocatedBudget > 0 && ((remainingLiquidity / allocatedBudget) <= 0.15);

  MerchantDashboardState copyWith({
    double? allocatedBudget,
    double? todayDispensedAmount,
    int? todayTransactionsCount,
    List<RedemptionTransactionModel>? recentTransactions,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return MerchantDashboardState(
      allocatedBudget: allocatedBudget ?? this.allocatedBudget,
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
        allocatedBudget,
        todayDispensedAmount,
        todayTransactionsCount,
        recentTransactions,
        isLoading,
        errorMessage,
      ];
}
