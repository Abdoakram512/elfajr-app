import '../data_sources/admin_remote_data_source.dart';
import '../models/admin_beneficiary_item.dart';
import '../models/admin_merchant_item.dart';
import '../models/admin_redemption_item.dart';
import 'admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _remoteDataSource;

  AdminRepositoryImpl({
    required AdminRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Stream<Map<String, dynamic>> getGlobalStatsStream() {
    return _remoteDataSource.getGlobalStatsStream();
  }

  @override
  Stream<List<AdminRedemptionItem>> getLiveRedemptionsStream() {
    return _remoteDataSource.getLiveRedemptionsStream();
  }

  @override
  Stream<List<AdminMerchantItem>> getMerchantsStream() {
    return _remoteDataSource.getAuthorizedMerchantsStream();
  }

  @override
  Future<void> updateMerchantStatus(String merchantId, bool isActive) async {
    await _remoteDataSource.setMerchantActiveStatus(merchantId, isActive);
  }

  @override
  Stream<List<AdminBeneficiaryItem>> getBeneficiariesStream() {
    return _remoteDataSource.getRegisteredBeneficiariesStream();
  }

  @override
  Future<void> updateBeneficiaryStatus(
    String beneficiaryId,
    bool isActive,
    String? cardId,
  ) async {
    await _remoteDataSource.setBeneficiaryActiveStatus(
      beneficiaryId,
      isActive,
      cardId,
    );
  }
}

