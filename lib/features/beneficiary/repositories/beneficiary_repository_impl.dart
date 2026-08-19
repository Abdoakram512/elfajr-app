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
  }) {
    return _remoteDataSource.getActiveAidCardStream(
      beneficiaryId: beneficiaryId,
      cardId: cardId,
    );
  }

  @override
  Stream<List<BeneficiaryRedemptionItem>> getRedemptionsHistory({
    required String beneficiaryId,
    String? cardId,
  }) {
    return _remoteDataSource.getRedemptionsStream(
      beneficiaryId: beneficiaryId,
      cardId: cardId,
    );
  }
}
