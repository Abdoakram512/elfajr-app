import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/service_locator.dart';
import '../../auth/view_models/auth_cubit.dart';
import '../../auth/view_models/auth_state.dart';
import '../models/aid_card_model.dart';
import '../repositories/beneficiary_repository.dart';
import 'beneficiary_state.dart';

class BeneficiaryCubit extends Cubit<BeneficiaryState> {
  final BeneficiaryRepository _repository;
  StreamSubscription<AidCardModel?>? _cardSubscription;
  StreamSubscription<List<BeneficiaryRedemptionItem>>? _redemptionsSubscription;

  BeneficiaryCubit({BeneficiaryRepository? repository})
      : _repository = repository ?? getIt<BeneficiaryRepository>(),
        super(const BeneficiaryState()) {
    initDataStreams();
  }

  void initDataStreams() {
    final authState = getIt<AuthCubit>().state;
    final user = authState is Authenticated ? authState.user : null;

    if (user == null) {
      debugPrint(
        '[BeneficiaryCubit] ⚠️ No authenticated user - skipping streams',
      );
      return;
    }

    final beneficiaryId = user.uid;
    final nationalId = user.nationalId;
    final beneficiaryName = user.name;
    final phone = user.phone;
    final cardId = user.activeCardId?.isNotEmpty == true
        ? user.activeCardId!
        : (beneficiaryId.startsWith('FAJR-CARD-')
            ? beneficiaryId
            : beneficiaryId.replaceFirst('usr_ben_case_', 'FAJR-CARD-'));

    debugPrint('[BeneficiaryCubit] 🔍 user.uid        = $beneficiaryId');
    debugPrint('[BeneficiaryCubit] 🔍 user.name       = $beneficiaryName');
    debugPrint('[BeneficiaryCubit] 🔍 user.nationalId = $nationalId');
    debugPrint('[BeneficiaryCubit] 🔍 derived cardId  = $cardId');

    // 1. Subscribe to Live Aid Card from Firestore across all keys
    _cardSubscription?.cancel();
    _cardSubscription = _repository
        .getActiveAidCard(
          beneficiaryId: beneficiaryId,
          cardId: cardId,
          nationalId: nationalId,
          beneficiaryName: beneficiaryName,
          phone: phone,
        )
        .listen((card) {
          debugPrint(
            '[BeneficiaryCubit] 📥 LIVE card received = ${card?.cardId} (balance=${card?.totalBalance}, baskets=${card?.foodBasketsQuota})',
          );
          if (card != null) {
            emit(state.copyWith(activeCard: card));
            final effectiveCardId =
                card.cardId.isNotEmpty ? card.cardId : cardId;
            final effectiveNatId =
                card.nationalId.isNotEmpty ? card.nationalId : nationalId;
            if (effectiveCardId != cardId) {
              _startRedemptionsSubscription(
                beneficiaryId: beneficiaryId,
                cardId: effectiveCardId,
                nationalId: effectiveNatId,
              );
            }
          }
        });

    // 2. Subscribe to Live Redemptions & Basket Distributions from Firestore
    _startRedemptionsSubscription(
      beneficiaryId: beneficiaryId,
      cardId: cardId,
      nationalId: nationalId,
    );
  }

  void _startRedemptionsSubscription({
    required String beneficiaryId,
    String? cardId,
    String? nationalId,
  }) {
    _redemptionsSubscription?.cancel();
    _redemptionsSubscription = _repository
        .getRedemptionsHistory(
          beneficiaryId: beneficiaryId,
          cardId: cardId,
          nationalId: nationalId,
        )
        .listen((redemptions) {
          debugPrint(
            '[BeneficiaryCubit] 📥 redemptions/baskets count = ${redemptions.length}',
          );
          emit(state.copyWith(redemptions: redemptions));
        });
  }

  Future<void> refreshData() async {
    initDataStreams();
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<void> close() {
    _cardSubscription?.cancel();
    _redemptionsSubscription?.cancel();
    return super.close();
  }
}
