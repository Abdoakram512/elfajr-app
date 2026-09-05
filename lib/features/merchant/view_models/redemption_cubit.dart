import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/service_locator.dart';
import '../../auth/view_models/auth_cubit.dart';
import '../../auth/view_models/auth_state.dart';
import '../../beneficiary/models/aid_card_model.dart';
import '../repositories/merchant_repository.dart';
import 'redemption_state.dart';

class RedemptionCubit extends Cubit<RedemptionState> {
  final MerchantRepository _repository;

  RedemptionCubit({MerchantRepository? repository})
    : _repository = repository ?? getIt<MerchantRepository>(),
      super(const RedemptionInitial());

  Future<void> onQrCodeScanned(String rawQrCode) async {
    final cardId = rawQrCode.trim();
    if (cardId.isEmpty) {
      emit(const RedemptionFailure('merchant.invalid_card'));
      return;
    }

    emit(const RedemptionSearching());

    try {
      final card = await _repository.verifyScannedCard(cardId);
      if (card != null) {
        emit(RedemptionCardLoaded(card: card));
      } else {
        emit(const RedemptionFailure('merchant.card_not_registered'));
      }
    } catch (e) {
      emit(RedemptionFailure(e.toString().replaceAll('AppException: ', '')));
    }
  }

  Future<void> searchCardManual(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) {
      emit(const RedemptionFailure('merchant.search_query_empty'));
      return;
    }

    emit(const RedemptionSearching());

    try {
      final card = await _repository.searchCardByIdOrNationalId(clean);
      if (card != null) {
        emit(RedemptionCardLoaded(card: card));
      } else {
        emit(const RedemptionFailure('merchant.card_not_found'));
      }
    } catch (e) {
      emit(RedemptionFailure(e.toString().replaceAll('AppException: ', '')));
    }
  }

  void loadCard(AidCardModel card) {
    emit(RedemptionCardLoaded(card: card));
  }

  Future<bool> confirmRedemption({
    required double amount,
    int foodBaskets = 0,
    String? notes,
  }) async {
    final currentState = state;
    AidCardModel? currentCard;

    if (currentState is RedemptionCardLoaded) {
      currentCard = currentState.card;
    } else if (currentState is RedemptionFailure && currentState.card != null) {
      currentCard = currentState.card;
    }

    if (currentCard == null) {
      emit(const RedemptionFailure('merchant.invalid_card'));
      return false;
    }

    if (currentCard.hasRedeemedInCurrentMonth) {
      emit(
        RedemptionFailure(
          'merchant.monthly_quota_already_redeemed',
          card: currentCard,
        ),
      );
      return false;
    }

    if (amount <= 0) {
      emit(
        RedemptionCardLoaded(
          card: currentCard,
          amountError: 'merchant.enter_deduction_amount',
        ),
      );
      return false;
    }

    if (amount > currentCard.totalBalance) {
      emit(
        RedemptionCardLoaded(
          card: currentCard,
          amountError: 'merchant.insufficient_balance',
        ),
      );
      return false;
    }

    emit(RedemptionSubmitting(currentCard));

    final authState = getIt<AuthCubit>().state;
    final user = authState is Authenticated ? authState.user : null;
    final merchantId = user?.uid ?? 'usr_merch_nokhba';
    final storeName = user?.storeName ?? (user?.name ?? 'منفذ صرف معتمد');

    try {
      final txn = await _repository.processRedemption(
        cardId: currentCard.cardId,
        amount: amount,
        foodBaskets: foodBaskets,
        merchantId: merchantId,
        merchantStoreName: storeName,
        notes: notes,
      );

      emit(RedemptionSuccess(transaction: txn, card: currentCard));
      return true;
    } catch (e) {
      emit(
        RedemptionFailure(
          e.toString().replaceAll('AppException: ', ''),
          card: currentCard,
        ),
      );
      return false;
    }
  }

  void reset() {
    emit(const RedemptionInitial());
  }
}
