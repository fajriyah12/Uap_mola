import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    this.photoURL,
    required this.createdAt,
    this.lastLogin,
  });

  // Convert to Map (untuk save ke Firestore)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'photoURL': photoURL,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
    };
  }

  // Convert from Firestore Document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      userId: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      photoURL: data['photoURL'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLogin: data['lastLogin'] != null 
          ? (data['lastLogin'] as Timestamp).toDate() 
          : null,
    );
  }

  // Copy with method untuk update data
  UserModel copyWith({
    String? userId,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? photoURL,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}