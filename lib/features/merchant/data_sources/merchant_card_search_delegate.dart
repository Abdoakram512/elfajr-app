import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/errors/failure.dart';
import '../../../core/utils/arabic_normalizer.dart';
import '../../beneficiary/models/aid_card_model.dart';

/// Dedicated delegate responsible exclusively for multi-vector card search operations.
/// Follows Single Responsibility Principle (SRP).
class MerchantCardSearchDelegate {
  final FirebaseFirestore _firestore;

  static const String _cardsCollection = 'aid_cards';
  static const String _usersCollection = 'users';

  const MerchantCardSearchDelegate({required FirebaseFirestore firestore})
      : _firestore = firestore;

  /// Fetches an aid card by its primary Document ID or `cardId` field.
  Future<AidCardModel?> fetchCardById(String cardId) async {
    final cleanId = ArabicNormalizer.convertDigits(cardId);
    if (cleanId.isEmpty) return null;

    try {
      // 1. Direct Document ID lookup (Fastest O(1) single-read)
      final doc = await _firestore.collection(_cardsCollection).doc(cleanId).get();
      if (doc.exists && doc.data() != null) {
        return AidCardModel.fromMap(doc.data()!, documentId: doc.id);
      }

      // 2. Query by cardId field (Exact match)
      final byField = await _findCardByField('cardId', cleanId);
      if (byField != null) return byField;

      // 3. Case-insensitive variant if contains latin characters
      final upperClean = cleanId.toUpperCase();
      if (cleanId != upperClean) {
        final byUpper = await _findCardByField('cardId', upperClean);
        if (byUpper != null) return byUpper;
      }

      return null;
    } on FirebaseException catch (e) {
      throw _handleFirebaseException('جلب بيانات الكارت', e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('فشل في جلب بيانات كارت المستفيد: $e');
    }
  }

  /// Performs a multi-strategy search across Card ID, National ID, Phone, and Name.
  Future<AidCardModel?> searchCardByIdOrNationalId(String query) async {
    final clean = ArabicNormalizer.convertDigits(query);
    if (clean.isEmpty) return null;

    try {
      // ── Strategy 1: Search by Card ID & Prefixes ──
      final cardById = await _searchByCardId(clean);
      if (cardById != null) return cardById;

      // ── Strategy 2: Search by National ID (Cards & Users) ──
      final cardByNat = await _searchByNationalId(clean);
      if (cardByNat != null) return cardByNat;

      // ── Strategy 3: Search by Phone Variations (Users & Cards) ──
      final cardByPhone = await _searchByPhone(clean);
      if (cardByPhone != null) return cardByPhone;

      // ── Strategy 4: Search by Beneficiary Name ──
      final cardByName = await _searchByName(clean);
      if (cardByName != null) return cardByName;

      return null;
    } on FirebaseException catch (e) {
      throw _handleFirebaseException('البحث عن المستفيد', e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('فشل في البحث عن كارت المستفيد: $e');
    }
  }

  Future<AidCardModel?> _searchByCardId(String clean) async {
    final direct = await fetchCardById(clean);
    if (direct != null) return direct;

    const prefixes = ['QOUT-CARD-', 'FAJR-CARD-', 'CRD-'];
    final upper = clean.toUpperCase();
    for (final prefix in prefixes) {
      if (!upper.startsWith(prefix)) {
        final withPrefix = await fetchCardById('$prefix$clean');
        if (withPrefix != null) return withPrefix;
      }
    }
    return null;
  }

  Future<AidCardModel?> _searchByNationalId(String clean) async {
    // 1. Direct query in aid_cards collection
    final cardInCards = await _findCardByField('nationalId', clean);
    if (cardInCards != null) return cardInCards;

    // 2. Query in users collection
    final userQuery = await _firestore
        .collection(_usersCollection)
        .where('nationalId', isEqualTo: clean)
        .limit(1)
        .get();

    if (userQuery.docs.isNotEmpty) {
      final uDoc = userQuery.docs.first;
      final uData = uDoc.data();
      return _findCardForUser(uDoc.id, uData['activeCardId'] as String?);
    }

    return null;
  }

  Future<AidCardModel?> _searchByPhone(String clean) async {
    final variations = ArabicNormalizer.generatePhoneVariations(clean);

    for (final phone in variations) {
      // 1. Search in users collection by 'phone' or 'phoneNumber'
      final userByPhone = await _findUserByFields(['phone', 'phoneNumber'], phone);
      if (userByPhone != null) {
        final card = await _findCardForUser(
          userByPhone.id,
          userByPhone.data()['activeCardId'] as String?,
        );
        if (card != null) return card;
      }

      // 2. Search in aid_cards collection by 'phone' or 'beneficiaryPhone'
      for (final field in ['phone', 'beneficiaryPhone']) {
        final card = await _findCardByField(field, phone);
        if (card != null) return card;
      }
    }

    return null;
  }

  Future<AidCardModel?> _searchByName(String clean) async {
    final cardByName = await _findCardByField('beneficiaryName', clean);
    if (cardByName != null) return cardByName;

    final userQuery = await _firestore
        .collection(_usersCollection)
        .where('name', isEqualTo: clean)
        .limit(1)
        .get();

    if (userQuery.docs.isNotEmpty) {
      final uDoc = userQuery.docs.first;
      return _findCardForUser(uDoc.id, uDoc.data()['activeCardId'] as String?);
    }

    return null;
  }

  Future<AidCardModel?> _findCardForUser(String userId, String? activeCardId) async {
    if (activeCardId != null && activeCardId.isNotEmpty) {
      final card = await fetchCardById(activeCardId);
      if (card != null) return card;
    }
    return _findCardByField('beneficiaryId', userId);
  }

  Future<AidCardModel?> _findCardByField(String field, dynamic value) async {
    final query = await _firestore
        .collection(_cardsCollection)
        .where(field, isEqualTo: value)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      final data = doc.data();
      return AidCardModel.fromMap(data, documentId: doc.id);
    }
    return null;
  }

  Future<QueryDocumentSnapshot<Map<String, dynamic>>?> _findUserByFields(
    List<String> fields,
    dynamic value,
  ) async {
    for (final field in fields) {
      final query = await _firestore
          .collection(_usersCollection)
          .where(field, isEqualTo: value)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        return query.docs.first;
      }
    }
    return null;
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
