import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/booking_service.dart';
import '../../../services/property_service.dart';
import '../../../models/booking_model.dart';
import '../../../models/property_model.dart';
import '../../../config/app_theme.dart';
import '../user/property_detail_screen.dart';

class BookingListScreen extends StatefulWidget {
  final bool showBottomNav;

  const BookingListScreen({
    super.key,
    this.showBottomNav = true,
  });

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  final BookingService _bookingService = BookingService();
  final PropertyService _propertyService = PropertyService();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userId = authService.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Booking Saya')),
        body: _emptyState(
          icon: Icons.login,
          title: 'Belum Login',
          subtitle: 'Silakan login untuk melihat booking Anda',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Saya'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<BookingModel>>(
        stream: _bookingService.getUserBookings(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _emptyState(
              icon: Icons.error_outline,
              title: 'Terjadi Kesalahan',
              subtitle: snapshot.error.toString(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _emptyState(
              icon: Icons.receipt_long,
              title: 'Belum Ada Booking',
              subtitle: 'Booking yang Anda buat akan tampil di sini',
            );
          }

          final bookings = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              return FutureBuilder<PropertyModel?>(
                future: _propertyService.getPropertyById(
                  bookings[index].propertyId,
                ),
                builder: (context, propertySnapshot) {
                  return BookingCard(
                    booking: bookings[index],
                    property: propertySnapshot.data,
                    isLoading: propertySnapshot.connectionState ==
                        ConnectionState.waiting,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final PropertyModel? property;
  final bool isLoading;

  const BookingCard({
    super.key,
    required this.booking,
    this.property,
    this.isLoading = false,
  });

  Color _statusColor() {
    switch (booking.bookingStatus) {
      case 'confirmed':
        return AppTheme.successColor;
      case 'cancelled':
        return AppTheme.errorColor;
      case 'completed':
        return Colors.blue;
      default:
        return AppTheme.warningColor;
    }
  }

  String _statusText() {
    switch (booking.bookingStatus) {
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'cancelled':
        return 'Dibatalkan';
      case 'completed':
        return 'Selesai';
      default:
        return booking.bookingStatus;
    }
  }

  Color _paymentColor() {
    switch (booking.paymentStatus) {
      case 'paid':
        return AppTheme.successColor;
      case 'pending':
        return AppTheme.warningColor;
      case 'failed':
        return AppTheme.errorColor;
      default:
        return Colors.grey;
    }
  }

  String _paymentText() {
    switch (booking.paymentStatus) {
      case 'paid':
        return 'Lunas';
      case 'pending':
        return 'Menunggu';
      case 'failed':
        return 'Gagal';
      default:
        return booking.paymentStatus;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: property == null
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PropertyDetailScreen(property: property!),
                    ),
                  );
                },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER PROPERTY
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: isLoading
                          ? Container(
                              width: 72,
                              height: 72,
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : property != null &&
                                  property!.images.isNotEmpty
                              ? Image.network(
                                  property!.images.first,
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 72,
                                  height: 72,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.hotel, size: 32),
                                ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            property?.name ?? 'Property tidak ditemukan',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                property?.city ?? '-',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),
                const Divider(),

                // STATUS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Booking ID',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: _statusColor().withOpacity(0.12),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        _statusText(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: _statusColor(),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),
                Text(
                  booking.bookingId.substring(0, 12) + '...',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 14),

                // PAYMENT
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _paymentColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Pembayaran: ${_paymentText()}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: _paymentColor(),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // DATE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _dateItem('Check-in', booking.checkInDate),
                    const Icon(Icons.arrow_forward_ios,
                        size: 14, color: Colors.grey),
                    _dateItem('Check-out', booking.checkOutDate),
                  ],
                ),

                const SizedBox(height: 16),

                // INFO
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _infoItem(Icons.nights_stay,
                        '${booking.totalNights} malam'),
                    _infoItem(
                        Icons.people, '${booking.numberOfGuests} tamu'),
                    _infoItem(Icons.payment, booking.paymentMethod),
                  ],
                ),

                const Divider(height: 28),

                // TOTAL
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Pembayaran',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Rp ${booking.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(text,
            style: TextStyle(fontSize: 13, color: Colors.grey[700])),
      ],
    );
  }

  Widget _dateItem(String title, DateTime date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          '${date.day}/${date.month}/${date.year}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
