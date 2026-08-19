import '../data_sources/admin_remote_data_source.dart';
import '../view_models/admin_state.dart';
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
}
