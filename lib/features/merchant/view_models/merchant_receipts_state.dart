import 'package:equatable/equatable.dart';
import '../models/payment_receipt_model.dart';

enum MerchantReceiptsStatus { initial, loading, success, failure }

class MerchantReceiptsState extends Equatable {
  final MerchantReceiptsStatus status;
  final List<PaymentReceiptModel> receipts;
  final String? confirmingReceiptId;
  final String? errorMessage;
  final String? successMessage;

  const MerchantReceiptsState({
    this.status = MerchantReceiptsStatus.initial,
    this.receipts = const [],
    this.confirmingReceiptId,
    this.errorMessage,
    this.successMessage,
  });

  int get pendingCount => receipts.where((r) => r.isPending).length;
  double get totalConfirmed =>
      receipts.where((r) => r.isConfirmed).fold(0.0, (acc, r) => acc + r.amount);
  double get totalPending =>
      receipts.where((r) => r.isPending).fold(0.0, (acc, r) => acc + r.amount);

  MerchantReceiptsState copyWith({
    MerchantReceiptsStatus? status,
    List<PaymentReceiptModel>? receipts,
    String? confirmingReceiptId,
    bool clearConfirmingId = false,
    String? errorMessage,
    String? successMessage,
  }) {
    return MerchantReceiptsState(
      status: status ?? this.status,
      receipts: receipts ?? this.receipts,
      confirmingReceiptId: clearConfirmingId
          ? null
          : (confirmingReceiptId ?? this.confirmingReceiptId),
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        receipts,
        confirmingReceiptId,
        errorMessage,
        successMessage,
      ];
}
