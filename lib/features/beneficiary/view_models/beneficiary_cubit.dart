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
      debugPrint('[BeneficiaryCubit] ⚠️ No authenticated user - skipping streams');
      return;
    }

    final beneficiaryId = user.uid;
    final cardId = user.activeCardId?.isNotEmpty == true
        ? user.activeCardId!
        : beneficiaryId.replaceFirst('usr_ben_case_', 'QOUT-CARD-');

    debugPrint('[BeneficiaryCubit] 🔍 user.uid       = $beneficiaryId');
    debugPrint('[BeneficiaryCubit] 🔍 user.activeCardId = ${user.activeCardId}');
    debugPrint('[BeneficiaryCubit] 🔍 derived cardId = $cardId');

    // 1. Subscribe to Live Aid Card from Firestore
    _cardSubscription?.cancel();
    _cardSubscription = _repository
        .getActiveAidCard(beneficiaryId: beneficiaryId, cardId: cardId)
        .listen((card) {
          debugPrint('[BeneficiaryCubit] 📥 card received = ${card?.cardId} (null=${card == null})');
          if (card != null) {
            emit(state.copyWith(activeCard: card));
          }
        });

    // 2. Subscribe to Live Redemptions from Firestore
    _redemptionsSubscription?.cancel();
    _redemptionsSubscription = _repository
        .getRedemptionsHistory(beneficiaryId: beneficiaryId, cardId: cardId)
        .listen((redemptions) {
          debugPrint('[BeneficiaryCubit] 📥 redemptions count = ${redemptions.length}');
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
