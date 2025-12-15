import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../config/firebase_config.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current User
  User? get currentUser => _auth.currentUser;

  // Auth State Listener
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ==========================
  // SIGN UP (EMAIL & PASSWORD)
  // ==========================
  Future<String?> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel userModel = UserModel(
        userId: userCredential.user!.uid,
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userCredential.user!.uid)
          .set(userModel.toMap());

      await userCredential.user!.updateDisplayName(fullName);

      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } catch (e) {
      return 'Terjadi kesalahan: ${e.toString()}';
    }
  }

  // ==========================
  // SIGN IN (EMAIL & PASSWORD)
  // ==========================
  Future<String?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userCredential.user!.uid)
          .update({
        'lastLogin': Timestamp.fromDate(DateTime.now()),
      });

      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } catch (e) {
      return 'Terjadi kesalahan: ${e.toString()}';
    }
  }

  // ==========
  // LOGOUT
  // ==========
  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }

  // ==================
  // RESET PASSWORD
  // ==================
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } catch (e) {
      return 'Terjadi kesalahan: ${e.toString()}';
    }
  }

  // ==================
  // GET USER DATA
  // ==================
  Future<UserModel?> getUserData(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ==================
  // UPDATE PROFILE
  // ==================
  Future<String?> updateUserProfile({
    required String userId,
    String? fullName,
    String? phoneNumber,
    String? photoURL,
  }) async {
    try {
      Map<String, dynamic> updates = {};

      if (fullName != null) updates['fullName'] = fullName;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (photoURL != null) updates['photoURL'] = photoURL;

      await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId)
          .update(updates);

      if (fullName != null) {
        await currentUser?.updateDisplayName(fullName);
      }

      notifyListeners();
      return null;
    } catch (e) {
      return 'Gagal update profile: ${e.toString()}';
    }
  }

  // ==================
  // ERROR HANDLER
  // ==================
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Email tidak terdaftar';
      case 'wrong-password':
        return 'Password salah';
      case 'email-already-in-use':
        return 'Email sudah digunakan';
      case 'weak-password':
        return 'Password terlalu lemah';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'user-disabled':
        return 'Akun telah dinonaktifkan';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan, coba lagi nanti';
      default:
        return 'Terjadi kesalahan: ${e.message}';
    }
  }
}
