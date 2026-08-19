import '../view_models/admin_state.dart';

abstract class AdminRepository {
  Stream<Map<String, dynamic>> getGlobalStatsStream();
  Stream<List<AdminRedemptionItem>> getLiveRedemptionsStream();
  Stream<List<AdminMerchantItem>> getMerchantsStream();
  Future<void> updateMerchantStatus(String merchantId, bool isActive);
}
