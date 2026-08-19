import '../models/aid_card_model.dart';
import '../view_models/beneficiary_state.dart';

abstract class BeneficiaryRepository {
  Stream<AidCardModel?> getActiveAidCard({
    required String beneficiaryId,
    String? cardId,
  });

  Stream<List<BeneficiaryRedemptionItem>> getRedemptionsHistory({
    required String beneficiaryId,
    String? cardId,
  });
}
