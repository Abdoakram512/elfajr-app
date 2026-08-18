import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';

class AuthService {
  final FirebaseAuth? _authOverride;
  final FirebaseFirestore? _firestoreOverride;

  AuthService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _authOverride = firebaseAuth,
        _firestoreOverride = firestore;

  bool get isFirebaseInitialized => Firebase.apps.isNotEmpty;

  FirebaseAuth? get _firebaseAuth {
    if (_authOverride != null) return _authOverride;
    if (isFirebaseInitialized) {
      return FirebaseAuth.instance;
    }
    return null;
  }

  FirebaseFirestore? get _firestore {
    if (_firestoreOverride != null) return _firestoreOverride;
    if (isFirebaseInitialized) {
      return FirebaseFirestore.instance;
    }
    return null;
  }

  User? get currentFirebaseUser => _firebaseAuth?.currentUser;

  Future<UserModel?> getCurrentUserData() async {
    final auth = _firebaseAuth;
    final store = _firestore;

    if (auth == null || store == null) {
      debugPrint('Firebase is not initialized yet. Running in offline UI mode.');
      return null;
    }

    final user = auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await store.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, documentId: doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user data: $e');
    }
  }

  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final auth = _firebaseAuth;
    final store = _firestore;

    if (auth == null || store == null) {
      // Demo / Mock fallback if Firebase config is not connected yet
      debugPrint('Firebase not connected. Simulating demo login for testing.');
      return UserModel(
        uid: 'demo_user_123',
        email: email.trim(),
        name: email.split('@').first,
        role: UserRole.donor,
        createdAt: DateTime.now(),
      );
    }

    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('User credential is null.');
      }

      final doc = await store.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, documentId: doc.id);
      } else {
        final defaultUser = UserModel(
          uid: user.uid,
          email: user.email ?? email,
          name: user.displayName ?? 'User',
          role: UserRole.donor,
          createdAt: DateTime.now(),
        );
        await store.collection('users').doc(user.uid).set(defaultUser.toMap());
        return defaultUser;
      }
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phone,
    String? city,
    String? extraDetails,
  }) async {
    final auth = _firebaseAuth;
    final store = _firestore;

    if (auth == null || store == null) {
      // Demo / Mock fallback if Firebase config is not connected yet
      debugPrint('Firebase not connected. Simulating demo registration for testing.');
      return UserModel(
        uid: 'demo_user_new',
        email: email.trim(),
        name: name.trim(),
        phone: phone?.trim(),
        role: role,
        isApproved: role != UserRole.volunteer,
        city: city?.trim(),
        extraDetails: extraDetails?.trim(),
        createdAt: DateTime.now(),
      );
    }

    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Failed to create user.');
      }

      await user.updateDisplayName(name.trim());

      final isApproved = role != UserRole.volunteer;

      final userModel = UserModel(
        uid: user.uid,
        email: email.trim(),
        name: name.trim(),
        phone: phone?.trim(),
        role: role,
        isApproved: isApproved,
        city: city?.trim(),
        extraDetails: extraDetails?.trim(),
        createdAt: DateTime.now(),
      );

      await store.collection('users').doc(user.uid).set(userModel.toMap());
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    final auth = _firebaseAuth;
    if (auth == null) {
      debugPrint('Firebase not connected. Simulating reset email.');
      return;
    }

    try {
      await auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> signOut() async {
    final auth = _firebaseAuth;
    if (auth != null) {
      await auth.signOut();
    }
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'auth_errors.user_not_found';
      case 'wrong-password':
        return 'auth_errors.wrong_password';
      case 'email-already-in-use':
        return 'auth_errors.email_already_in_use';
      case 'invalid-email':
        return 'auth_errors.invalid_email';
      case 'weak-password':
        return 'auth_errors.weak_password';
      case 'user-disabled':
        return 'auth_errors.user_disabled';
      case 'too-many-requests':
        return 'auth_errors.too_many_requests';
      default:
        return e.message ?? 'auth_errors.unknown_error';
    }
  }
}
