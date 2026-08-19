import 'package:flutter_bloc/flutter_bloc.dart';
import 'donor_state.dart';

class DonorCubit extends Cubit<DonorState> {
  DonorCubit() : super(const DonorState()) {
    loadInitialData();
  }

  void setTab(int index) {
    emit(state.copyWith(currentTabIndex: index));
  }

  void setCategory(String category) {
    emit(state.copyWith(selectedCategory: category));
  }

  void loadInitialData() {
    final mockCampaigns = [
      const CampaignItem(
        id: 'c1',
        title: 'توزيع السلال الغذائية للأسر الأشد احتياجاً',
        category: 'food',
        targetAmount: 50000.0,
        raisedAmount: 38500.0,
        location: 'الرياض، وادي لبن',
      ),
      const CampaignItem(
        id: 'c2',
        title: 'كفالة العمليات الجراحية العاجلة للأطفال',
        category: 'health',
        targetAmount: 120000.0,
        raisedAmount: 96000.0,
        location: 'جدة، مجمع الأمل الطبي',
      ),
      const CampaignItem(
        id: 'c3',
        title: 'حفر وتجهيز آبار مياه الشرب النظيفة',
        category: 'water',
        targetAmount: 35000.0,
        raisedAmount: 22000.0,
        location: 'جازان، القرى الجنوبية',
      ),
      const CampaignItem(
        id: 'c4',
        title: 'كفالة الرعاية الشاملة لـ 50 يتيماً',
        category: 'orphans',
        targetAmount: 80000.0,
        raisedAmount: 64000.0,
        location: 'مكة المكرمة',
      ),
    ];

    final mockHistory = [
      DonationHistoryItem(
        id: 'dh1',
        campaignTitle: 'توزيع السلال الغذائية للأسر الأشد احتياجاً',
        amount: 500.0,
        date: DateTime.now().subtract(const Duration(days: 2)),
        transactionId: 'TXN-984218',
      ),
      DonationHistoryItem(
        id: 'dh2',
        campaignTitle: 'كفالة العمليات الجراحية العاجلة للأطفال',
        amount: 1000.0,
        date: DateTime.now().subtract(const Duration(days: 7)),
        transactionId: 'TXN-874211',
      ),
    ];

    emit(state.copyWith(
      campaigns: mockCampaigns,
      donationHistory: mockHistory,
    ));
  }

  void donateToCampaign(String campaignId, double amount) {
    final updatedCampaigns = state.campaigns.map((c) {
      if (c.id == campaignId) {
        return CampaignItem(
          id: c.id,
          title: c.title,
          category: c.category,
          targetAmount: c.targetAmount,
          raisedAmount: c.raisedAmount + amount,
          location: c.location,
          imageUrl: c.imageUrl,
        );
      }
      return c;
    }).toList();

    final newHistoryItem = DonationHistoryItem(
      id: 'dh_${DateTime.now().millisecondsSinceEpoch}',
      campaignTitle: state.campaigns.firstWhere((c) => c.id == campaignId).title,
      amount: amount,
      date: DateTime.now(),
      transactionId: 'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
    );

    emit(state.copyWith(
      campaigns: updatedCampaigns,
      totalDonated: state.totalDonated + amount,
      casesSupported: state.casesSupported + 1,
      donationHistory: [newHistoryItem, ...state.donationHistory],
      successMessage: amount.toStringAsFixed(0),
    ));
  }

  void clearSuccessMessage() {
    emit(state.copyWith(successMessage: null));
  }
}
