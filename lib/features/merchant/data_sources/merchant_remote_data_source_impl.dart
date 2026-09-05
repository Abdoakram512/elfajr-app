import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../beneficiary/models/aid_card_model.dart';
import '../models/extra_disbursement_request_model.dart';
import '../models/payment_receipt_model.dart';
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
          'allocatedBudget': (data['allocatedBudget'] as num?)?.toDouble() ??
              (data['budget'] as num?)?.toDouble() ??
              0.0,
        };
      }
      return {
        'totalTransactions': 0,
        'totalDisbursed': 0.0,
        'totalBaskets': 0,
        'allocatedBudget': 0.0,
      };
    });
  }

  @override
  Future<void> submitExtraDisbursementRequest(
    ExtraDisbursementRequestModel request,
  ) async {
    final docId = request.requestId.isNotEmpty
        ? request.requestId
        : 'REQ-${DateTime.now().millisecondsSinceEpoch}';
    await _firestore
        .collection('extra_disbursement_requests')
        .doc(docId)
        .set(request.toMap());
  }

  @override
  Stream<List<PaymentReceiptModel>> streamPaymentReceipts({
    required String merchantId,
  }) {
    final cleanMerchantId = merchantId.trim();
    if (cleanMerchantId.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('payment_receipts')
        .where('merchantId', isEqualTo: cleanMerchantId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => PaymentReceiptModel.fromMap(doc.data(), documentId: doc.id))
          .toList();
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }

  @override
  Future<void> confirmPaymentReceipt({
    required String receiptId,
    required String merchantId,
    required String adminId,
  }) async {
    final batch = _firestore.batch();
    final receiptRef = _firestore.collection('payment_receipts').doc(receiptId);

    batch.update(receiptRef, {
      'status': 'confirmed_by_merchant',
      'isConfirmed': true,
      'confirmedAt': FieldValue.serverTimestamp(),
    });

    final logRef = _firestore.collection('audit_logs').doc();
    batch.set(logRef, {
      'action': 'CONFIRM_PAYMENT_RECEIPT',
      'receiptId': receiptId,
      'merchantId': merchantId,
      'performedBy': merchantId,
      'adminId': adminId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Dispatch real-time notification document
    final notifRef = _firestore.collection('notifications').doc();
    batch.set(notifRef, {
      'id': notifRef.id,
      'userId': merchantId,
      'recipientRole': 'merchant',
      'title': 'تم تأكيد استلام الحوالة بنجاح ✅',
      'body': 'تم توثيق وتأكيد استلام الحوالة المالية ونقلها إلى سجل المعاملات المؤكدة',
      'type': 'payment_receipt',
      'referenceId': receiptId,
      'isRead': false,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 4. Safe Data Mappers
  // ───────────────────────────────────────────────────────────────────────────

  RedemptionTransactionModel _mapDocToRedemptionTransaction(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return RedemptionTransactionModel.fromMap(
      doc.data(),
      documentId: doc.id,
    );
  }
}
