import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luxora_app/models/property_model.dart';
import 'package:luxora_app/config/firebase_config.dart';

class PropertyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get All Properties
  Stream<List<PropertyModel>> getAllProperties() {
    return _firestore
        .collection(FirebaseConfig.propertiesCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PropertyModel.fromFirestore(doc))
            .toList());
  }

  // Get Property by ID
  Future<PropertyModel?> getPropertyById(String propertyId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(FirebaseConfig.propertiesCollection)
          .doc(propertyId)
          .get();

      if (doc.exists) {
        return PropertyModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Search Properties by City
  Stream<List<PropertyModel>> searchByCity(String city) {
    return _firestore
        .collection(FirebaseConfig.propertiesCollection)
        .where('city', isEqualTo: city)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PropertyModel.fromFirestore(doc))
            .toList());
  }

  // Search Properties by Type
  Stream<List<PropertyModel>> searchByType(String type) {
    return _firestore
        .collection(FirebaseConfig.propertiesCollection)
        .where('type', isEqualTo: type)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PropertyModel.fromFirestore(doc))
            .toList());
  }

  // Search Properties dengan Filter
  Future<List<PropertyModel>> searchProperties({
    String? city,
    String? type,
    double? minPrice,
    double? maxPrice,
    int? minGuests,
  }) async {
    try {
      Query query = _firestore
          .collection(FirebaseConfig.propertiesCollection)
          .where('isActive', isEqualTo: true);

      if (city != null && city.isNotEmpty) {
        query = query.where('city', isEqualTo: city);
      }

      if (type != null && type.isNotEmpty) {
        query = query.where('type', isEqualTo: type);
      }

      QuerySnapshot snapshot = await query.get();
      
      List<PropertyModel> properties = snapshot.docs
          .map((doc) => PropertyModel.fromFirestore(doc))
          .toList();

      // Filter by price range
      if (minPrice != null) {
        properties = properties.where((p) => p.pricePerNight >= minPrice).toList();
      }
      if (maxPrice != null) {
        properties = properties.where((p) => p.pricePerNight <= maxPrice).toList();
      }

      // Filter by guests
      if (minGuests != null) {
        properties = properties.where((p) => p.maxGuests >= minGuests).toList();
      }

      return properties;
    } catch (e) {
      return [];
    }
  }

  // Get Featured Properties (Rating tinggi)
  Stream<List<PropertyModel>> getFeaturedProperties() {
    return _firestore
        .collection(FirebaseConfig.propertiesCollection)
        .where('isActive', isEqualTo: true)
        .where('rating', isGreaterThanOrEqualTo: 4.5)
        .orderBy('rating', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PropertyModel.fromFirestore(doc))
            .toList());
  }

  // Get Properties by Owner
  Stream<List<PropertyModel>> getPropertiesByOwner(String ownerId) {
    return _firestore
        .collection(FirebaseConfig.propertiesCollection)
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PropertyModel.fromFirestore(doc))
            .toList());
  }

  // Create Property (untuk pemilik/mitra)
  Future<String?> createProperty(PropertyModel property) async {
    try {
      await _firestore
          .collection(FirebaseConfig.propertiesCollection)
          .doc(property.propertyId)
          .set(property.toMap());
      return null; // Success
    } catch (e) {
      return 'Gagal menambahkan properti: ${e.toString()}';
    }
  }

  // Update Property
  Future<String?> updateProperty(PropertyModel property) async {
    try {
      await _firestore
          .collection(FirebaseConfig.propertiesCollection)
          .doc(property.propertyId)
          .update(property.toMap());
      return null; // Success
    } catch (e) {
      return 'Gagal update properti: ${e.toString()}';
    }
  }

  // Delete Property (soft delete)
  Future<String?> deleteProperty(String propertyId) async {
    try {
      await _firestore
          .collection(FirebaseConfig.propertiesCollection)
          .doc(propertyId)
          .update({'isActive': false});
      return null; // Success
    } catch (e) {
      return 'Gagal menghapus properti: ${e.toString()}';
    }
  }

  // Sort Properties by Price
  Future<List<PropertyModel>> sortByPrice(List<PropertyModel> properties, {bool ascending = true}) async {
    properties.sort((a, b) {
      if (ascending) {
        return a.pricePerNight.compareTo(b.pricePerNight);
      } else {
        return b.pricePerNight.compareTo(a.pricePerNight);
      }
    });
    return properties;
  }

  // Sort Properties by Rating
  Future<List<PropertyModel>> sortByRating(List<PropertyModel> properties) async {
    properties.sort((a, b) => b.rating.compareTo(a.rating));
    return properties;
  }
}