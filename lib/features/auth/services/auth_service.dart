import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  Future<UserModel?> getCurrentUserData() async {
    final user = currentFirebaseUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
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
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('User credential is null.');
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, documentId: doc.id);
      } else {
        // Fallback default user model if firestore document was not found
        final defaultUser = UserModel(
          uid: user.uid,
          email: user.email ?? email,
          name: user.displayName ?? 'User',
          role: UserRole.donor,
          createdAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(user.uid).set(defaultUser.toMap());
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
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Failed to create user.');
      }

      // Update Firebase Auth display name
      await user.updateDisplayName(name.trim());

      // Volunteers start as isApproved: false until reviewed
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

      // Save user profile in Firestore
      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
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
