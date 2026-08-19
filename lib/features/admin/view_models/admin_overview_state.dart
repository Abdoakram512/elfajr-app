import 'package:equatable/equatable.dart';
import '../models/admin_redemption_item.dart';

class AdminOverviewState extends Equatable {
  final double totalFundsDisbursed;
  final int totalBeneficiariesCount;
  final int activeMerchantsCount;
  final int totalRedemptionsCount;
  final List<AdminRedemptionItem> recentRedemptions;
  final bool isLoading;
  final String? errorMessage;

  const AdminOverviewState({
    this.totalFundsDisbursed = 0.0,
    this.totalBeneficiariesCount = 0,
    this.activeMerchantsCount = 0,
    this.totalRedemptionsCount = 0,
    this.recentRedemptions = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  AdminOverviewState copyWith({
    double? totalFundsDisbursed,
    int? totalBeneficiariesCount,
    int? activeMerchantsCount,
    int? totalRedemptionsCount,
    List<AdminRedemptionItem>? recentRedemptions,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AdminOverviewState(
      totalFundsDisbursed: totalFundsDisbursed ?? this.totalFundsDisbursed,
      totalBeneficiariesCount:
          totalBeneficiariesCount ?? this.totalBeneficiariesCount,
      activeMerchantsCount: activeMerchantsCount ?? this.activeMerchantsCount,
      totalRedemptionsCount:
          totalRedemptionsCount ?? this.totalRedemptionsCount,
      recentRedemptions: recentRedemptions ?? this.recentRedemptions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        totalFundsDisbursed,
        totalBeneficiariesCount,
        activeMerchantsCount,
        totalRedemptionsCount,
        recentRedemptions,
        isLoading,
        errorMessage,
      ];
}
