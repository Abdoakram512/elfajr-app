import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/service_locator.dart';
import '../../auth/view_models/auth_cubit.dart';
import '../../auth/view_models/auth_state.dart';
import '../models/redemption_transaction_model.dart';
import '../repositories/merchant_repository.dart';
import 'merchant_dashboard_state.dart';

class MerchantDashboardCubit extends Cubit<MerchantDashboardState> {
  final MerchantRepository _repository;
  StreamSubscription<List<RedemptionTransactionModel>>? _txnsSubscription;
  StreamSubscription<Map<String, dynamic>>? _statsSubscription;

  MerchantDashboardCubit({MerchantRepository? repository})
      : _repository = repository ?? getIt<MerchantRepository>(),
        super(const MerchantDashboardState()) {
    initDataStreams();
  }

  void initDataStreams() {
    final authState = getIt<AuthCubit>().state;
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

  Future<void> refreshData() async {
    initDataStreams();
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<void> close() {
    _txnsSubscription?.cancel();
    _statsSubscription?.cancel();
    return super.close();
  }
}
