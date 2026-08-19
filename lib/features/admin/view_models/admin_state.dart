import 'package:equatable/equatable.dart';

class AdminRedemptionItem extends Equatable {
  final String id;
  final String beneficiaryName;
  final String cardId;
  final String merchantName;
  final double amount;
  final int foodBaskets;
  final String city;
  final DateTime timestamp;

  const AdminRedemptionItem({
    required this.id,
    required this.beneficiaryName,
    required this.cardId,
    required this.merchantName,
    required this.amount,
    required this.foodBaskets,
    required this.city,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        id,
        beneficiaryName,
        cardId,
        merchantName,
        amount,
        foodBaskets,
        city,
        timestamp,
      ];
}

class AdminMerchantItem extends Equatable {
  final String id;
  final String name;
  final String storeType;
  final String city;
  final String commercialReg;
  final int totalTransactions;
  final double totalDisbursed;
  final bool isActive;

  const AdminMerchantItem({
    required this.id,
    required this.name,
    required this.storeType,
    required this.city,
    required this.commercialReg,
    required this.totalTransactions,
    required this.totalDisbursed,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        storeType,
        city,
        commercialReg,
        totalTransactions,
        totalDisbursed,
        isActive,
      ];
}

class AdminState extends Equatable {
  final int currentTabIndex;
  final double totalFundsDisbursed;
  final int totalBeneficiariesCount;
  final int activeMerchantsCount;
  final int totalRedemptionsCount;
  final List<AdminRedemptionItem> recentRedemptions;
  final List<AdminMerchantItem> merchants;
  final bool isLoading;
  final String? notificationMessage;

  const AdminState({
    this.currentTabIndex = 0,
    this.totalFundsDisbursed = 0.0,
    this.totalBeneficiariesCount = 0,
    this.activeMerchantsCount = 0,
    this.totalRedemptionsCount = 0,
    this.recentRedemptions = const [],
    this.merchants = const [],
    this.isLoading = false,
    this.notificationMessage,
  });

  AdminState copyWith({
    int? currentTabIndex,
    double? totalFundsDisbursed,
    int? totalBeneficiariesCount,
    int? activeMerchantsCount,
    int? totalRedemptionsCount,
    List<AdminRedemptionItem>? recentRedemptions,
    List<AdminMerchantItem>? merchants,
    bool? isLoading,
    String? notificationMessage,
  }) {
    return AdminState(
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      totalFundsDisbursed: totalFundsDisbursed ?? this.totalFundsDisbursed,
      totalBeneficiariesCount:
          totalBeneficiariesCount ?? this.totalBeneficiariesCount,
      activeMerchantsCount: activeMerchantsCount ?? this.activeMerchantsCount,
      totalRedemptionsCount:
          totalRedemptionsCount ?? this.totalRedemptionsCount,
      recentRedemptions: recentRedemptions ?? this.recentRedemptions,
      merchants: merchants ?? this.merchants,
      isLoading: isLoading ?? this.isLoading,
      notificationMessage: notificationMessage,
    );
  }

  @override
  List<Object?> get props => [
        currentTabIndex,
        totalFundsDisbursed,
        totalBeneficiariesCount,
        activeMerchantsCount,
        totalRedemptionsCount,
        recentRedemptions,
        merchants,
        isLoading,
        notificationMessage,
      ];
}
