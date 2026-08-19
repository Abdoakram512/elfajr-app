import 'dart:async';
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
      : _repository = repository ?? sl<BeneficiaryRepository>(),
        super(const BeneficiaryState()) {
    initDataStreams();
  }

  void setTab(int index) {
    emit(state.copyWith(currentTabIndex: index));
  }

  void initDataStreams() {
    final authState = sl<AuthCubit>().state;
    final user = authState is Authenticated ? authState.user : null;

    final beneficiaryId = user?.uid ?? 'usr_ben_ahmed';
    final cardId = user?.activeCardId ?? 'QOUT-CARD-784920';

    // 1. Subscribe to Live Aid Card from Firestore
    _cardSubscription?.cancel();
    _cardSubscription = _repository
        .getActiveAidCard(beneficiaryId: beneficiaryId, cardId: cardId)
        .listen((card) {
      if (card != null) {
        emit(state.copyWith(activeCard: card));
      }
    });

    // 2. Subscribe to Live Redemptions from Firestore
    _redemptionsSubscription?.cancel();
    _redemptionsSubscription = _repository
        .getRedemptionsHistory(beneficiaryId: beneficiaryId, cardId: cardId)
        .listen((redemptions) {
      emit(state.copyWith(redemptions: redemptions));
    });
  }

  @override
  Future<void> close() {
    _cardSubscription?.cancel();
    _redemptionsSubscription?.cancel();
    return super.close();
  }
}
