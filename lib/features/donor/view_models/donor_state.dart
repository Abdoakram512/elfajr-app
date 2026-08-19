import 'package:equatable/equatable.dart';

class CampaignItem extends Equatable {
  final String id;
  final String title;
  final String category;
  final double targetAmount;
  final double raisedAmount;
  final String location;
  final String? imageUrl;

  const CampaignItem({
    required this.id,
    required this.title,
    required this.category,
    required this.targetAmount,
    required this.raisedAmount,
    required this.location,
    this.imageUrl,
  });

  double get progress => (raisedAmount / targetAmount).clamp(0.0, 1.0);
  double get remaining => (targetAmount - raisedAmount).clamp(0.0, double.infinity);
  int get progressPercent => (progress * 100).toInt();

  @override
  List<Object?> get props => [
        id,
        title,
        category,
        targetAmount,
        raisedAmount,
        location,
        imageUrl,
      ];
}

class DonationHistoryItem extends Equatable {
  final String id;
  final String campaignTitle;
  final double amount;
  final DateTime date;
  final String transactionId;

  const DonationHistoryItem({
    required this.id,
    required this.campaignTitle,
    required this.amount,
    required this.date,
    required this.transactionId,
  });

  @override
  List<Object?> get props => [id, campaignTitle, amount, date, transactionId];
}

class DonorState extends Equatable {
  final int currentTabIndex;
  final String selectedCategory;
  final double totalDonated;
  final int casesSupported;
  final List<CampaignItem> campaigns;
  final List<DonationHistoryItem> donationHistory;
  final bool isLoading;
  final String? successMessage;

  const DonorState({
    this.currentTabIndex = 0,
    this.selectedCategory = 'all',
    this.totalDonated = 12500.0,
    this.casesSupported = 18,
    this.campaigns = const [],
    this.donationHistory = const [],
    this.isLoading = false,
    this.successMessage,
  });

  DonorState copyWith({
    int? currentTabIndex,
    String? selectedCategory,
    double? totalDonated,
    int? casesSupported,
    List<CampaignItem>? campaigns,
    List<DonationHistoryItem>? donationHistory,
    bool? isLoading,
    String? successMessage,
  }) {
    return DonorState(
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      totalDonated: totalDonated ?? this.totalDonated,
      casesSupported: casesSupported ?? this.casesSupported,
      campaigns: campaigns ?? this.campaigns,
      donationHistory: donationHistory ?? this.donationHistory,
      isLoading: isLoading ?? this.isLoading,
      successMessage: successMessage,
    );
  }

  List<CampaignItem> get filteredCampaigns {
    if (selectedCategory == 'all') return campaigns;
    return campaigns.where((c) => c.category == selectedCategory).toList();
  }

  @override
  List<Object?> get props => [
        currentTabIndex,
        selectedCategory,
        totalDonated,
        casesSupported,
        campaigns,
        donationHistory,
        isLoading,
        successMessage,
      ];
}
