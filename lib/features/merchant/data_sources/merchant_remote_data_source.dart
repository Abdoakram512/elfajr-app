import 'dart:async';
import '../../beneficiary/models/aid_card_model.dart';
import '../models/extra_disbursement_request_model.dart';
import '../models/payment_receipt_model.dart';
import '../models/redemption_transaction_model.dart';

/// Contract interface for Merchant remote data operations.
/// Follows Interface Segregation and Dependency Inversion principles.
abstract class MerchantRemoteDataSource {
  /// Fetches an aid card by its primary Document ID or `cardId` field.
  Future<AidCardModel?> fetchCardById(String cardId);

  /// Performs a multi-strategy search across Card ID, National ID, Phone, and Name.
  Future<AidCardModel?> searchCardByIdOrNationalId(String query);

  /// Executes an atomic, concurrency-safe redemption transaction in Firestore.
  Future<RedemptionTransactionModel> commitRedemption({
    required String cardId,
    required double amount,
    int foodBaskets = 0,
    required String merchantId,
    required String merchantStoreName,
    String? notes,
  });

  /// Realtime stream of redemption transactions for a specific merchant store.
  Stream<List<RedemptionTransactionModel>> getMerchantRedemptionsStream({
    required String merchantId,
  });

  /// Realtime stream of aggregated statistics for a specific merchant.
  Stream<Map<String, dynamic>> getMerchantStatsStream({
    required String merchantId,
  });

  /// Submits an emergency extra disbursement request to Firestore.
  Future<void> submitExtraDisbursementRequest(
    ExtraDisbursementRequestModel request,
  );

  /// Realtime stream of payment receipts sent by admin to a merchant.
  Stream<List<PaymentReceiptModel>> streamPaymentReceipts({
    required String merchantId,
  });

  /// Confirms receipt of payment transfer and logs audit record.
  Future<void> confirmPaymentReceipt({
    required String receiptId,
    required String merchantId,
    required String adminId,
  });
}
