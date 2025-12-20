import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String bookingId;
  final String userId;
  final String propertyId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numberOfGuests;
  final int totalNights;
  final double totalPrice;
  final String paymentMethod;
  final String paymentStatus; // pending, paid, failed
  final String bookingStatus; // confirmed, cancelled, completed
  final String guestName;
  final String guestPhone;
  final String guestEmail;
  final String? specialRequest;
  final DateTime createdAt;
  final DateTime? updatedAt;

  BookingModel({
    required this.bookingId,
    required this.userId,
    required this.propertyId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfGuests,
    required this.totalNights,
    required this.totalPrice,
    required this.paymentMethod,
    this.paymentStatus = 'pending',
    this.bookingStatus = 'confirmed',
    required this.guestName,
    required this.guestPhone,
    required this.guestEmail,
    this.specialRequest,
    required this.createdAt,
    this.updatedAt,
  });

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'propertyId': propertyId,
      'checkInDate': Timestamp.fromDate(checkInDate),
      'checkOutDate': Timestamp.fromDate(checkOutDate),
      'numberOfGuests': numberOfGuests,
      'totalNights': totalNights,
      'totalPrice': totalPrice,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'bookingStatus': bookingStatus,
      'guestName': guestName,
      'guestPhone': guestPhone,
      'guestEmail': guestEmail,
      'specialRequest': specialRequest,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Convert from Firestore
  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      bookingId: doc.id,
      userId: data['userId'] ?? '',
      propertyId: data['propertyId'] ?? '',
      checkInDate: (data['checkInDate'] as Timestamp).toDate(),
      checkOutDate: (data['checkOutDate'] as Timestamp).toDate(),
      numberOfGuests: data['numberOfGuests'] ?? 0,
      totalNights: data['totalNights'] ?? 0,
      totalPrice: (data['totalPrice'] ?? 0.0).toDouble(),
      paymentMethod: data['paymentMethod'] ?? '',
      paymentStatus: data['paymentStatus'] ?? 'pending',
      bookingStatus: data['bookingStatus'] ?? 'confirmed',
      guestName: data['guestName'] ?? '',
      guestPhone: data['guestPhone'] ?? '',
      guestEmail: data['guestEmail'] ?? '',
      specialRequest: data['specialRequest'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  // Copy with
  BookingModel copyWith({
    String? bookingId,
    String? userId,
    String? propertyId,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? numberOfGuests,
    int? totalNights,
    double? totalPrice,
    String? paymentMethod,
    String? paymentStatus,
    String? bookingStatus,
    String? guestName,
    String? guestPhone,
    String? guestEmail,
    String? specialRequest,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingModel(
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
      propertyId: propertyId ?? this.propertyId,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      totalNights: totalNights ?? this.totalNights,
      totalPrice: totalPrice ?? this.totalPrice,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      guestName: guestName ?? this.guestName,
      guestPhone: guestPhone ?? this.guestPhone,
      guestEmail: guestEmail ?? this.guestEmail,
      specialRequest: specialRequest ?? this.specialRequest,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}