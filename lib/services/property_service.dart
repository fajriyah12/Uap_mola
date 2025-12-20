import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/property_model.dart';
import '../config/firebase_config.dart';

class PropertyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get All Properties
  Stream<List<PropertyModel>> getAllProperties() {
    print('📊 Getting all properties...');

    return _firestore
        .collection(FirebaseConfig.propertiesCollection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          print('✅ Received ${snapshot.docs.length} properties');

          return snapshot.docs
              .map((doc) {
                try {
                  return PropertyModel.fromFirestore(doc);
                } catch (e) {
                  print('❌ Error parsing property ${doc.id}: $e');
                  return null;
                }
              })
              .where((property) => property != null)
              .cast<PropertyModel>()
              .toList();
        })
        .handleError((error) {
          print('❌ Error in getAllProperties stream: $error');
          return <PropertyModel>[];
        });
  }

  // 🔥 GET PROPERTY BY ID (DIPERBAIKI)
  Future<PropertyModel?> getPropertyById(String propertyId) async {
    try {
      print('Trying to fetch property with ID: $propertyId');
      final snapshot = await _firestore
          .collection(FirebaseConfig.propertiesCollection)
          .where('propertyId', isEqualTo: propertyId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        print('❌ Property not found with propertyId: $propertyId');
        return null;
      }

      print('✅ Property found');
      return PropertyModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      print('❌ Error getting property: $e');
      return null;
    }
  }

  // Search Properties by City
  Stream<List<PropertyModel>> searchByCity(String city) {
    print('🔍 Searching by city: $city');

    return _firestore
        .collection(FirebaseConfig.propertiesCollection)
        .where('city', isEqualTo: city)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          print('✅ Found ${snapshot.docs.length} properties in $city');

          return snapshot.docs
              .map((doc) {
                try {
                  return PropertyModel.fromFirestore(doc);
                } catch (e) {
                  print('❌ Error parsing property: $e');
                  return null;
                }
              })
              .where((property) => property != null)
              .cast<PropertyModel>()
              .toList();
        })
        .handleError((error) {
          print('❌ Error in searchByCity: $error');
          return <PropertyModel>[];
        });
  }

  // Search Properties by Type
  Stream<List<PropertyModel>> searchByType(String type) {
    print('🔍 Searching by type: $type');

    return _firestore
        .collection(FirebaseConfig.propertiesCollection)
        .where('type', isEqualTo: type.toLowerCase())
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          print('✅ Found ${snapshot.docs.length} properties with type $type');

          return snapshot.docs
              .map((doc) {
                try {
                  return PropertyModel.fromFirestore(doc);
                } catch (e) {
                  print('❌ Error parsing property: $e');
                  return null;
                }
              })
              .where((property) => property != null)
              .cast<PropertyModel>()
              .toList();
        })
        .handleError((error) {
          print('❌ Error in searchByType: $error');
          return <PropertyModel>[];
        });
  }

  // Search Properties with Filter
  Future<List<PropertyModel>> searchProperties({
    String? city,
    String? type,
    double? minPrice,
    double? maxPrice,
    int? minGuests,
  }) async {
    try {
      print('🔍 Searching properties with filters...');

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
      print('✅ Found ${snapshot.docs.length} properties');

      List<PropertyModel> properties = snapshot.docs
          .map((doc) {
            try {
              return PropertyModel.fromFirestore(doc);
            } catch (e) {
              print('❌ Error parsing property: $e');
              return null;
            }
          })
          .where((property) => property != null)
          .cast<PropertyModel>()
          .toList();

      if (minPrice != null) {
        properties =
            properties.where((p) => p.pricePerNight >= minPrice).toList();
      }
      if (maxPrice != null) {
        properties =
            properties.where((p) => p.pricePerNight <= maxPrice).toList();
      }
      if (minGuests != null) {
        properties =
            properties.where((p) => p.maxGuests >= minGuests).toList();
      }

      print('✅ Filtered to ${properties.length} properties');
      return properties;
    } catch (e) {
      print('❌ Error searching properties: $e');
      return [];
    }
  }

  // Get Featured Properties
  Stream<List<PropertyModel>> getFeaturedProperties() {
    print('⭐ Getting featured properties...');

    return _firestore
        .collection(FirebaseConfig.propertiesCollection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          var properties = snapshot.docs
              .map((doc) {
                try {
                  return PropertyModel.fromFirestore(doc);
                } catch (e) {
                  print('❌ Error parsing property: $e');
                  return null;
                }
              })
              .where((property) => property != null)
              .cast<PropertyModel>()
              .where((p) => p.rating >= 4.5)
              .toList();

          properties.sort((a, b) => b.rating.compareTo(a.rating));
          return properties.take(10).toList();
        })
        .handleError((error) {
          print('❌ Error in getFeaturedProperties: $error');
          return <PropertyModel>[];
        });
  }

  // Get Properties by Owner
  Stream<List<PropertyModel>> getPropertiesByOwner(String ownerId) {
    print('👤 Getting properties by owner: $ownerId');

    return _firestore
        .collection(FirebaseConfig.propertiesCollection)
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                try {
                  return PropertyModel.fromFirestore(doc);
                } catch (e) {
                  print('❌ Error parsing property: $e');
                  return null;
                }
              })
              .where((property) => property != null)
              .cast<PropertyModel>()
              .toList();
        })
        .handleError((error) {
          print('❌ Error in getPropertiesByOwner: $error');
          return <PropertyModel>[];
        });
  }

  // Create Property
  Future<String?> createProperty(PropertyModel property) async {
    try {
      await _firestore
          .collection(FirebaseConfig.propertiesCollection)
          .doc(property.propertyId)
          .set(property.toMap());
      return null;
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
      return null;
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
      return null;
    } catch (e) {
      return 'Gagal menghapus properti: ${e.toString()}';
    }
  }
}
