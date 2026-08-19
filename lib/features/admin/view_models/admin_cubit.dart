import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/service_locator.dart';
import '../repositories/admin_repository.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final AdminRepository _repository;
  StreamSubscription<Map<String, dynamic>>? _statsSubscription;
  StreamSubscription<List<AdminRedemptionItem>>? _redemptionsSubscription;
  StreamSubscription<List<AdminMerchantItem>>? _merchantsSubscription;

  AdminCubit({AdminRepository? repository})
      : _repository = repository ?? sl<AdminRepository>(),
        super(const AdminState()) {
    initDataStreams();
  }

  void setTab(int index) {
    emit(state.copyWith(currentTabIndex: index));
  }

  void initDataStreams() {
    // 1. Live Stats from Firestore (stats/global)
    _statsSubscription?.cancel();
    _statsSubscription = _repository.getGlobalStatsStream().listen((stats) {
      emit(state.copyWith(
        totalFundsDisbursed: stats['totalFundsDisbursed'] as double? ?? 0.0,
        totalBeneficiariesCount: stats['totalBeneficiariesCount'] as int? ?? 0,
        activeMerchantsCount: stats['activeMerchantsCount'] as int? ?? 0,
        totalRedemptionsCount: stats['totalRedemptionsCount'] as int? ?? 0,
      ));
    });

    // 2. Live Redemptions Stream from Firestore
    _redemptionsSubscription?.cancel();
    _redemptionsSubscription = _repository
        .getLiveRedemptionsStream()
        .listen((redemptions) {
      emit(state.copyWith(recentRedemptions: redemptions));
    });

    // 3. Live Merchants Stream from Firestore
    _merchantsSubscription?.cancel();
    _merchantsSubscription = _repository
        .getMerchantsStream()
        .listen((merchants) {
      emit(state.copyWith(
        merchants: merchants,
        activeMerchantsCount: merchants.where((m) => m.isActive).length,
      ));
    });
  }

  Future<void> toggleMerchantStatus(String merchantId) async {
    final currentMerchant = state.merchants.firstWhere(
      (m) => m.id == merchantId,
      orElse: () => const AdminMerchantItem(
        id: '',
        name: '',
        storeType: '',
        city: '',
        commercialReg: '',
        totalTransactions: 0,
        totalDisbursed: 0,
        isActive: true,
      ),
    );

    if (currentMerchant.id.isNotEmpty) {
      final newStatus = !currentMerchant.isActive;
      await _repository.updateMerchantStatus(merchantId, newStatus);
    }
  }

  void clearNotification() {
    emit(state.copyWith(notificationMessage: null));
  }

  @override
  Future<void> close() {
    _statsSubscription?.cancel();
    _redemptionsSubscription?.cancel();
    _merchantsSubscription?.cancel();
    return super.close();
  }
}
