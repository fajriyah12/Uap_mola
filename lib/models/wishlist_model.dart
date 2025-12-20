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

  // TIDAK DIUBAH
  Map<String, dynamic> toMap() {
    return {
      'wishlistId': wishlistId,
      'userId': userId,
      'propertyId': propertyId,
      'addedAt': FieldValue.serverTimestamp(),
    };
  }

  // 🔧 PERBAIKAN ADA DI SINI SAJA
  factory WishlistModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final Timestamp? timestamp = data['addedAt'] as Timestamp?;

    return WishlistModel(
      wishlistId: data['wishlistId'] ?? doc.id,
      userId: data['userId'] ?? '',
      propertyId: data['propertyId'] ?? '',
      addedAt: timestamp != null
          ? timestamp.toDate()
          : DateTime.now(),
    );
  }

  // TIDAK DIUBAH
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
