import 'package:cloud_firestore/cloud_firestore.dart';

class PropertyModel {
  final String propertyId;
  final String ownerId;
  final String name;
  final String type; // hotel, villa, homestay
  final String description;
  final String address;
  final String city;
  final double latitude;
  final double longitude;
  final double pricePerNight;
  final int maxGuests;
  final int bedrooms;
  final int bathrooms;
  final double rating;
  final int totalReviews;
  final List<String> images;
  final List<String> facilities;
  final bool isActive;
  final DateTime createdAt;

  PropertyModel({
    required this.propertyId,
    required this.ownerId,
    required this.name,
    required this.type,
    required this.description,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.pricePerNight,
    required this.maxGuests,
    required this.bedrooms,
    required this.bathrooms,
    this.rating = 0.0,
    this.totalReviews = 0,
    required this.images,
    required this.facilities,
    this.isActive = true,
    required this.createdAt,
  });

  /// Convert model → Firestore
  Map<String, dynamic> toMap() {
    return {
      'propertyId': propertyId,
      'ownerId': ownerId,
      'name': name,
      'type': type,
      'description': description,
      'address': address,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'pricePerNight': pricePerNight,
      'maxGuests': maxGuests,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'rating': rating,
      'totalReviews': totalReviews,
      'images': images,
      'facilities': facilities,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Convert Firestore → model (SAFE)
  factory PropertyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    return PropertyModel(
      propertyId: data?['propertyId'] ?? doc.id,
      ownerId: data?['ownerId'] ?? '',
      name: data?['name'] ?? '',
      type: data?['type'] ?? '',
      description: data?['description'] ?? '',
      address: data?['address'] ?? '',
      city: data?['city'] ?? '',
      latitude: (data?['latitude'] ?? 0).toDouble(),
      longitude: (data?['longitude'] ?? 0).toDouble(),
      pricePerNight: (data?['pricePerNight'] ?? 0).toDouble(),
      maxGuests: data?['maxGuests'] ?? 0,
      bedrooms: data?['bedrooms'] ?? 0,
      bathrooms: data?['bathrooms'] ?? 0,
      rating: (data?['rating'] ?? 0).toDouble(),
      totalReviews: data?['totalReviews'] ?? 0,
      images: List<String>.from(data?['images'] ?? []),
      facilities: List<String>.from(data?['facilities'] ?? []),
      isActive: data?['isActive'] ?? true,
      createdAt: (data?['createdAt'] is Timestamp)
          ? (data!['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// CopyWith
  PropertyModel copyWith({
    String? propertyId,
    String? ownerId,
    String? name,
    String? type,
    String? description,
    String? address,
    String? city,
    double? latitude,
    double? longitude,
    double? pricePerNight,
    int? maxGuests,
    int? bedrooms,
    int? bathrooms,
    double? rating,
    int? totalReviews,
    List<String>? images,
    List<String>? facilities,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return PropertyModel(
      propertyId: propertyId ?? this.propertyId,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      maxGuests: maxGuests ?? this.maxGuests,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      images: images ?? this.images,
      facilities: facilities ?? this.facilities,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
