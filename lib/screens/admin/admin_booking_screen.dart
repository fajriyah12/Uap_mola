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
    const Color primaryBrown = Color(0xFF6F4E37);
    const Color cream = Color(0xFFF5EFE6);

    return Scaffold(
      backgroundColor: cream,

      appBar: AppBar(
        title: const Text(
          "Booking User",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryBrown,
        elevation: 4,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada booking.",
                style: TextStyle(color: Colors.brown),
              ),
            );
          }

          final bookings = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
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

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ===== HEADER =====
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            guestName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryBrown,
                            ),
                          ),
                          _StatusBadge(
                            text: bookingStatus,
                            color: statusColor(bookingStatus),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),
                      Text(
                        guestEmail,
                        style: const TextStyle(color: Colors.grey),
                      ),

                      const Divider(height: 24),

                      // ===== DATE =====
                      Row(
                        children: [
                          const Icon(Icons.login, size: 18, color: primaryBrown),
                          const SizedBox(width: 6),
                          Text("Check-in: ${formatDate(checkInDate)}"),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.logout, size: 18, color: primaryBrown),
                          const SizedBox(width: 6),
                          Text("Check-out: ${formatDate(checkOutDate)}"),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ===== PAYMENT =====
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Metode: $paymentMethod"),
                          _StatusBadge(
                            text: paymentStatus,
                            color: statusColor(paymentStatus),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ===== TOTAL =====
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cream,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total Harga",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Rp ${formatCurrency(totalPrice)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: primaryBrown,
                              ),
                            ),
                          ],
                        ),
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

// ================= STATUS BADGE =================
class _StatusBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusBadge({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
