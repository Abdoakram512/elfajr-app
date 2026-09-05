import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/errors/failure.dart';
import '../../../core/utils/app_validators.dart';
import '../../../core/utils/arabic_normalizer.dart';
import '../models/redemption_transaction_model.dart';

/// Dedicated processor responsible exclusively for executing atomic, concurrency-safe redemption transactions.
/// Follows Single Responsibility Principle (SRP).
class MerchantRedemptionProcessor {
  final FirebaseFirestore _firestore;

  static const String _cardsCollection = 'aid_cards';
  static const String _usersCollection = 'users';
  static const String _redemptionsCollection = 'redemptions';
  static const String _statsCollection = 'stats';
  static const String _globalStatsDoc = 'global';

  const MerchantRedemptionProcessor({required FirebaseFirestore firestore})
      : _firestore = firestore;

  /// Executes an atomic, concurrency-safe redemption transaction in Firestore.
  Future<RedemptionTransactionModel> executeRedemption({
    required String cardId,
    required double amount,
    int foodBaskets = 0,
    required String merchantId,
    required String merchantStoreName,
    String? notes,
  }) async {
    // ── 1. Input Sanitization & Pre-validation (Guard Pattern) ──
    AppValidators.guardRedemptionInput(
      cardId: cardId,
      merchantId: merchantId,
      amount: amount,
      foodBaskets: foodBaskets,
    );

    final cleanId = ArabicNormalizer.convertDigits(cardId);
    final cleanMerchantId = merchantId.trim();
    final cleanStoreName = merchantStoreName.trim().isEmpty ? 'منفذ صرف معتمد' : merchantStoreName.trim();
    final operationNotes = notes?.trim().isNotEmpty == true ? notes!.trim() : 'صرف مشتريات مواد أساسية';

    // ── 2. Pre-transaction Reference Resolution ──
    final cardRef = await _resolveCardDocReference(cleanId);

    // Generate a collision-free unique transaction ID outside transaction for retry safety
    final txnDocRef = _firestore.collection(_redemptionsCollection).doc();
    final txnId = 'TXN-RED-${txnDocRef.id}';
    final merchantRef = _firestore.collection(_usersCollection).doc(cleanMerchantId);
    final statsRef = _firestore.collection(_statsCollection).doc(_globalStatsDoc);

    try {
      // ── 3. Atomic Firestore Transaction (Prevents Race Conditions & Double-Spending) ──
      return await _firestore.runTransaction<RedemptionTransactionModel>((transaction) async {
        // [READ PHASE] All reads must be executed prior to any writes
        final cardSnapshot = await transaction.get(cardRef);

        if (!cardSnapshot.exists || cardSnapshot.data() == null) {
          throw const AppException('merchant.invalid_card');
        }

        final cardData = cardSnapshot.data()!;
        final cardStatus = cardData['status'] as String?;
        if (cardStatus != null && cardStatus != 'active') {
          throw const AppException('merchant.invalid_card');
        }

        final currentBalance = (cardData['balance'] as num?)?.toDouble() ??
            ((cardData['totalBalance'] as num?)?.toDouble() ?? 0.0);
        final currentBaskets = (cardData['foodBasketsQuota'] as num?)?.toInt() ??
            ((cardData['quota'] as num?)?.toInt() ?? 0);

        final lastRedeemedCycle = cardData['lastRedeemedMonthCycle'] as String?;
        final lastRedemptionDateRaw = cardData['lastCashRedemptionDate'];
        final now = DateTime.now();
        final currentCycle = '${now.year}-${now.month.toString().padLeft(2, '0')}';

        // Check if beneficiary has already redeemed in the current monthly cycle
        if (lastRedeemedCycle == currentCycle) {
          throw const AppException('merchant.monthly_quota_already_redeemed');
        }

        if (lastRedemptionDateRaw != null) {
          DateTime? lastDate;
          if (lastRedemptionDateRaw is Timestamp) {
            lastDate = lastRedemptionDateRaw.toDate();
          } else if (lastRedemptionDateRaw is String) {
            lastDate = DateTime.tryParse(lastRedemptionDateRaw);
          }
          if (lastDate != null && lastDate.year == now.year && lastDate.month == now.month) {
            throw const AppException('merchant.monthly_quota_already_redeemed');
          }
        }

        // Strict Balance & Quota Validation inside Transaction
        if (amount > currentBalance || foodBaskets > currentBaskets) {
          throw const AppException('merchant.insufficient_balance');
        }

        final remainingBalance = currentBalance - amount;
        final remainingBaskets = currentBaskets - foodBaskets;
        final canonicalCardId = cardData['cardId'] as String? ?? cardSnapshot.id;
        final benId = cardData['beneficiaryId'] as String? ?? '';
        final benName = cardData['beneficiaryName'] as String? ?? 'مستفيد معتمد';
        final benNationalId = cardData['nationalId'] as String? ?? '';
        final city = cardData['residence'] as String? ?? (cardData['city'] as String? ?? 'الرياض');

        // [WRITE PHASE] Atomic updates committed together
        // 1. Decrement balance and record redemption cycle on aid card
        transaction.update(cardRef, {
          'totalBalance': remainingBalance,
          'balance': remainingBalance,
          'foodBasketsQuota': remainingBaskets,
          'quota': remainingBaskets,
          'lastRedeemedMonthCycle': currentCycle,
          'lastCashRedemptionDate': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // 2. Increment store totals on merchant document
        transaction.set(merchantRef, {
          'totalTransactions': FieldValue.increment(1),
          'totalDisbursed': FieldValue.increment(amount),
          'totalBaskets': FieldValue.increment(foodBaskets),
        }, SetOptions(merge: true));

        // 3. Increment global metrics
        transaction.set(statsRef, {
          'totalFundsDisbursed': FieldValue.increment(amount),
          'totalRedemptionsCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // 4. Create immutable audit record in redemptions collection
        transaction.set(txnDocRef, {
          'transactionId': txnId,
          'cardId': canonicalCardId,
          'cardDocId': cardSnapshot.id,
          'beneficiaryId': benId,
          'beneficiaryName': benName,
          'beneficiaryNationalId': benNationalId,
          'merchantId': cleanMerchantId,
          'merchantStoreName': cleanStoreName,
          'amountDeducted': amount,
          'foodBasketsDeducted': foodBaskets,
          'remainingBalance': remainingBalance,
          'remainingBaskets': remainingBaskets,
          'notes': operationNotes,
          'city': city,
          'timestamp': FieldValue.serverTimestamp(),
        });

        return RedemptionTransactionModel(
          transactionId: txnId,
          cardId: canonicalCardId,
          beneficiaryId: benId,
          beneficiaryName: benName,
          merchantId: cleanMerchantId,
          merchantStoreName: cleanStoreName,
          amountDeducted: amount,
          foodBasketsDeducted: foodBaskets,
          remainingBalance: remainingBalance,
          remainingBaskets: remainingBaskets,
          notes: operationNotes,
          timestamp: DateTime.now(),
        );
      });
    } on AppException {
      rethrow;
    } on FirebaseException catch (e) {
      throw _handleFirebaseException('توثيق عملية الصرف', e);
    } catch (e) {
      throw AppException('فشل في توثيق عملية الصرف: $e');
    }
  }

  Future<DocumentReference<Map<String, dynamic>>> _resolveCardDocReference(String cleanId) async {
    final directRef = _firestore.collection(_cardsCollection).doc(cleanId);
    final directSnap = await directRef.get();

    if (directSnap.exists) {
      return directRef;
    }

    final query = await _firestore
        .collection(_cardsCollection)
        .where('cardId', isEqualTo: cleanId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.reference;
    }

    throw const AppException('merchant.invalid_card');
  }

  AppException _handleFirebaseException(String context, FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return const AppException('ليس لديك الصلاحية الكافية لتنفيذ هذا الإجراء.');
      case 'unavailable':
      case 'network-request-failed':
        return const AppException('فشل الاتصال بقاعدة البيانات. يرجى التحقق من اتصال الإنترنت.');
      case 'deadline-exceeded':
        return const AppException('انتهت مهلة الطلب، يرجى المحاولة مرة أخرى.');
      default:
        return AppException('فشل في $context: ${e.message ?? e.code}');
    }
  }
}
