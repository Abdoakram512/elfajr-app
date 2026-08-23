import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/errors/failure.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel?> getCurrentUserData();
  Future<UserModel?> getUserDataById(String uid);
  Future<UserModel?> getUserDataByEmail(String email);
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phone,
    String? city,
    String? storeName,
    String? commercialReg,
  });
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserModel?> getCurrentUserData() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, documentId: doc.id);
      }

      if (currentUser.email != null) {
        return await getUserDataByEmail(currentUser.email!);
      }
      return null;
    } catch (e) {
      throw AppException('Failed to fetch user data: $e');
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
    final normalizedEmail = email.trim().toLowerCase();

    try {
      // 1. First look up user document directly in Firestore
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        final data = doc.data();
        final storedPassword = data['password'] as String?;

        if (storedPassword != null && storedPassword != password) {
          throw const AppException('auth_errors.wrong_password');
        }

        // Try Firebase Auth in parallel to establish session if available
        try {
          await _firebaseAuth.signInWithEmailAndPassword(
            email: normalizedEmail,
            password: password,
          );
        } catch (_) {}

        return UserModel.fromMap(data, documentId: doc.id);
      }

      // 2. If not found in direct Firestore query, attempt Firebase Auth sign in
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          return UserModel.fromMap(doc.data()!, documentId: doc.id);
        }

        return UserModel(
          uid: user.uid,
          email: user.email ?? normalizedEmail,
          name: user.displayName ?? normalizedEmail.split('@').first,
          role: UserRole.beneficiary,
          createdAt: DateTime.now(),
        );
      }

      throw const AppException('auth_errors.user_not_found');
    } on FirebaseAuthException catch (e) {
      throw AppException(_mapFirebaseAuthError(e.code));
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('auth_errors.user_not_found');
    }
  }

  @override
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phone,
    String? city,
    String? storeName,
    String? commercialReg,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    try {
      // Check if email already exists in Firestore
      final existing = await _firestore
          .collection('users')
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        throw const AppException('auth_errors.email_already_in_use');
      }

      String uid = 'usr_${DateTime.now().millisecondsSinceEpoch}';

      // Create Firebase Auth user
      try {
        final credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: normalizedEmail,
          password: password,
        );
        if (credential.user != null) {
          uid = credential.user!.uid;
          await credential.user!.updateDisplayName(name);
        }
      } catch (_) {}

      String? activeCardId;
      String? nationalId;

      final bool isAutoApproved = role == UserRole.admin;

      // Automatically provision an Aid Card if registering as a beneficiary (pending approval)
      if (role == UserRole.beneficiary) {
        final uniqueSuffix = '${DateTime.now().millisecondsSinceEpoch}'.substring(4);
        activeCardId = 'FAJR-CARD-$uniqueSuffix';
        nationalId = (phone != null && phone.trim().isNotEmpty) ? phone.trim() : 'N-$uniqueSuffix';

        final aidCardData = {
          'cardId': activeCardId,
          'beneficiaryId': uid,
          'beneficiaryName': name,
          'nationalId': nationalId,
          'familyCount': 4,
          'totalBalance': 600.0,
          'foodBasketsQuota': 2,
          'status': isAutoApproved ? 'active' : 'pending',
          'nationality': 'مصرية',
          'residence': city ?? 'القاهرة',
          'securityHash': uniqueSuffix,
          'activatedAt': DateTime.now().toIso8601String(),
          'expiresAt': DateTime.now().add(const Duration(days: 365)).toIso8601String(),
          'fieldResearchStatus':
              isAutoApproved ? 'معتمد ومسجل حديثاً' : 'قيد مراجعة الإدارة',
          'totalBasketsDelivered': 0,
          'extraNotes': 'حساب مستفيد رسمي مسجل من التطبيق',
        };

        try {
          await _firestore
              .collection('aid_cards')
              .doc(activeCardId)
              .set(aidCardData);
        } catch (e) {
          // If set fails with string date, try basic map
          await _firestore.collection('aid_cards').doc(activeCardId).set({
            'cardId': activeCardId,
            'beneficiaryId': uid,
            'beneficiaryName': name,
            'nationalId': nationalId,
            'familyCount': 4,
            'totalBalance': 600.0,
            'foodBasketsQuota': 2,
            'status': isAutoApproved ? 'active' : 'pending',
            'securityHash': uniqueSuffix,
          });
        }
      }

      final userModel = UserModel(
        uid: uid,
        email: normalizedEmail,
        name: name,
        phone: phone,
        role: role,
        city: city ?? 'القاهرة',
        isApproved: isAutoApproved,
        isActive: isAutoApproved,
        activeCardId: activeCardId,
        nationalId: nationalId,
        storeName: storeName,
        commercialReg: commercialReg,
        createdAt: DateTime.now(),
      );

      final userMap = userModel.toMap();
      userMap['password'] = password;

      await _firestore.collection('users').doc(uid).set(userMap);
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AppException(_mapFirebaseAuthError(e.code));
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('auth_errors.user_not_found');
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
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
      case 'invalid-credential':
      case 'configuration-not-found':
      case 'operation-not-allowed':
        return 'auth_errors.user_not_found';
      case 'wrong-password':
        return 'auth_errors.wrong_password';
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
