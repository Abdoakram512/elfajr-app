import '../../beneficiary/models/aid_card_model.dart';
import '../models/extra_disbursement_request_model.dart';
import '../models/payment_receipt_model.dart';
import '../models/redemption_transaction_model.dart';

abstract class MerchantRepository {
  Future<AidCardModel?> verifyScannedCard(String cardId);
  Future<AidCardModel?> searchCardByIdOrNationalId(String query);
  Future<RedemptionTransactionModel> processRedemption({
    required String cardId,
    required double amount,
    int foodBaskets = 0,
    required String merchantId,
    required String merchantStoreName,
    String? notes,
  });
  Stream<List<RedemptionTransactionModel>> getStoreRedemptionsStream({
    required String merchantId,
  });
  Stream<Map<String, dynamic>> getStoreStatsStream({
    required String merchantId,
  });
  Future<void> submitExtraDisbursementRequest(
    ExtraDisbursementRequestModel request,
  );
  Stream<List<PaymentReceiptModel>> streamPaymentReceipts({
    required String merchantId,
  });
  Future<void> confirmPaymentReceipt({
    required String receiptId,
    required String merchantId,
    required String adminId,
  });
}
