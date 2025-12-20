// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../config/firebase_config.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ==================
  // SIGN UP (USER ONLY)
  // ==================
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

      final uid = userCredential.user!.uid;

      UserModel userModel = UserModel(
        userId: uid,
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(uid)
          .set({
        ...userModel.toMap(),
        'role': 'user',
      });

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
  // ✅ SIGN IN WITH EMAIL CHANGE CHECK
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

      final uid = userCredential.user!.uid;

      // ✅ CEK: Apakah ada pending email change?
      final tempEmailDoc = await _firestore
          .collection('email_change_temp')
          .doc(uid)
          .get();

      if (tempEmailDoc.exists) {
        final tempData = tempEmailDoc.data()!;
        final newEmail = tempData['newEmail'];
        
        print('🔄 Detected pending email change to: $newEmail');
        print('📧 Current auth email: ${userCredential.user!.email}');

        // Jika user login dengan email BARU yang sudah diapprove
        if (email.toLowerCase() == newEmail.toLowerCase()) {
          // Email di Firebase Auth sudah terupdate saat login dengan email baru

          // ✅ Update email di Firestore users
          await _firestore
              .collection(FirebaseConfig.usersCollection)
              .doc(uid)
              .update({
            'email': newEmail,
            'lastLogin': Timestamp.fromDate(DateTime.now()),
          });

          // ✅ Hapus temporary data
          await _firestore
              .collection('email_change_temp')
              .doc(uid)
              .delete();

          print('✅ Email change completed successfully');
        }
      } else {
        // Normal login - update lastLogin
        await _firestore
            .collection(FirebaseConfig.usersCollection)
            .doc(uid)
            .update({
          'lastLogin': Timestamp.fromDate(DateTime.now()),
        });
      }
      // sinkron email Auth → Firestore
      await syncEmailToFirestore();


      notifyListeners();
      return null;


    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } catch (e) {
      print('❌ Sign in error: $e');
      return 'Terjadi kesalahan: ${e.toString()}';
    }
  }

  // ==================
  // GET USER ROLE
  // ==================
  Future<String?> getUserRole() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return null;

      final doc = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(uid)
          .get();

      if (!doc.exists) return null;

      return doc['role'];
    } catch (e) {
      return null;
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

  Future<void> syncEmailToFirestore() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .update({
    'email': user.email,
    'updatedAt': FieldValue.serverTimestamp(),
  });
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
  // ✅ CHECK PENDING EMAIL CHANGE
  // ==================
  Future<Map<String, dynamic>?> checkPendingEmailChange(String userId) async {
    try {
      final doc = await _firestore
          .collection('email_change_temp')
          .doc(userId)
          .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      return null;
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
      case 'requires-recent-login':
        return 'Silakan login ulang untuk melanjutkan';
      default:
        return 'Terjadi kesalahan: ${e.message}';
    }
  }
}