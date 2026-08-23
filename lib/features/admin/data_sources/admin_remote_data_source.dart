import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qout/features/admin/models/admin_beneficiary_item.dart';
import '../models/admin_merchant_item.dart';
import '../models/admin_redemption_item.dart';

abstract class AdminRemoteDataSource {
  Stream<Map<String, dynamic>> getGlobalStatsStream();
  Stream<List<AdminRedemptionItem>> getLiveRedemptionsStream();
  Stream<List<AdminMerchantItem>> getAuthorizedMerchantsStream();
  Future<void> setMerchantActiveStatus(String merchantId, bool isActive);
  Stream<List<AdminBeneficiaryItem>> getRegisteredBeneficiariesStream();
  Future<void> setBeneficiaryActiveStatus(
    String beneficiaryId,
    bool isActive,
    String? cardId,
  );
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final FirebaseFirestore _firestore;

  AdminRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  DateTime _parseTimestamp(dynamic val) {
    if (val == null) return DateTime.now();
    if (val is Timestamp) return val.toDate();
    if (val is DateTime) return val;
    if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
    return DateTime.now();
  }

  @override
  Stream<Map<String, dynamic>> getGlobalStatsStream() {
    return _firestore.collection('stats').doc('global').snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return {
          'totalFundsDisbursed':
              (data['totalFundsDisbursed'] as num?)?.toDouble() ?? 0.0,
          'totalBeneficiariesCount':
              (data['totalBeneficiariesCount'] as num?)?.toInt() ?? 0,
          'activeMerchantsCount':
              (data['activeMerchantsCount'] as num?)?.toInt() ?? 0,
          'totalRedemptionsCount':
              (data['totalRedemptionsCount'] as num?)?.toInt() ?? 0,
        };
      }
      return {
        'totalFundsDisbursed': 0.0,
        'totalBeneficiariesCount': 0,
        'activeMerchantsCount': 0,
        'totalRedemptionsCount': 0,
      };
    });
  }

  @override
  Stream<List<AdminRedemptionItem>> getLiveRedemptionsStream() {
    return _firestore
        .collection('redemptions')
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs.map((doc) {
        final data = doc.data();
        return AdminRedemptionItem(
          id: doc.id,
          beneficiaryName: data['beneficiaryName'] as String? ?? 'مستفيد',
          cardId: data['cardId'] as String? ?? '-',
          merchantName: data['merchantStoreName'] as String? ?? 'منفذ صرف',
          amount: (data['amountDeducted'] as num?)?.toDouble() ?? 0.0,
          foodBaskets: (data['foodBasketsDeducted'] as num?)?.toInt() ?? 0,
          city: data['city'] as String? ?? 'الرياض',
          timestamp: _parseTimestamp(data['timestamp']),
        );
      }).toList();

      items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return items;
    });
  }

  @override
  Stream<List<AdminMerchantItem>> getAuthorizedMerchantsStream() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'merchant')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return AdminMerchantItem(
          id: doc.id,
          name: data['storeName'] as String? ??
              (data['name'] as String? ?? 'منفذ معتمد'),
          storeType: 'سوبرماركت وتموينات معتمدة',
          city: data['city'] as String? ?? 'الرياض',
          commercialReg: data['commercialReg'] as String? ?? '-',
          totalTransactions:
              (data['totalTransactions'] as num?)?.toInt() ?? 0,
          totalDisbursed:
              (data['totalDisbursed'] as num?)?.toDouble() ?? 0.0,
          isActive: data['isActive'] as bool? ??
              (data['isApproved'] as bool? ?? false),
        );
      }).toList();
    });
  }

  @override
  Stream<List<AdminBeneficiaryItem>> getRegisteredBeneficiariesStream() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'beneficiary')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return AdminBeneficiaryItem(
          id: doc.id,
          name: data['name'] as String? ?? 'مستفيد',
          email: data['email'] as String? ?? '-',
          phone: data['phone'] as String? ?? '-',
          city: data['city'] as String? ?? 'القاهرة',
          cardId: data['activeCardId'] as String? ?? '-',
          isApproved: data['isApproved'] as bool? ?? false,
          isActive: data['isActive'] as bool? ?? false,
          createdAt: _parseTimestamp(data['createdAt']),
        );
      }).toList();
    });
  }

  @override
  Future<void> setMerchantActiveStatus(String merchantId, bool isActive) async {
    await _firestore.collection('users').doc(merchantId).set({
      'isActive': isActive,
      'isApproved': isActive,
    }, SetOptions(merge: true));
  }

  @override
  Future<void> setBeneficiaryActiveStatus(
    String beneficiaryId,
    bool isActive,
    String? cardId,
  ) async {
    await _firestore.collection('users').doc(beneficiaryId).set({
      'isActive': isActive,
      'isApproved': isActive,
    }, SetOptions(merge: true));

    if (cardId != null && cardId.isNotEmpty && cardId != '-') {
      await _firestore.collection('aid_cards').doc(cardId).set({
        'status': isActive ? 'active' : 'pending',
      }, SetOptions(merge: true));
    }
  }
}
