import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../beneficiary/models/aid_card_model.dart';
import '../models/redemption_transaction_model.dart';
import 'merchant_card_search_delegate.dart';
import 'merchant_redemption_processor.dart';
import 'merchant_remote_data_source.dart';

/// Facade implementation of [MerchantRemoteDataSource].
/// Orchestrates specialized delegates ([MerchantCardSearchDelegate], [MerchantRedemptionProcessor])
/// and exposes realtime reactive streams.
class MerchantRemoteDataSourceImpl implements MerchantRemoteDataSource {
  final FirebaseFirestore _firestore;
  final MerchantCardSearchDelegate _searchDelegate;
  final MerchantRedemptionProcessor _redemptionProcessor;

  static const String _usersCollection = 'users';
  static const String _redemptionsCollection = 'redemptions';

  MerchantRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    MerchantCardSearchDelegate? searchDelegate,
    MerchantRedemptionProcessor? redemptionProcessor,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _searchDelegate = searchDelegate ??
            MerchantCardSearchDelegate(
              firestore: firestore ?? FirebaseFirestore.instance,
            ),
        _redemptionProcessor = redemptionProcessor ??
            MerchantRedemptionProcessor(
              firestore: firestore ?? FirebaseFirestore.instance,
            );

  // ───────────────────────────────────────────────────────────────────────────
  // 1. Delegated Card Searching (MerchantCardSearchDelegate)
  // ───────────────────────────────────────────────────────────────────────────

  @override
  Future<AidCardModel?> fetchCardById(String cardId) {
    return _searchDelegate.fetchCardById(cardId);
  }

  @override
  Future<AidCardModel?> searchCardByIdOrNationalId(String query) {
    return _searchDelegate.searchCardByIdOrNationalId(query);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 2. Delegated Atomic Redemption (MerchantRedemptionProcessor)
  // ───────────────────────────────────────────────────────────────────────────

  @override
  Future<RedemptionTransactionModel> commitRedemption({
    required String cardId,
    required double amount,
    int foodBaskets = 0,
    required String merchantId,
    required String merchantStoreName,
    String? notes,
  }) {
    return _redemptionProcessor.executeRedemption(
      cardId: cardId,
      amount: amount,
      foodBaskets: foodBaskets,
      merchantId: merchantId,
      merchantStoreName: merchantStoreName,
      notes: notes,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 3. Realtime Reactive Streams
  // ───────────────────────────────────────────────────────────────────────────

  @override
  Stream<List<RedemptionTransactionModel>> getMerchantRedemptionsStream({
    required String merchantId,
  }) {
    final cleanMerchantId = merchantId.trim();
    Query<Map<String, dynamic>> query = _firestore.collection(_redemptionsCollection);

    if (cleanMerchantId.isNotEmpty) {
      query = query.where('merchantId', isEqualTo: cleanMerchantId);
    }

    return query.snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => _mapDocToRedemptionTransaction(doc))
          .toList();

      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }

  @override
  Stream<Map<String, dynamic>> getMerchantStatsStream({
    required String merchantId,
  }) {
    final cleanMerchantId = merchantId.trim();
    if (cleanMerchantId.isEmpty) {
      return Stream.value({
        'totalTransactions': 0,
        'totalDisbursed': 0.0,
        'totalBaskets': 0,
      });
    }

    return _firestore
        .collection(_usersCollection)
        .doc(cleanMerchantId)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return {
          'totalTransactions': (data['totalTransactions'] as num?)?.toInt() ?? 0,
          'totalDisbursed': (data['totalDisbursed'] as num?)?.toDouble() ?? 0.0,
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

  // ───────────────────────────────────────────────────────────────────────────
  // 4. Safe Data Mappers
  // ───────────────────────────────────────────────────────────────────────────

  RedemptionTransactionModel _mapDocToRedemptionTransaction(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return RedemptionTransactionModel(
      transactionId: doc.id,
      cardId: data['cardId'] as String? ?? '',
      beneficiaryId: data['beneficiaryId'] as String? ?? '',
      beneficiaryName: data['beneficiaryName'] as String? ?? 'مستفيد معتمد',
      merchantId: data['merchantId'] as String? ?? '',
      merchantStoreName: data['merchantStoreName'] as String? ?? 'منفذ صرف',
      amountDeducted: (data['amountDeducted'] as num?)?.toDouble() ?? 0.0,
      foodBasketsDeducted: (data['foodBasketsDeducted'] as num?)?.toInt() ?? 0,
      remainingBalance: (data['remainingBalance'] as num?)?.toDouble() ?? 0.0,
      remainingBaskets: (data['remainingBaskets'] as num?)?.toInt() ?? 0,
      notes: data['notes'] as String?,
      timestamp: _parseTimestamp(data['timestamp']),
    );
  }

  DateTime _parseTimestamp(dynamic val) {
    if (val == null) return DateTime.now();
    if (val is Timestamp) return val.toDate();
    if (val is DateTime) return val;
    if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
    return DateTime.now();
  }
}
