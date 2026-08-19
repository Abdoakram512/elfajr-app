import 'package:equatable/equatable.dart';
import '../models/aid_card_model.dart';

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

class BeneficiaryState extends Equatable {
  final int currentTabIndex;
  final AidCardModel? activeCard;
  final List<BeneficiaryRedemptionItem> redemptions;
  final bool isLoading;
  final String? successMessage;

  const BeneficiaryState({
    this.currentTabIndex = 0,
    this.activeCard,
    this.redemptions = const [],
    this.isLoading = false,
    this.successMessage,
  });

  BeneficiaryState copyWith({
    int? currentTabIndex,
    AidCardModel? activeCard,
    List<BeneficiaryRedemptionItem>? redemptions,
    bool? isLoading,
    String? successMessage,
  }) {
    return BeneficiaryState(
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      activeCard: activeCard ?? this.activeCard,
      redemptions: redemptions ?? this.redemptions,
      isLoading: isLoading ?? this.isLoading,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        currentTabIndex,
        activeCard,
        redemptions,
        isLoading,
        successMessage,
      ];
}
