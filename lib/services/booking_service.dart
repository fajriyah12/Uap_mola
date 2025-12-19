import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';
import '../config/firebase_config.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //normalisasi tanggal (hilangkan jam, menit, detik)
  DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Create Booking dengan cek availability
  Future<String?> createBooking(BookingModel booking) async {
    try {
      // Normalize tanggal checkIn & checkOut
      DateTime checkIn = normalizeDate(booking.checkInDate);
      DateTime checkOut = normalizeDate(booking.checkOutDate);

      // Pastikan tanggal checkIn < checkOut
      if (!checkIn.isBefore(checkOut)) {
        return 'Tanggal check-in harus sebelum check-out';
      }

      // Cek ketersediaan property
      bool available = await checkAvailability(
        propertyId: booking.propertyId,
        checkIn: checkIn,
        checkOut: checkOut,
      );

      if (!available) {
        return 'Properti tidak tersedia pada tanggal yang dipilih';
      }

      // Generate ID otomatis dari Firestore
      DocumentReference docRef = _firestore
          .collection(FirebaseConfig.bookingsCollection)
          .doc();

      BookingModel newBooking = booking.copyWith(
        bookingId: docRef.id,
        createdAt: DateTime.now(),
        bookingStatus: 'confirmed', // default langsung confirmed
        checkInDate: checkIn,
        checkOutDate: checkOut,
      );

      await docRef.set(newBooking.toMap());

      return docRef.id; // Return booking ID
    } catch (e) {
      print('Error creating booking: $e');
      return null;
    }
  }

  // Check Availability - fix
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

        // Normalize tanggal Firestore
        DateTime existingCheckIn = normalizeDate(booking.checkInDate);
        DateTime existingCheckOut = normalizeDate(booking.checkOutDate);

        // Debug log
        print(
            'Existing: $existingCheckIn - $existingCheckOut, Requested: $checkIn - $checkOut');

        // Cek overlap
        bool isOverlap =
            checkIn.isBefore(existingCheckOut) && checkOut.isAfter(existingCheckIn);

        if (isOverlap) {
          print('Overlap ditemukan, properti tidak tersedia');
          return false;
        }
      }

      print('Tidak ada overlap, properti tersedia');
      return true;
    } catch (e) {
      print('Error checking availability: $e');
      return false;
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
      return null; 
    } catch (e) {
      print('Error cancelling booking: $e');
      return 'Gagal membatalkan booking: ${e.toString()}';
    }
  }
}
