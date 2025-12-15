import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:luxora_app/models/review_model.dart';
import 'package:luxora_app/config/firebase_config.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Create Review
  Future<String?> createReview(ReviewModel review) async {
    try {
      String reviewId = _uuid.v4();
      ReviewModel newReview = review.copyWith(
        reviewId: reviewId,
        createdAt: DateTime.now(),
      );

      // Add review
      await _firestore
          .collection(FirebaseConfig.reviewsCollection)
          .doc(reviewId)
          .set(newReview.toMap());

      // Update property rating
      await _updatePropertyRating(review.propertyId);

      return null; // Success
    } catch (e) {
      return 'Gagal menambahkan review: ${e.toString()}';
    }
  }

  // Get Property Reviews
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

  // Get User Reviews
  Stream<List<ReviewModel>> getUserReviews(String userId) {
    return _firestore
        .collection(FirebaseConfig.reviewsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromFirestore(doc))
            .toList());
  }

  // Check if User Already Reviewed
  Future<bool> hasUserReviewed({
    required String userId,
    required String propertyId,
  }) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(FirebaseConfig.reviewsCollection)
          .where('userId', isEqualTo: userId)
          .where('propertyId', isEqualTo: propertyId)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Update Review
  Future<String?> updateReview({
    required String reviewId,
    required double rating,
    required String comment,
  }) async {
    try {
      await _firestore
          .collection(FirebaseConfig.reviewsCollection)
          .doc(reviewId)
          .update({
        'rating': rating,
        'comment': comment,
      });

      // Get property ID and update rating
      DocumentSnapshot doc = await _firestore
          .collection(FirebaseConfig.reviewsCollection)
          .doc(reviewId)
          .get();
      
      if (doc.exists) {
        ReviewModel review = ReviewModel.fromFirestore(doc);
        await _updatePropertyRating(review.propertyId);
      }

      return null; // Success
    } catch (e) {
      return 'Gagal update review: ${e.toString()}';
    }
  }

  // Delete Review
  Future<String?> deleteReview(String reviewId) async {
    try {
      // Get property ID before delete
      DocumentSnapshot doc = await _firestore
          .collection(FirebaseConfig.reviewsCollection)
          .doc(reviewId)
          .get();

      if (doc.exists) {
        ReviewModel review = ReviewModel.fromFirestore(doc);
        
        // Delete review
        await _firestore
            .collection(FirebaseConfig.reviewsCollection)
            .doc(reviewId)
            .delete();

        // Update property rating
        await _updatePropertyRating(review.propertyId);
      }

      return null; // Success
    } catch (e) {
      return 'Gagal menghapus review: ${e.toString()}';
    }
  }

  // Update Property Rating (private helper)
  Future<void> _updatePropertyRating(String propertyId) async {
    try {
      // Get all reviews for this property
      QuerySnapshot snapshot = await _firestore
          .collection(FirebaseConfig.reviewsCollection)
          .where('propertyId', isEqualTo: propertyId)
          .get();

      if (snapshot.docs.isEmpty) {
        // No reviews, set rating to 0
        await _firestore
            .collection(FirebaseConfig.propertiesCollection)
            .doc(propertyId)
            .update({
          'rating': 0.0,
          'totalReviews': 0,
        });
        return;
      }

      // Calculate average rating
      double totalRating = 0;
      for (var doc in snapshot.docs) {
        ReviewModel review = ReviewModel.fromFirestore(doc);
        totalRating += review.rating;
      }

      double averageRating = totalRating / snapshot.docs.length;
      int totalReviews = snapshot.docs.length;

      // Update property
      await _firestore
          .collection(FirebaseConfig.propertiesCollection)
          .doc(propertyId)
          .update({
        'rating': averageRating,
        'totalReviews': totalReviews,
      });
    } catch (e) {
      // Silently fail
    }
  }

  // Get Average Rating for Property
  Future<double> getAverageRating(String propertyId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(FirebaseConfig.reviewsCollection)
          .where('propertyId', isEqualTo: propertyId)
          .get();

      if (snapshot.docs.isEmpty) return 0.0;

      double totalRating = 0;
      for (var doc in snapshot.docs) {
        ReviewModel review = ReviewModel.fromFirestore(doc);
        totalRating += review.rating;
      }

      return totalRating / snapshot.docs.length;
    } catch (e) {
      return 0.0;
    }
  }

  // Get Review Count for Property
  Future<int> getReviewCount(String propertyId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(FirebaseConfig.reviewsCollection)
          .where('propertyId', isEqualTo: propertyId)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }
}