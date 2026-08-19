import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/service_locator.dart';
import '../../auth/view_models/auth_cubit.dart';
import '../../auth/view_models/auth_state.dart';
import '../models/redemption_transaction_model.dart';
import '../repositories/merchant_repository.dart';
import 'merchant_state.dart';

class MerchantCubit extends Cubit<MerchantState> {
  final MerchantRepository _repository;
  StreamSubscription<List<RedemptionTransactionModel>>? _txnsSubscription;
  StreamSubscription<Map<String, dynamic>>? _statsSubscription;

  MerchantCubit({MerchantRepository? repository})
      : _repository = repository ?? sl<MerchantRepository>(),
        super(const MerchantState()) {
    initDataStreams();
  }

  void setTab(int index) {
    emit(state.copyWith(currentTabIndex: index));
  }

  void initDataStreams() {
    final authState = sl<AuthCubit>().state;
    final user = authState is Authenticated ? authState.user : null;
    final merchantId = user?.uid ?? 'usr_merch_nokhba';

    // 1. Transactions Stream
    _txnsSubscription?.cancel();
    _txnsSubscription = _repository
        .getStoreRedemptionsStream(merchantId: merchantId)
        .listen((transactions) {
      emit(state.copyWith(recentTransactions: transactions));
    });

    // 2. Merchant Store Stats Stream from Firestore
    _statsSubscription?.cancel();
    _statsSubscription = _repository
        .getStoreStatsStream(merchantId: merchantId)
        .listen((stats) {
      emit(state.copyWith(
        todayDispensedAmount:
            (stats['totalDisbursed'] as num?)?.toDouble() ?? 0.0,
        todayTransactionsCount:
            (stats['totalTransactions'] as num?)?.toInt() ?? 0,
      ));
    });
  }

  Future<void> onQrCodeScanned(String rawQrCode) async {
    final cardId = rawQrCode.trim();

    if (cardId.isEmpty) {
      emit(state.copyWith(errorMessage: 'merchant.invalid_card'));
      return;
    }

    try {
      final card = await _repository.verifyScannedCard(cardId);
      if (card != null) {
        emit(state.copyWith(scannedCard: card));
      } else {
        emit(state.copyWith(errorMessage: 'كارت الإغاثة غير موجود أو غير صالح'));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString().replaceAll('AppException: ', '')));
    }
  }

  Future<void> redeemAid({
    required double amount,
    required int foodBaskets,
    String? notes,
  }) async {
    final card = state.scannedCard;
    if (card == null) return;

    if (amount > card.totalBalance || foodBaskets > card.foodBasketsQuota) {
      emit(state.copyWith(errorMessage: 'merchant.insufficient_balance'));
      return;
    }

    final authState = sl<AuthCubit>().state;
    final user = authState is Authenticated ? authState.user : null;

    final merchantId = user?.uid ?? 'usr_merch_nokhba';
    final storeName = user?.storeName ?? (user?.name ?? 'منفذ صرف معتمد');

    try {
      await _repository.processRedemption(
        cardId: card.cardId,
        amount: amount,
        foodBaskets: foodBaskets,
        merchantId: merchantId,
        merchantStoreName: storeName,
        notes: notes,
      );

      emit(state.copyWith(
        scannedCard: null,
        successMessage: amount.toStringAsFixed(0),
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString().replaceAll('AppException: ', '')));
    }
  }

  void clearScannedCard() {
    emit(state.copyWith(scannedCard: null));
  }

  void clearMessages() {
    emit(state.copyWith(successMessage: null, errorMessage: null));
  }

  @override
  Future<void> close() {
    _txnsSubscription?.cancel();
    _statsSubscription?.cancel();
    return super.close();
  }
}
