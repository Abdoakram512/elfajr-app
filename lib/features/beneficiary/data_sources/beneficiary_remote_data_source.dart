import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../merchant/models/redemption_transaction_model.dart';
import '../models/aid_card_model.dart';
import '../models/basket_distribution_model.dart';
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

  BeneficiaryRedemptionItem _mapRedemptionDocToItem(
    String docId,
    Map<String, dynamic> data,
  ) {
    final model =
        RedemptionTransactionModel.fromMap(data, documentId: docId);
    return BeneficiaryRedemptionItem(
      transactionId: model.transactionId,
      merchantStoreName: model.merchantStoreName.isNotEmpty
          ? model.merchantStoreName
          : 'منفذ صرف معتمد',
      amountDeducted: model.amountDeducted,
      foodBasketsDeducted: model.foodBasketsDeducted,
      remainingBalance: model.remainingBalance,
      remainingBaskets: model.remainingBaskets,
      timestamp: model.timestamp,
      notes: model.notes,
    );
  }

  BeneficiaryRedemptionItem _mapBasketDistributionDocToItem(
    String docId,
    Map<String, dynamic> data,
  ) {
    final model =
        BasketDistributionModel.fromMap(data, documentId: docId);
    return BeneficiaryRedemptionItem(
      transactionId: model.distributionId,
      merchantStoreName: model.distributionCenter,
      amountDeducted: 0.0,
      foodBasketsDeducted: model.basketsCount,
      remainingBalance: 0.0,
      remainingBaskets: model.remainingBasketsAfter,
      timestamp: model.timestamp,
      notes: model.notes ?? 'تسليم سلة غذائية من الإدارة',
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

    Future<void> autoSyncMonthlyQuota(
      AidCardModel card,
      DocumentReference<Map<String, dynamic>> docRef,
    ) async {
      if (card.status != AidCardStatus.active) return;
      final now = DateTime.now();
      final currentCycle = '${now.year}-${now.month.toString().padLeft(2, '0')}';

      if (card.lastMonthlyCycle == currentCycle) return;

      try {
        final newBalance = card.totalBalance + 30.0;
        final newQuota = card.foodBasketsQuota + 1;
        final nowIso = now.toIso8601String();

        await docRef.update({
          'balance': newBalance,
          'totalBalance': newBalance,
          'foodBasketsQuota': newQuota,
          'lastMonthlyCycle': currentCycle,
          'lastRechargedAt': nowIso,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (card.beneficiaryId.isNotEmpty) {
          await _firestore.collection('users').doc(card.beneficiaryId).update({
            'balance': newBalance,
            'totalBalance': newBalance,
            'foodBasketsQuota': newQuota,
            'lastMonthlyCycle': currentCycle,
            'lastRechargedAt': nowIso,
          });
        }
      } catch (_) {
        // Silently catch to avoid disrupting stream
      }
    }

    void handleDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
      if (controller.isClosed) return;
      if (doc.exists && doc.data() != null) {
        final card = AidCardModel.fromMap(doc.data()!, documentId: doc.id);
        controller.add(card);
        autoSyncMonthlyQuota(card, doc.reference);
      }
    }

    void handleDocs(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
      if (controller.isClosed) return;
      if (docs.isNotEmpty) {
        final doc = docs.first;
        final card = AidCardModel.fromMap(doc.data(), documentId: doc.id);
        controller.add(card);
        autoSyncMonthlyQuota(card, doc.reference);
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
