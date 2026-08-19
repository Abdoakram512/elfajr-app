import '../../beneficiary/models/aid_card_model.dart';
import '../models/redemption_transaction_model.dart';

abstract class MerchantRepository {
  Future<AidCardModel?> verifyScannedCard(String cardId);
  Future<AidCardModel?> searchCardByIdOrNationalId(String query);
  Future<RedemptionTransactionModel> processRedemption({
    required String cardId,
    required double amount,
    required int foodBaskets,
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
}
