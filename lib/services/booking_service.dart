import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';
import '../config/firebase_config.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create Booking - DIPERBAIKI
  Future<String?> createBooking(BookingModel booking) async {
    try {
      // Generate ID otomatis dari Firestore
      DocumentReference docRef = _firestore
          .collection(FirebaseConfig.bookingsCollection)
          .doc();

      BookingModel newBooking = booking.copyWith(
        bookingId: docRef.id,
        createdAt: DateTime.now(),
      );

      await docRef.set(newBooking.toMap());

      return docRef.id; // Return booking ID
    } catch (e) {
      print('Error creating booking: $e');
      return null;
    }
  }

  // Get Booking by ID
  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(FirebaseConfig.bookingsCollection)
          .doc(bookingId)
          .get();

      if (doc.exists) {
        return BookingModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting booking: $e');
      return null;
    }
  }

  // Get User Bookings
  Stream<List<BookingModel>> getUserBookings(String userId) {
    return _firestore
        .collection(FirebaseConfig.bookingsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromFirestore(doc))
            .toList());
  }

  // Get Property Bookings (untuk owner)
  Stream<List<BookingModel>> getPropertyBookings(String propertyId) {
    return _firestore
        .collection(FirebaseConfig.bookingsCollection)
        .where('propertyId', isEqualTo: propertyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromFirestore(doc))
            .toList());
  }

  // Get Upcoming Bookings
  Stream<List<BookingModel>> getUpcomingBookings(String userId) {
    return _firestore
        .collection(FirebaseConfig.bookingsCollection)
        .where('userId', isEqualTo: userId)
        .where('bookingStatus', isEqualTo: 'confirmed')
        .where('checkInDate', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('checkInDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromFirestore(doc))
            .toList());
  }

  // Get Past Bookings
  Stream<List<BookingModel>> getPastBookings(String userId) {
    return _firestore
        .collection(FirebaseConfig.bookingsCollection)
        .where('userId', isEqualTo: userId)
        .where('checkOutDate', isLessThan: Timestamp.now())
        .orderBy('checkOutDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromFirestore(doc))
            .toList());
  }

  // Update Booking Status
  Future<String?> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    try {
      await _firestore
          .collection(FirebaseConfig.bookingsCollection)
          .doc(bookingId)
          .update({
        'bookingStatus': status,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      return null; // Success
    } catch (e) {
      print('Error updating booking status: $e');
      return 'Gagal update status: ${e.toString()}';
    }
  }

  // Update Payment Status
  Future<String?> updatePaymentStatus({
    required String bookingId,
    required String paymentStatus,
  }) async {
    try {
      await _firestore
          .collection(FirebaseConfig.bookingsCollection)
          .doc(bookingId)
          .update({
        'paymentStatus': paymentStatus,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      return null; // Success
    } catch (e) {
      print('Error updating payment status: $e');
      return 'Gagal update pembayaran: ${e.toString()}';
    }
  }

  // Cancel Booking
  Future<String?> cancelBooking(String bookingId) async {
    try {
      await _firestore
          .collection(FirebaseConfig.bookingsCollection)
          .doc(bookingId)
          .update({
        'bookingStatus': 'cancelled',
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      return null; // Success
    } catch (e) {
      print('Error cancelling booking: $e');
      return 'Gagal membatalkan booking: ${e.toString()}';
    }
  }

  // Check Availability
  Future<bool> checkAvailability({
    required String propertyId,
    required DateTime checkIn,
    required DateTime checkOut,
  }) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(FirebaseConfig.bookingsCollection)
          .where('propertyId', isEqualTo: propertyId)
          .where('bookingStatus', isEqualTo: 'confirmed')
          .get();

      for (var doc in snapshot.docs) {
        BookingModel booking = BookingModel.fromFirestore(doc);
        
        // Check overlap
        if (checkIn.isBefore(booking.checkOutDate) &&
            checkOut.isAfter(booking.checkInDate)) {
          return false; // Not available
        }
      }

      return true; // Available
    } catch (e) {
      print('Error checking availability: $e');
      return false;
    }
  }

  // Calculate Total Nights
  int calculateTotalNights(DateTime checkIn, DateTime checkOut) {
    return checkOut.difference(checkIn).inDays;
  }

  // Calculate Total Price
  double calculateTotalPrice({
    required double pricePerNight,
    required int totalNights,
  }) {
    return pricePerNight * totalNights;
  }
}