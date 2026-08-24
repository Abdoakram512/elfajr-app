import '../../beneficiary/models/aid_card_model.dart';
import '../data_sources/merchant_remote_data_source.dart';
import '../models/extra_disbursement_request_model.dart';
import '../models/payment_receipt_model.dart';
import '../models/redemption_transaction_model.dart';
import 'merchant_repository.dart';

class MerchantRepositoryImpl implements MerchantRepository {
  final MerchantRemoteDataSource _remoteDataSource;

  MerchantRepositoryImpl({
    required MerchantRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<AidCardModel?> verifyScannedCard(String cardId) async {
    return await _remoteDataSource.fetchCardById(cardId);
  }

  @override
  Future<AidCardModel?> searchCardByIdOrNationalId(String query) async {
    return await _remoteDataSource.searchCardByIdOrNationalId(query);
  }

  @override
  Future<RedemptionTransactionModel> processRedemption({
    required String cardId,
    required double amount,
    int foodBaskets = 0,
    required String merchantId,
    required String merchantStoreName,
    String? notes,
  }) async {
    return await _remoteDataSource.commitRedemption(
      cardId: cardId,
      amount: amount,
      foodBaskets: foodBaskets,
      merchantId: merchantId,
      merchantStoreName: merchantStoreName,
      notes: notes,
    );
  }

  @override
  Stream<List<RedemptionTransactionModel>> getStoreRedemptionsStream({
    required String merchantId,
  }) {
    return _remoteDataSource.getMerchantRedemptionsStream(
      merchantId: merchantId,
    );
  }

  @override
  Stream<Map<String, dynamic>> getStoreStatsStream({
    required String merchantId,
  }) {
    return _remoteDataSource.getMerchantStatsStream(
      merchantId: merchantId,
    );
  }

  @override
  Future<void> submitExtraDisbursementRequest(
    ExtraDisbursementRequestModel request,
  ) async {
    await _remoteDataSource.submitExtraDisbursementRequest(request);
  }

  @override
  Stream<List<PaymentReceiptModel>> streamPaymentReceipts({
    required String merchantId,
  }) {
    return _remoteDataSource.streamPaymentReceipts(
      merchantId: merchantId,
    );
  }

  @override
  Future<void> confirmPaymentReceipt({
    required String receiptId,
    required String merchantId,
    required String adminId,
  }) async {
    await _remoteDataSource.confirmPaymentReceipt(
      receiptId: receiptId,
      merchantId: merchantId,
      adminId: adminId,
    );
  }
}
