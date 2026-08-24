import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/service_locator.dart';
import '../../auth/view_models/auth_cubit.dart';
import '../../auth/view_models/auth_state.dart';
import '../repositories/merchant_repository.dart';
import 'merchant_receipts_state.dart';

class MerchantReceiptsCubit extends Cubit<MerchantReceiptsState> {
  final MerchantRepository _repository;
  StreamSubscription? _receiptsSubscription;

  MerchantReceiptsCubit({
    MerchantRepository? repository,
  })  : _repository = repository ?? getIt<MerchantRepository>(),
        super(const MerchantReceiptsState()) {
    _initStream();
  }

  void _initStream() {
    final authState = getIt<AuthCubit>().state;
    if (authState is Authenticated && authState.user.uid.isNotEmpty) {
      final merchantId = authState.user.uid;
      _receiptsSubscription?.cancel();
      emit(state.copyWith(status: MerchantReceiptsStatus.loading));
      _receiptsSubscription = _repository
          .streamPaymentReceipts(merchantId: merchantId)
          .listen(
            (receipts) {
              emit(state.copyWith(
                status: MerchantReceiptsStatus.success,
                receipts: receipts,
              ));
            },
            onError: (error) {
              emit(state.copyWith(
                status: MerchantReceiptsStatus.failure,
                errorMessage: error.toString(),
              ));
            },
          );
    }
  }

  Future<void> confirmReceipt({
    required String receiptId,
    required String adminId,
  }) async {
    final authState = getIt<AuthCubit>().state;
    if (authState is! Authenticated) return;
    final merchantId = authState.user.uid;

    emit(state.copyWith(confirmingReceiptId: receiptId));
    try {
      await _repository.confirmPaymentReceipt(
        receiptId: receiptId,
        merchantId: merchantId,
        adminId: adminId,
      );
      emit(state.copyWith(
        clearConfirmingId: true,
        successMessage: 'merchant.receipts.confirm_success',
      ));
    } catch (e) {
      emit(state.copyWith(
        clearConfirmingId: true,
        errorMessage: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    _receiptsSubscription?.cancel();
    return super.close();
  }
}
