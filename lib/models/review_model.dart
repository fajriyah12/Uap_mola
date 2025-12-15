import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String reviewId;
  final String userId;
  final String propertyId;
  final String bookingId;
  final double rating; // 1.0 - 5.0
  final String comment;
  final DateTime createdAt;
  final String? userName; // For display
  final String? userPhoto; // For display

  ReviewModel({
    required this.reviewId,
    required this.userId,
    required this.propertyId,
    required this.bookingId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.userName,
    this.userPhoto,
  });

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'reviewId': reviewId,
      'userId': userId,
      'propertyId': propertyId,
      'bookingId': bookingId,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'userName': userName,
      'userPhoto': userPhoto,
    };
  }

  // Convert from Firestore
  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      reviewId: doc.id,
      userId: data['userId'] ?? '',
      propertyId: data['propertyId'] ?? '',
      bookingId: data['bookingId'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      comment: data['comment'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      userName: data['userName'],
      userPhoto: data['userPhoto'],
    );
  }

  // Copy with
  ReviewModel copyWith({
    String? reviewId,
    String? userId,
    String? propertyId,
    String? bookingId,
    double? rating,
    String? comment,
    DateTime? createdAt,
    String? userName,
    String? userPhoto,
  }) {
    return ReviewModel(
      reviewId: reviewId ?? this.reviewId,
      userId: userId ?? this.userId,
      propertyId: propertyId ?? this.propertyId,
      bookingId: bookingId ?? this.bookingId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      userName: userName ?? this.userName,
      userPhoto: userPhoto ?? this.userPhoto,
    );
  }
}