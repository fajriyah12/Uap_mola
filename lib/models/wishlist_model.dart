import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistModel {
  final String wishlistId;
  final String userId;
  final String propertyId;
  final DateTime addedAt;

  WishlistModel({
    required this.wishlistId,
    required this.userId,
    required this.propertyId,
    required this.addedAt,
  });

  // Convert to Map - DIPERBAIKI untuk avoid assertion error
  Map<String, dynamic> toMap() {
    return {
      'wishlistId': wishlistId,
      'userId': userId,
      'propertyId': propertyId,
      'addedAt': FieldValue.serverTimestamp(), // Gunakan server timestamp
    };
  }

  // Convert from Firestore
  factory WishlistModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Handle null timestamp
    DateTime addedAtDate;
    if (data['addedAt'] != null) {
      addedAtDate = (data['addedAt'] as Timestamp).toDate();
    } else {
      addedAtDate = DateTime.now();
    }
    
    return WishlistModel(
      wishlistId: doc.id,
      userId: data['userId'] ?? '',
      propertyId: data['propertyId'] ?? '',
      addedAt: addedAtDate,
    );
  }

  // Copy with
  WishlistModel copyWith({
    String? wishlistId,
    String? userId,
    String? propertyId,
    DateTime? addedAt,
  }) {
    return WishlistModel(
      wishlistId: wishlistId ?? this.wishlistId,
      userId: userId ?? this.userId,
      propertyId: propertyId ?? this.propertyId,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}