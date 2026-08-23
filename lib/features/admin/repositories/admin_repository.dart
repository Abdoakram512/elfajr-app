import '../models/admin_beneficiary_item.dart';
import '../models/admin_merchant_item.dart';
import '../models/admin_redemption_item.dart';

abstract class AdminRepository {
  Stream<Map<String, dynamic>> getGlobalStatsStream();
  Stream<List<AdminRedemptionItem>> getLiveRedemptionsStream();
  Stream<List<AdminMerchantItem>> getMerchantsStream();
  Future<void> updateMerchantStatus(String merchantId, bool isActive);
  Stream<List<AdminBeneficiaryItem>> getBeneficiariesStream();
  Future<void> updateBeneficiaryStatus(
    String beneficiaryId,
    bool isActive,
    String? cardId,
  );
}

