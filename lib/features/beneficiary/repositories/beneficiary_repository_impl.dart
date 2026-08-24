import '../data_sources/beneficiary_remote_data_source.dart';
import '../models/aid_card_model.dart';
import '../view_models/beneficiary_state.dart';
import 'beneficiary_repository.dart';

class BeneficiaryRepositoryImpl implements BeneficiaryRepository {
  final BeneficiaryRemoteDataSource _remoteDataSource;

  BeneficiaryRepositoryImpl({
    required BeneficiaryRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Stream<AidCardModel?> getActiveAidCard({
    required String beneficiaryId,
    String? cardId,
    String? nationalId,
    String? beneficiaryName,
    String? phone,
  }) {
    return _remoteDataSource.getActiveAidCardStream(
      beneficiaryId: beneficiaryId,
      cardId: cardId,
      nationalId: nationalId,
      beneficiaryName: beneficiaryName,
      phone: phone,
    );
  }

  @override
  Stream<List<BeneficiaryRedemptionItem>> getRedemptionsHistory({
    required String beneficiaryId,
    String? cardId,
    String? nationalId,
  }) {
    return _remoteDataSource.getRedemptionsStream(
      beneficiaryId: beneficiaryId,
      cardId: cardId,
      nationalId: nationalId,
    );
  }
}
