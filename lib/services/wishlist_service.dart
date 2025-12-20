import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wishlist_model.dart';
import '../config/firebase_config.dart';

class WishlistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add to Wishlist - SIMPLIFIED VERSION
  Future<String?> addToWishlist({
    required String userId,
    required String propertyId,
  }) async {
    try {
      print('Adding to wishlist: userId=$userId, propertyId=$propertyId');
      
      // Check if already exists
      final existingQuery = await _firestore
          .collection(FirebaseConfig.wishlistsCollection)
          .where('userId', isEqualTo: userId)
          .where('propertyId', isEqualTo: propertyId)
          .limit(1)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        print('Property already in wishlist');
        return 'Properti sudah ada di wishlist';
      }

      // Generate document reference
      final docRef = _firestore
          .collection(FirebaseConfig.wishlistsCollection)
          .doc();

      // Create simple data map
      final data = {
        'wishlistId': docRef.id,
        'userId': userId,
        'propertyId': propertyId,
        'addedAt': Timestamp.now(),
      };

      // Set data
      await docRef.set(data);
      
      print('Successfully added to wishlist: ${docRef.id}');
      return null; // Success
    } catch (e) {
      print('Error adding to wishlist: $e');
      print('Error type: ${e.runtimeType}');
      return 'Gagal menambahkan: ${e.toString()}';
    }
  }

  // Remove from Wishlist
  Future<String?> removeFromWishlist({
    required String userId,
    required String propertyId,
  }) async {
    try {
      print('Removing from wishlist: userId=$userId, propertyId=$propertyId');
      
      final snapshot = await _firestore
          .collection(FirebaseConfig.wishlistsCollection)
          .where('userId', isEqualTo: userId)
          .where('propertyId', isEqualTo: propertyId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        print('Wishlist item not found');
        return 'Properti tidak ditemukan di wishlist';
      }

      await snapshot.docs.first.reference.delete();
      print('Successfully removed from wishlist');
      
      return null; // Success
    } catch (e) {
      print('Error removing from wishlist: $e');
      return 'Gagal menghapus: ${e.toString()}';
    }
  }

  // Get User Wishlist
  Stream<List<WishlistModel>> getUserWishlist(String userId) {
    print('Getting wishlist for user: $userId');
    
    return _firestore
        .collection(FirebaseConfig.wishlistsCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          print('Wishlist snapshot received: ${snapshot.docs.length} items');
          return snapshot.docs
              .map((doc) {
                try {
                  return WishlistModel.fromFirestore(doc);
                } catch (e) {
                  print('Error parsing wishlist doc: $e');
                  return null;
                }
              })
              .where((item) => item != null)
              .cast<WishlistModel>()
              .toList();
        });
  }

  // Check if Property in Wishlist
  Future<bool> isInWishlist({
    required String userId,
    required String propertyId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConfig.wishlistsCollection)
          .where('userId', isEqualTo: userId)
          .where('propertyId', isEqualTo: propertyId)
          .limit(1)
          .get();

      final exists = snapshot.docs.isNotEmpty;
      print('isInWishlist: $exists');
      return exists;
    } catch (e) {
      print('Error checking wishlist: $e');
      return false;
    }
  }

  // Toggle Wishlist
  Future<String?> toggleWishlist({
    required String userId,
    required String propertyId,
  }) async {
    try {
      print('Toggling wishlist for propertyId: $propertyId');
      
      final inWishlist = await isInWishlist(
        userId: userId,
        propertyId: propertyId,
      );

      if (inWishlist) {
        return await removeFromWishlist(
          userId: userId,
          propertyId: propertyId,
        );
      } else {
        return await addToWishlist(
          userId: userId,
          propertyId: propertyId,
        );
      }
    } catch (e) {
      print('Error toggling wishlist: $e');
      return 'Terjadi kesalahan: ${e.toString()}';
    }
  }

  // Get Wishlist Count
  Future<int> getWishlistCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConfig.wishlistsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('Error getting wishlist count: $e');
      return 0;
    }
  }

  // Clear All Wishlist
  Future<String?> clearAllWishlist(String userId) async {
    try {
      print('Clearing all wishlist for user: $userId');
      
      final snapshot = await _firestore
          .collection(FirebaseConfig.wishlistsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      print('Successfully cleared all wishlist');
      return null; // Success
    } catch (e) {
      print('Error clearing wishlist: $e');
      return 'Gagal menghapus wishlist: ${e.toString()}';
    }
  }
}