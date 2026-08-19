import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/errors/failure.dart';
import '../../beneficiary/models/aid_card_model.dart';
import '../models/redemption_transaction_model.dart';

abstract class MerchantRemoteDataSource {
  Future<AidCardModel?> fetchCardById(String cardId);
  Future<RedemptionTransactionModel> commitRedemption({
    required String cardId,
    required double amount,
    required int foodBaskets,
    required String merchantId,
    required String merchantStoreName,
    String? notes,
  });
  Stream<List<RedemptionTransactionModel>> getMerchantRedemptionsStream({
    required String merchantId,
  });
  Stream<Map<String, dynamic>> getMerchantStatsStream({
    required String merchantId,
  });
}

class MerchantRemoteDataSourceImpl implements MerchantRemoteDataSource {
  final FirebaseFirestore _firestore;

  MerchantRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  DateTime _parseTimestamp(dynamic val) {
    if (val == null) return DateTime.now();
    if (val is Timestamp) return val.toDate();
    if (val is DateTime) return val;
    if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
    return DateTime.now();
  }

  @override
  Future<AidCardModel?> fetchCardById(String cardId) async {
    final cleanId = cardId.trim();

    try {
      final doc = await _firestore.collection('aid_cards').doc(cleanId).get();
      if (doc.exists && doc.data() != null) {
        return AidCardModel.fromMap(doc.data()!, documentId: doc.id);
      }

      final query = await _firestore
          .collection('aid_cards')
          .where('cardId', isEqualTo: cleanId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final found = query.docs.first;
        return AidCardModel.fromMap(found.data(), documentId: found.id);
      }

      return null;
    } catch (e) {
      throw AppException('فشل في جلب بيانات كارت الإغاثة: $e');
    }
  }

  @override
  Future<RedemptionTransactionModel> commitRedemption({
    required String cardId,
    required double amount,
    required int foodBaskets,
    required String merchantId,
    required String merchantStoreName,
    String? notes,
  }) async {
    final cleanId = cardId.trim();
    final txnId =
        'TXN-RED-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    try {
      final cardRef = _firestore.collection('aid_cards').doc(cleanId);
      final cardDoc = await cardRef.get();

      if (!cardDoc.exists || cardDoc.data() == null) {
        throw const AppException('merchant.invalid_card');
      }

      final data = cardDoc.data()!;
      final currentBal = (data['totalBalance'] as num?)?.toDouble() ?? 0.0;
      final currentBaskets = (data['foodBasketsQuota'] as num?)?.toInt() ?? 0;
      final benId = data['beneficiaryId'] as String? ?? '';
      final benName = data['beneficiaryName'] as String? ?? 'مستفيد';
      final city = data['city'] as String? ?? 'الرياض';

      if (amount > currentBal || foodBaskets > currentBaskets) {
        throw const AppException('merchant.insufficient_balance');
      }

      final remBal = currentBal - amount;
      final remBaskets = currentBaskets - foodBaskets;

      final batch = _firestore.batch();

      // 1. Decrement balance on aid card
      batch.update(cardRef, {
        'totalBalance': FieldValue.increment(-amount),
        'foodBasketsQuota': FieldValue.increment(-foodBaskets),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. Increment store totals on merchant user document
      final merchantRef = _firestore.collection('users').doc(merchantId);
      batch.set(merchantRef, {
        'totalTransactions': FieldValue.increment(1),
        'totalDisbursed': FieldValue.increment(amount),
        'totalBaskets': FieldValue.increment(foodBaskets),
      }, SetOptions(merge: true));

      // 3. Increment global analytics on stats/global
      final statsRef = _firestore.collection('stats').doc('global');
      batch.set(statsRef, {
        'totalFundsDisbursed': FieldValue.increment(amount),
        'totalRedemptionsCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 4. Create record in redemptions collection
      final txnRef = _firestore.collection('redemptions').doc(txnId);
      batch.set(txnRef, {
        'transactionId': txnId,
        'cardId': cleanId,
        'beneficiaryId': benId,
        'beneficiaryName': benName,
        'merchantId': merchantId,
        'merchantStoreName': merchantStoreName,
        'amountDeducted': amount,
        'foodBasketsDeducted': foodBaskets,
        'remainingBalance': remBal,
        'remainingBaskets': remBaskets,
        'notes': notes ?? 'صرف إعانة تموينية',
        'city': city,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      return RedemptionTransactionModel(
        transactionId: txnId,
        cardId: cleanId,
        beneficiaryId: benId,
        beneficiaryName: benName,
        merchantId: merchantId,
        merchantStoreName: merchantStoreName,
        amountDeducted: amount,
        foodBasketsDeducted: foodBaskets,
        remainingBalance: remBal,
        remainingBaskets: remBaskets,
        notes: notes ?? 'صرف إعانة تموينية',
        timestamp: DateTime.now(),
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('فشل في توثيق عملية الصرف: $e');
    }
  }

  @override
  Stream<List<RedemptionTransactionModel>> getMerchantRedemptionsStream({
    required String merchantId,
  }) {
    Query query = _firestore.collection('redemptions');

    if (merchantId.isNotEmpty) {
      query = query.where('merchantId', isEqualTo: merchantId);
    }

    return query.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return RedemptionTransactionModel(
          transactionId: doc.id,
          cardId: data['cardId'] as String? ?? '',
          beneficiaryId: data['beneficiaryId'] as String? ?? '',
          beneficiaryName:
              data['beneficiaryName'] as String? ?? 'مستفيد معتمد',
          merchantId: data['merchantId'] as String? ?? merchantId,
          merchantStoreName:
              data['merchantStoreName'] as String? ?? 'منفذ صرف',
          amountDeducted: (data['amountDeducted'] as num?)?.toDouble() ?? 0.0,
          foodBasketsDeducted:
              (data['foodBasketsDeducted'] as num?)?.toInt() ?? 0,
          remainingBalance:
              (data['remainingBalance'] as num?)?.toDouble() ?? 0.0,
          remainingBaskets:
              (data['remainingBaskets'] as num?)?.toInt() ?? 0,
          notes: data['notes'] as String?,
          timestamp: _parseTimestamp(data['timestamp']),
        );
      }).toList();

      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }

  @override
  Stream<Map<String, dynamic>> getMerchantStatsStream({
    required String merchantId,
  }) {
    return _firestore.collection('users').doc(merchantId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return {
          'totalTransactions':
              (data['totalTransactions'] as num?)?.toInt() ?? 0,
          'totalDisbursed':
              (data['totalDisbursed'] as num?)?.toDouble() ?? 0.0,
          'totalBaskets': (data['totalBaskets'] as num?)?.toInt() ?? 0,
        };
      }
      return {
        'totalTransactions': 0,
        'totalDisbursed': 0.0,
        'totalBaskets': 0,
      };
    });
  }
}
