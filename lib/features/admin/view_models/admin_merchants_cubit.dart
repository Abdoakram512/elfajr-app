import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/service_locator.dart';
import '../models/admin_beneficiary_item.dart';
import '../models/admin_merchant_item.dart';
import '../repositories/admin_repository.dart';
import 'admin_merchants_state.dart';

class AdminMerchantsCubit extends Cubit<AdminMerchantsState> {
  final AdminRepository _repository;
  StreamSubscription<List<AdminMerchantItem>>? _merchantsSubscription;
  StreamSubscription<List<AdminBeneficiaryItem>>? _beneficiariesSubscription;

  AdminMerchantsCubit({AdminRepository? repository})
      : _repository = repository ?? getIt<AdminRepository>(),
        super(const AdminMerchantsState()) {
    initStreams();
  }

  void initStreams() {
    _merchantsSubscription?.cancel();
    _merchantsSubscription =
        _repository.getMerchantsStream().listen((merchants) {
      emit(state.copyWith(merchants: merchants));
    });

    _beneficiariesSubscription?.cancel();
    _beneficiariesSubscription =
        _repository.getBeneficiariesStream().listen((beneficiaries) {
      emit(state.copyWith(beneficiaries: beneficiaries));
    });
  }

  Future<void> refreshData() async {
    initStreams();
    await Future.delayed(const Duration(milliseconds: 600));
  }

  void setSegment(int segment) {
    emit(state.copyWith(selectedSegment: segment));
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

  Future<void> toggleBeneficiaryStatus(String beneficiaryId, String? cardId) async {
    final beneficiary = state.beneficiaries.firstWhere(
      (b) => b.id == beneficiaryId,
      orElse: () => AdminBeneficiaryItem(
        id: '',
        name: '',
        email: '',
        phone: '',
        city: '',
        cardId: '',
        isApproved: false,
        isActive: false,
        createdAt: DateTime.now(),
      ),
    );

    if (beneficiary.id.isNotEmpty) {
      final newStatus = !beneficiary.isActive;
      await _repository.updateBeneficiaryStatus(
        beneficiaryId,
        newStatus,
        cardId ?? beneficiary.cardId,
      );
    }
  }

  @override
  Future<void> close() {
    _merchantsSubscription?.cancel();
    _beneficiariesSubscription?.cancel();
    return super.close();
  }
}

