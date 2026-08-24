import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/errors/failure.dart';
import '../models/register_params.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel?> getCurrentUserData();
  Future<UserModel?> getUserDataById(String uid);
  Future<UserModel?> getUserDataByEmail(String email);
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<UserModel> registerWithEmailAndPassword(RegisterParams params);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Stream<List<String>> streamNationalities();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<String>> streamNationalities() {
    return _firestore.collection('nationalities').snapshots().map((snap) {
      return snap.docs
          .map((d) => (d.data()['name'] ?? d.id).toString().trim())
          .where((n) => n.isNotEmpty)
          .toSet()
          .toList();
    });
  }

  @override
  Future<UserModel?> getCurrentUserData() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, documentId: doc.id);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserModel?> getUserDataById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, documentId: doc.id);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserModel?> getUserDataByEmail(String email) async {
    try {
      final normalized = email.trim().toLowerCase();
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: normalized)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        return UserModel.fromMap(doc.data(), documentId: doc.id);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final rawIdentifier = email.trim();
    final normalizedEmail = rawIdentifier.toLowerCase();

    try {
      // 1. Look up user document in Firestore by email, nationalId, activeCardId, or phone
      QuerySnapshot<Map<String, dynamic>> query = await _firestore
          .collection('users')
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        query = await _firestore
            .collection('users')
            .where('nationalId', isEqualTo: rawIdentifier)
            .limit(1)
            .get();
      }

      if (query.docs.isEmpty) {
        query = await _firestore
            .collection('users')
            .where('activeCardId', isEqualTo: rawIdentifier.toUpperCase())
            .limit(1)
            .get();
      }

      if (query.docs.isEmpty) {
        query = await _firestore
            .collection('users')
            .where('phone', isEqualTo: rawIdentifier)
            .limit(1)
            .get();
      }

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        final data = doc.data();

        // Direct Password Match
        final storedPassword = data['password']?.toString();
        if (storedPassword != null && storedPassword.isNotEmpty) {
          if (storedPassword == password) {
            return UserModel.fromMap(data, documentId: doc.id);
          } else {
            throw const AppException('auth_errors.wrong_password');
          }
        }

        // Fallback: If no plaintext password, authenticate via Firebase Auth
        final firestoreEmail = data['email']?.toString() ?? normalizedEmail;
        try {
          final credential = await _firebaseAuth.signInWithEmailAndPassword(
            email: firestoreEmail,
            password: password,
          );
          if (credential.user != null) {
            return UserModel.fromMap(data, documentId: doc.id);
          }
        } on FirebaseAuthException catch (e) {
          throw AppException(_mapFirebaseAuthError(e.code));
        }
      }

      // If document not found in Firestore query, attempt Firebase Auth as last resort
      try {
        final credential = await _firebaseAuth.signInWithEmailAndPassword(
          email: normalizedEmail,
          password: password,
        );
        if (credential.user != null) {
          final userDoc = await _firestore
              .collection('users')
              .doc(credential.user!.uid)
              .get();
          if (userDoc.exists && userDoc.data() != null) {
            return UserModel.fromMap(userDoc.data()!, documentId: userDoc.id);
          }
        }
      } on FirebaseAuthException catch (e) {
        throw AppException(_mapFirebaseAuthError(e.code));
      }

      throw const AppException('auth_errors.user_not_found');
    } on FirebaseAuthException catch (e) {
      throw AppException(_mapFirebaseAuthError(e.code));
    } on AppException {
      rethrow;
    } catch (e) {
      throw const AppException('auth_errors.user_not_found');
    }
  }

  @override
  Future<UserModel> registerWithEmailAndPassword(RegisterParams params) async {
    final cleanPhone = params.phone?.trim();
    final cleanNationalId =
        (params.nationalId != null && params.nationalId!.trim().isNotEmpty)
        ? params.nationalId!.trim().replaceAll(RegExp(r'\s+'), '').toUpperCase()
        : null;

    try {
      // 1. UNIQUE CHECK: Phone Number
      if (cleanPhone != null && cleanPhone.isNotEmpty) {
        final existingPhone = await _firestore
            .collection('users')
            .where('phone', isEqualTo: cleanPhone)
            .limit(1)
            .get();

        if (existingPhone.docs.isNotEmpty) {
          throw const AppException('auth_errors.phone_already_in_use');
        }
      }

      // 2. UNIQUE CHECK: National ID / Passport for Beneficiaries
      if (params.isBeneficiary &&
          cleanNationalId != null &&
          cleanNationalId.isNotEmpty) {
        final existingNatId = await _firestore
            .collection('users')
            .where('nationalId', isEqualTo: cleanNationalId)
            .limit(1)
            .get();

        if (existingNatId.docs.isNotEmpty) {
          throw const AppException('auth_errors.national_id_already_in_use');
        }
      }

      // Technical email for Firebase Auth
      String normalizedEmail = params.email.trim().toLowerCase();
      if (params.isBeneficiary &&
          (normalizedEmail.isEmpty || !normalizedEmail.contains('@'))) {
        normalizedEmail =
            '${cleanNationalId?.toLowerCase() ?? 'usr_${DateTime.now().millisecondsSinceEpoch}'}@alfajr.app';
      }

      // Check email uniqueness
      final existingEmail = await _firestore
          .collection('users')
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get();

      if (existingEmail.docs.isNotEmpty) {
        if (params.isBeneficiary) {
          throw const AppException('auth_errors.national_id_already_in_use');
        } else {
          throw const AppException('auth_errors.email_already_in_use');
        }
      }

      String uid = 'usr_${DateTime.now().millisecondsSinceEpoch}';

      // Create Firebase Auth user
      try {
        final credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: normalizedEmail,
          password: params.password,
        );
        if (credential.user != null) {
          uid = credential.user!.uid;
          await credential.user!.updateDisplayName(params.name);
        }
      } catch (_) {}

      String? activeCardId;
      String? finalNationalId = cleanNationalId;
      final bool isAutoApproved = params.isAdmin;

      // Automatically provision Aid Card for Beneficiaries
      if (params.isBeneficiary) {
        final uniqueSuffix = '${DateTime.now().millisecondsSinceEpoch}'
            .substring(4);
        activeCardId = 'FAJR-CARD-$uniqueSuffix';
        finalNationalId = cleanNationalId ?? 'N-$uniqueSuffix';

        final aidCardData = {
          'cardId': activeCardId,
          'beneficiaryId': uid,
          'beneficiaryName': params.name,
          'nationalId': finalNationalId,
          'familyCount': 4,
          'totalBalance': 600.0,
          'balance': 600.0,
          'foodBasketsQuota': 2,
          'quota': 2,
          'status': isAutoApproved ? 'active' : 'pending',
          'nationality': params.nationality ?? 'مصري',
          'residence': params.city ?? 'القاهرة',
          'securityHash': uniqueSuffix,
          'activatedAt': DateTime.now().toIso8601String(),
          'expiresAt': DateTime.now()
              .add(const Duration(days: 365))
              .toIso8601String(),
          'fieldResearchStatus': isAutoApproved
              ? 'معتمد ومسجل حديثاً'
              : 'قيد مراجعة الإدارة',
          'totalBasketsDelivered': 0,
          'extraNotes': 'حساب مستفيد رسمي مسجل من التطبيق',
        };

        try {
          await _firestore
              .collection('aid_cards')
              .doc(activeCardId)
              .set(aidCardData);
        } catch (_) {}
      }

      final userModel = UserModel(
        uid: uid,
        email: normalizedEmail,
        name: params.name,
        phone: cleanPhone,
        role: params.role,
        city: params.city ?? 'القاهرة',
        isApproved: isAutoApproved,
        isActive: isAutoApproved,
        activeCardId: activeCardId,
        nationalId: finalNationalId,
        nationality: params.nationality,
        storeName: params.storeName,
        commercialReg: params.commercialReg,
        createdAt: DateTime.now(),
      );

      final userMap = userModel.toMap();
      userMap['password'] = params.password;

      await _firestore.collection('users').doc(uid).set(userMap);
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AppException(_mapFirebaseAuthError(e.code));
    } on AppException {
      rethrow;
    } catch (e) {
      throw const AppException('auth_errors.user_not_found');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (_) {}
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AppException(_mapFirebaseAuthError(e.code));
    }
  }

  String _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'auth_errors.user_not_found';
      case 'email-already-in-use':
        return 'auth_errors.email_already_in_use';
      case 'invalid-email':
        return 'auth_errors.invalid_email';
      case 'weak-password':
        return 'auth_errors.weak_password';
      default:
        return 'auth_errors.user_not_found';
    }
  }
}
