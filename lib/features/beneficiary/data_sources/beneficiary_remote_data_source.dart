import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/aid_card_model.dart';
import '../view_models/beneficiary_state.dart';

abstract class BeneficiaryRemoteDataSource {
  Stream<AidCardModel?> getActiveAidCardStream({
    required String beneficiaryId,
    String? cardId,
  });
  Stream<List<BeneficiaryRedemptionItem>> getRedemptionsStream({
    required String beneficiaryId,
    String? cardId,
  });
}

class BeneficiaryRemoteDataSourceImpl implements BeneficiaryRemoteDataSource {
  final FirebaseFirestore _firestore;

  BeneficiaryRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  DateTime _parseTimestamp(dynamic val) {
    if (val == null) return DateTime.now();
    if (val is Timestamp) return val.toDate();
    if (val is DateTime) return val;
    if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
    return DateTime.now();
  }

  @override
  Stream<AidCardModel?> getActiveAidCardStream({
    required String beneficiaryId,
    String? cardId,
  }) {
    if (cardId != null && cardId.isNotEmpty) {
      return _firestore.collection('aid_cards').doc(cardId).snapshots().map((doc) {
        if (doc.exists && doc.data() != null) {
          return AidCardModel.fromMap(doc.data()!, documentId: doc.id);
        }
        return null;
      });
    }

    return _firestore
        .collection('aid_cards')
        .where('beneficiaryId', isEqualTo: beneficiaryId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return AidCardModel.fromMap(doc.data(), documentId: doc.id);
      }
      return null;
    });
  }

  @override
  Stream<List<BeneficiaryRedemptionItem>> getRedemptionsStream({
    required String beneficiaryId,
    String? cardId,
  }) {
    Query query = _firestore.collection('redemptions');

    if (cardId != null && cardId.isNotEmpty) {
      query = query.where('cardId', isEqualTo: cardId);
    } else if (beneficiaryId.isNotEmpty) {
      query = query.where('beneficiaryId', isEqualTo: beneficiaryId);
    }

    return query.snapshots().map((snapshot) {
      final items = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return BeneficiaryRedemptionItem(
          transactionId: doc.id,
          merchantStoreName: data['merchantStoreName'] as String? ?? 'منفذ صرف معتمد',
          amountDeducted: (data['amountDeducted'] as num?)?.toDouble() ?? 0.0,
          foodBasketsDeducted: (data['foodBasketsDeducted'] as num?)?.toInt() ?? 0,
          remainingBalance: (data['remainingBalance'] as num?)?.toDouble() ?? 0.0,
          remainingBaskets: (data['remainingBaskets'] as num?)?.toInt() ?? 0,
          timestamp: _parseTimestamp(data['timestamp']),
          notes: data['notes'] as String?,
        );
      }).toList();

      items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return items;
    });
  }
}
