// lib/services/review_service.dart

import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:luxora_app/models/review_model.dart';
import 'package:luxora_app/config/firebase_config.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  Future<String?> createReview(ReviewModel review) async {
  try {
    final String reviewId = _uuid.v4();
    final ReviewModel newReview = review.copyWith(
      reviewId: reviewId,
      createdAt: DateTime.now(),
    );

    // LOG SUPER DETAIL UNTUK DEBUG
    print('=== DEBUG REVIEW ===');
    print('Collection name: ${FirebaseConfig.reviewsCollection}');
    print('Review ID: $reviewId');
    print('Property ID: ${review.propertyId}');
    print('User ID: ${review.userId}');
    print('Rating: ${review.rating}');
    print('Comment: ${review.comment}');
    print('Map data: ${newReview.toMap()}');
    print('===================');

    await _firestore
        .collection(FirebaseConfig.reviewsCollection)
        .doc(reviewId)
        .set(newReview.toMap());

    print('Review berhasil disimpan ke Firestore!');

    await _updatePropertyRating(review.propertyId);
    return null;
  } catch (e, stackTrace) {
    print('ERROR SAAT SIMPAN REVIEW: $e');
    print('Stack trace: $stackTrace');
    return 'Gagal menambahkan review: ${e.toString()}';
  }
}

  Future<bool> canUserReview({
    required String userId,
    required String propertyId,
  }) async {
    try {
      final bookingSnapshot = await _firestore
          .collection(FirebaseConfig.bookingsCollection)
          .where('userId', isEqualTo: userId)
          .where('propertyId', isEqualTo: propertyId)
          .where('bookingStatus', isEqualTo: 'completed')
          .limit(1)
          .get();

      if (bookingSnapshot.docs.isEmpty) return false;

      final reviewSnapshot = await _firestore
          .collection(FirebaseConfig.reviewsCollection)
          .where('userId', isEqualTo: userId)
          .where('propertyId', isEqualTo: propertyId)
          .limit(1)
          .get();

      return reviewSnapshot.docs.isEmpty;
    } catch (e) {
      developer.log('Error canUserReview: $e');
      return false;
    }
  }

  Future<String?> updateReview(ReviewModel review) async {
    try {
      await _firestore
          .collection(FirebaseConfig.reviewsCollection)
          .doc(review.reviewId)
          .update({
        'rating': review.rating,
        'comment': review.comment,
        'createdAt': DateTime.now(),
      });

      await _updatePropertyRating(review.propertyId);
      return null;
    } catch (e) {
      developer.log('Error updateReview: $e');
      return 'Gagal update review: ${e.toString()}';
    }
  }

  Future<String?> deleteReview(String reviewId) async {
    try {
      final docSnapshot = await _firestore
          .collection(FirebaseConfig.reviewsCollection)
          .doc(reviewId)
          .get();

      if (!docSnapshot.exists) return 'Review tidak ditemukan';

      final review = ReviewModel.fromFirestore(docSnapshot);
      await _firestore
          .collection(FirebaseConfig.reviewsCollection)
          .doc(reviewId)
          .delete();

      await _updatePropertyRating(review.propertyId);
      return null;
    } catch (e) {
      developer.log('Error deleteReview: $e');
      return 'Gagal menghapus review: ${e.toString()}';
    }
  }

  Stream<List<ReviewModel>> getPropertyReviews(String propertyId) {
    return _firestore
        .collection(FirebaseConfig.reviewsCollection)
        .where('propertyId', isEqualTo: propertyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromFirestore(doc))
            .toList());
  }

  Future<void> _updatePropertyRating(String propertyId) async {
    final propertyRef = _firestore
        .collection(FirebaseConfig.propertiesCollection)
        .doc(propertyId);

    try {
      final reviewsSnapshot = await _firestore
          .collection(FirebaseConfig.reviewsCollection)
          .where('propertyId', isEqualTo: propertyId)
          .get();

      if (reviewsSnapshot.docs.isEmpty) {
        await propertyRef.update({'rating': 0.0, 'totalReviews': 0});
        return;
      }

      double total = 0.0;
      for (var doc in reviewsSnapshot.docs) {
        total += (doc['rating'] as num).toDouble();
      }

      await propertyRef.update({
        'rating': total / reviewsSnapshot.docs.length,
        'totalReviews': reviewsSnapshot.docs.length,
      });
    } catch (e) {
      developer.log('Failed to update rating: $e');
    }
  }
}