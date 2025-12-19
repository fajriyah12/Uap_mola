import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminBookingScreen extends StatelessWidget {
  final String adminId;

  const AdminBookingScreen({Key? key, required this.adminId}) : super(key: key);

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "-";
    final date = timestamp.toDate();
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String formatCurrency(int price) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking User"),
        backgroundColor: const Color.fromRGBO(141, 105, 59, 1),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Belum ada booking."));
          }

          final bookings = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];

              final guestName = booking['guestName'] ?? '-';
              final guestEmail = booking['guestEmail'] ?? '-';
              final checkInDate = booking['checkInDate'] as Timestamp?;
              final checkOutDate = booking['checkOutDate'] as Timestamp?;
              final bookingStatus = booking['bookingStatus'] ?? 'pending';
              final paymentMethod = booking['paymentMethod'] ?? '-';
              final paymentStatus = booking['paymentStatus'] ?? '-';
              final totalPrice = booking['totalPrice'] ?? 0;

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guestName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text("Email: $guestEmail"),
                      Text("Check-in: ${formatDate(checkInDate)}"),
                      Text("Check-out: ${formatDate(checkOutDate)}"),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text("Status Booking: "),
                          Text(
                            bookingStatus,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: statusColor(bookingStatus)),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text("Metode Pembayaran: "),
                          Text(paymentMethod),
                        ],
                      ),
                      Row(
                        children: [
                          const Text("Status Pembayaran: "),
                          Text(
                            paymentStatus,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: statusColor(paymentStatus)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Total Harga: Rp ${formatCurrency(totalPrice)}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
