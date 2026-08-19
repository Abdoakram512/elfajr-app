import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/service_locator.dart';
import '../models/admin_merchant_item.dart';
import '../repositories/admin_repository.dart';
import 'admin_merchants_state.dart';

class AdminMerchantsCubit extends Cubit<AdminMerchantsState> {
  final AdminRepository _repository;
  StreamSubscription<List<AdminMerchantItem>>? _merchantsSubscription;

  AdminMerchantsCubit({AdminRepository? repository})
      : _repository = repository ?? getIt<AdminRepository>(),
        super(const AdminMerchantsState()) {
    initMerchantsStream();
  }

  void initMerchantsStream() {
    _merchantsSubscription?.cancel();
    _merchantsSubscription =
        _repository.getMerchantsStream().listen((merchants) {
      emit(state.copyWith(merchants: merchants));
    });
  }

  Future<void> refreshMerchants() async {
    initMerchantsStream();
    await Future.delayed(const Duration(milliseconds: 600));
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  Future<void> toggleMerchantStatus(String merchantId) async {
    final merchant = state.merchants.firstWhere(
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

    if (merchant.id.isNotEmpty) {
      final newStatus = !merchant.isActive;
      await _repository.updateMerchantStatus(merchantId, newStatus);
    }
  }

  @override
  Future<void> close() {
    _merchantsSubscription?.cancel();
    return super.close();
  }
}
