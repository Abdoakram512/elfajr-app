import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/aid_card_model.dart';
import '../view_models/beneficiary_state.dart';

abstract class BeneficiaryRemoteDataSource {
  Stream<AidCardModel?> getActiveAidCardStream({
    required String beneficiaryId,
    String? cardId,
    String? nationalId,
    String? beneficiaryName,
    String? phone,
  });
  Stream<List<BeneficiaryRedemptionItem>> getRedemptionsStream({
    required String beneficiaryId,
    String? cardId,
    String? nationalId,
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

  BeneficiaryRedemptionItem _mapRedemptionDocToItem(
    String docId,
    Map<String, dynamic> data,
  ) {
    return BeneficiaryRedemptionItem(
      transactionId: data['transactionId'] as String? ?? docId,
      merchantStoreName:
          data['merchantStoreName'] as String? ?? 'منفذ صرف معتمد',
      amountDeducted: (data['amountDeducted'] as num?)?.toDouble() ?? 0.0,
      foodBasketsDeducted: (data['foodBasketsDeducted'] as num?)?.toInt() ?? 0,
      remainingBalance: (data['remainingBalance'] as num?)?.toDouble() ?? 0.0,
      remainingBaskets: (data['remainingBaskets'] as num?)?.toInt() ?? 0,
      timestamp: _parseTimestamp(data['timestamp'] ?? data['createdAt']),
      notes: data['notes'] as String?,
    );
  }

  BeneficiaryRedemptionItem _mapBasketDistributionDocToItem(
    String docId,
    Map<String, dynamic> data,
  ) {
    return BeneficiaryRedemptionItem(
      transactionId: data['distributionId'] as String? ?? docId,
      merchantStoreName: data['distributionCenter'] as String? ??
          (data['center'] as String? ?? 'المقر الرئيسي - مركز توزيع الفجر'),
      amountDeducted: 0.0,
      foodBasketsDeducted: (data['basketsCount'] as num?)?.toInt() ??
          ((data['foodBasketsDeducted'] as num?)?.toInt() ?? 1),
      remainingBalance: (data['remainingBalance'] as num?)?.toDouble() ?? 0.0,
      remainingBaskets: (data['remainingBaskets'] as num?)?.toInt() ?? 0,
      timestamp: _parseTimestamp(data['timestamp'] ?? data['createdAt']),
      notes: data['notes'] as String? ?? 'تسليم سلة غذائية من الإدارة',
    );
  }

  @override
  Stream<AidCardModel?> getActiveAidCardStream({
    required String beneficiaryId,
    String? cardId,
    String? nationalId,
    String? beneficiaryName,
    String? phone,
  }) {
    late StreamController<AidCardModel?> controller;
    final List<StreamSubscription> subscriptions = [];

    void handleDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
      if (controller.isClosed) return;
      if (doc.exists && doc.data() != null) {
        final card = AidCardModel.fromMap(doc.data()!, documentId: doc.id);
        controller.add(card);
      }
    }

    void handleDocs(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
      if (controller.isClosed) return;
      if (docs.isNotEmpty) {
        final doc = docs.first;
        final card = AidCardModel.fromMap(doc.data(), documentId: doc.id);
        controller.add(card);
      }
    }

    controller = StreamController<AidCardModel?>.broadcast(
      onListen: () {
        // 1. Direct document listener on cardId (most direct and authoritative)
        if (cardId != null && cardId.isNotEmpty) {
          final subDoc = _firestore
              .collection('aid_cards')
              .doc(cardId)
              .snapshots()
              .listen(handleDoc, onError: (_) {});
          subscriptions.add(subDoc);

          final subCardQuery = _firestore
              .collection('aid_cards')
              .where('cardId', isEqualTo: cardId)
              .snapshots()
              .listen((snap) => handleDocs(snap.docs), onError: (_) {});
          subscriptions.add(subCardQuery);
        }

        // 2. Query by beneficiaryId
        if (beneficiaryId.isNotEmpty) {
          final subBen = _firestore
              .collection('aid_cards')
              .where('beneficiaryId', isEqualTo: beneficiaryId)
              .snapshots()
              .listen((snap) => handleDocs(snap.docs), onError: (_) {});
          subscriptions.add(subBen);
        }

        // 3. Query by nationalId
        if (nationalId != null && nationalId.isNotEmpty) {
          final subNat = _firestore
              .collection('aid_cards')
              .where('nationalId', isEqualTo: nationalId)
              .snapshots()
              .listen((snap) => handleDocs(snap.docs), onError: (_) {});
          subscriptions.add(subNat);
        }

        // 4. Query by beneficiaryName
        if (beneficiaryName != null && beneficiaryName.trim().isNotEmpty) {
          final subName = _firestore
              .collection('aid_cards')
              .where('beneficiaryName', isEqualTo: beneficiaryName.trim())
              .snapshots()
              .listen((snap) => handleDocs(snap.docs), onError: (_) {});
          subscriptions.add(subName);
        }

        // 5. Query by phone
        if (phone != null && phone.trim().isNotEmpty) {
          final subPhone = _firestore
              .collection('aid_cards')
              .where('phone', isEqualTo: phone.trim())
              .snapshots()
              .listen((snap) => handleDocs(snap.docs), onError: (_) {});
          subscriptions.add(subPhone);
        }
      },
      onCancel: () {
        for (final sub in subscriptions) {
          sub.cancel();
        }
        subscriptions.clear();
      },
    );

    return controller.stream;
  }

  @override
  Stream<List<BeneficiaryRedemptionItem>> getRedemptionsStream({
    required String beneficiaryId,
    String? cardId,
    String? nationalId,
  }) {
    late StreamController<List<BeneficiaryRedemptionItem>> controller;
    final Map<String, BeneficiaryRedemptionItem> itemsMap = {};

    final List<StreamSubscription> subscriptions = [];

    void emitMerged() {
      if (controller.isClosed) return;
      final list = itemsMap.values.toList();
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      controller.add(list);
    }

    void processRedemptionsDocs(
        List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
      for (final doc in docs) {
        final data = doc.data();
        final item = _mapRedemptionDocToItem(doc.id, data);
        itemsMap[item.transactionId] = item;
      }
      emitMerged();
    }

    void processBasketDistributionDocs(
        List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
      for (final doc in docs) {
        final data = doc.data();
        final item = _mapBasketDistributionDocToItem(doc.id, data);
        itemsMap[item.transactionId] = item;
      }
      emitMerged();
    }

    controller = StreamController<List<BeneficiaryRedemptionItem>>.broadcast(
      onListen: () {
        // 1. Redemptions Collection Queries
        if (beneficiaryId.isNotEmpty) {
          final sub = _firestore
              .collection('redemptions')
              .where('beneficiaryId', isEqualTo: beneficiaryId)
              .snapshots()
              .listen(
                (snap) => processRedemptionsDocs(snap.docs),
                onError: (err) {
                  if (!controller.isClosed) controller.addError(err);
                },
              );
          subscriptions.add(sub);
        }

        if (cardId != null && cardId.isNotEmpty) {
          final sub = _firestore
              .collection('redemptions')
              .where('cardId', isEqualTo: cardId)
              .snapshots()
              .listen(
                (snap) => processRedemptionsDocs(snap.docs),
                onError: (err) {
                  if (!controller.isClosed) controller.addError(err);
                },
              );
          subscriptions.add(sub);
        }

        // 2. Basket Distributions Collection Queries (Admin Handover)
        if (cardId != null && cardId.isNotEmpty) {
          final sub = _firestore
              .collection('basket_distributions')
              .where('cardId', isEqualTo: cardId)
              .snapshots()
              .listen(
                (snap) => processBasketDistributionDocs(snap.docs),
                onError: (err) {
                  if (!controller.isClosed) controller.addError(err);
                },
              );
          subscriptions.add(sub);
        }

        if (beneficiaryId.isNotEmpty) {
          final sub = _firestore
              .collection('basket_distributions')
              .where('beneficiaryId', isEqualTo: beneficiaryId)
              .snapshots()
              .listen(
                (snap) => processBasketDistributionDocs(snap.docs),
                onError: (_) {},
              );
          subscriptions.add(sub);
        }

        if (nationalId != null && nationalId.isNotEmpty) {
          final sub = _firestore
              .collection('basket_distributions')
              .where('nationalId', isEqualTo: nationalId)
              .snapshots()
              .listen(
                (snap) => processBasketDistributionDocs(snap.docs),
                onError: (_) {},
              );
          subscriptions.add(sub);
        }
      },
      onCancel: () {
        for (final sub in subscriptions) {
          sub.cancel();
        }
        subscriptions.clear();
      },
    );

    return controller.stream;
  }
}
