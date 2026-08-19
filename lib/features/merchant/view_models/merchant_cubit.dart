import 'package:flutter_bloc/flutter_bloc.dart';
import '../../beneficiary/models/aid_card_model.dart';
import '../models/redemption_transaction_model.dart';
import 'merchant_state.dart';

class MerchantCubit extends Cubit<MerchantState> {
  MerchantCubit() : super(const MerchantState()) {
    loadInitialData();
  }

  void setTab(int index) {
    emit(state.copyWith(currentTabIndex: index));
  }

  void loadInitialData() {
    final mockTransactions = [
      RedemptionTransactionModel(
        transactionId: 'TXN-RED-481920',
        cardId: 'QOUT-CARD-784920',
        beneficiaryId: 'usr_ben_01',
        beneficiaryName: 'محمد عبد الله السعيد',
        merchantId: 'merch_01',
        merchantStoreName: 'أسواق النخبة المركزية',
        amountDeducted: 250.0,
        foodBasketsDeducted: 1,
        remainingBalance: 350.0,
        remainingBaskets: 1,
        notes: 'صرف مواد تموينية أساسية',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      RedemptionTransactionModel(
        transactionId: 'TXN-RED-481912',
        cardId: 'QOUT-CARD-554210',
        beneficiaryId: 'usr_ben_02',
        beneficiaryName: 'أم خالد العتيبي',
        merchantId: 'merch_01',
        merchantStoreName: 'أسواق النخبة المركزية',
        amountDeducted: 180.0,
        foodBasketsDeducted: 0,
        remainingBalance: 420.0,
        remainingBaskets: 2,
        notes: 'صرف حليب وحفاضات أطفال',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];

    emit(state.copyWith(recentTransactions: mockTransactions));
  }

  void onQrCodeScanned(String rawQrCode) {
    // Look up or mock parse the card from QR string
    final cardId = rawQrCode.trim();

    if (cardId.isEmpty) {
      emit(state.copyWith(errorMessage: 'merchant.invalid_card'));
      return;
    }

    // Mock resolve valid card
    final card = AidCardModel(
      cardId: cardId,
      beneficiaryId: 'usr_ben_01',
      beneficiaryName: 'محمد عبد الله السعيد',
      nationalId: '1089283746',
      familyCount: 5,
      totalBalance: 600.0,
      foodBasketsQuota: 2,
      status: AidCardStatus.active,
      expiresAt: DateTime.now().add(const Duration(days: 180)),
      securityHash: 'sha256_mock_secure_token',
    );

    emit(state.copyWith(scannedCard: card));
  }

  void redeemAid({
    required double amount,
    required int foodBaskets,
    String? notes,
  }) {
    final card = state.scannedCard;
    if (card == null) return;

    if (amount > card.totalBalance || foodBaskets > card.foodBasketsQuota) {
      emit(state.copyWith(errorMessage: 'merchant.insufficient_balance'));
      return;
    }

    final remainingBal = card.totalBalance - amount;
    final remainingBaskets = card.foodBasketsQuota - foodBaskets;

    final newTransaction = RedemptionTransactionModel(
      transactionId: 'TXN-RED-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      cardId: card.cardId,
      beneficiaryId: card.beneficiaryId,
      beneficiaryName: card.beneficiaryName,
      merchantId: 'merch_01',
      merchantStoreName: 'أسواق النخبة المركزية',
      amountDeducted: amount,
      foodBasketsDeducted: foodBaskets,
      remainingBalance: remainingBal,
      remainingBaskets: remainingBaskets,
      notes: notes ?? 'صرف إعانة تموينية',
      timestamp: DateTime.now(),
    );

    emit(state.copyWith(
      recentTransactions: [newTransaction, ...state.recentTransactions],
      todayDispensedAmount: state.todayDispensedAmount + amount,
      todayTransactionsCount: state.todayTransactionsCount + 1,
      scannedCard: null,
      successMessage: amount.toStringAsFixed(0),
    ));
  }

  void clearScannedCard() {
    emit(state.copyWith(scannedCard: null));
  }

  void clearMessages() {
    emit(state.copyWith(successMessage: null, errorMessage: null));
  }
}
