import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/aid_card_model.dart';
import 'beneficiary_state.dart';

class BeneficiaryCubit extends Cubit<BeneficiaryState> {
  BeneficiaryCubit() : super(const BeneficiaryState()) {
    loadInitialData();
  }

  void setTab(int index) {
    emit(state.copyWith(currentTabIndex: index));
  }

  void loadInitialData() {
    final mockCard = AidCardModel(
      cardId: 'QOUT-CARD-784920',
      beneficiaryId: 'usr_ben_ahmed',
      beneficiaryName: 'أحمد سعيد الغامدي',
      nationalId: '1089283746',
      familyCount: 5,
      totalBalance: 600.0,
      foodBasketsQuota: 2,
      status: AidCardStatus.active,
      expiresAt: DateTime.now().add(const Duration(days: 180)),
      securityHash: 'sha256_mock_secure_token',
    );

    final mockRedemptions = [
      BeneficiaryRedemptionItem(
        transactionId: 'TXN-RED-481920',
        merchantStoreName: 'أسواق النخبة المركزية',
        amountDeducted: 250.0,
        foodBasketsDeducted: 1,
        remainingBalance: 350.0,
        remainingBaskets: 1,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        notes: 'صرف مواد تموينية وسلة غذائية',
      ),
      BeneficiaryRedemptionItem(
        transactionId: 'TXN-RED-410982',
        merchantStoreName: 'صيدليات الشفاء التخصصية',
        amountDeducted: 150.0,
        foodBasketsDeducted: 0,
        remainingBalance: 600.0,
        remainingBaskets: 2,
        timestamp: DateTime.now().subtract(const Duration(days: 4)),
        notes: 'صرف أدوية ومستلزمات علاجية',
      ),
    ];

    emit(state.copyWith(
      activeCard: mockCard,
      redemptions: mockRedemptions,
    ));
  }
}
