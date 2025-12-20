import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../../../services/auth_service.dart';
import '../../../services/booking_service.dart';
import '../../../services/property_service.dart';
import '../../../services/review_service.dart';
import '../../../models/booking_model.dart';
import '../../../models/property_model.dart';
import '../../../models/review_model.dart';
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
    final String? userId = authService.currentUser?.uid;

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
              final booking = bookings[index];

              return FutureBuilder<PropertyModel?>(
                future: _propertyService.getPropertyById(booking.propertyId),
                builder: (context, propertySnapshot) {
                  final property = propertySnapshot.data;
                  final isPropertyLoading = propertySnapshot.connectionState == ConnectionState.waiting;

                  return BookingCard(
                    booking: booking,
                    property: property,
                    isLoading: isPropertyLoading,
                    userId: userId,
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
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle, style: TextStyle(color: Colors.grey[600]), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class BookingCard extends StatefulWidget {
  final BookingModel booking;
  final PropertyModel? property;
  final bool isLoading;
  final String? userId;

  const BookingCard({
    super.key,
    required this.booking,
    this.property,
    this.isLoading = false,
    this.userId,
  });

  @override
  State<BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> {
  final ReviewService _reviewService = ReviewService();
  double _rating = 5.0;
  final TextEditingController _commentController = TextEditingController();
  ReviewModel? _existingReview;
  bool _isLoadingReview = false;

  @override
  void initState() {
    super.initState();
    if (widget.booking.bookingStatus == 'completed') {
      _loadExistingReview();
    }
  }

  Future<void> _loadExistingReview() async {
    if (widget.userId == null) return;

    final reviews = await _reviewService.getPropertyReviews(widget.booking.propertyId).first;
    final myReview = reviews.firstWhereOrNull((r) => r.userId == widget.userId);

    if (myReview != null) {
      setState(() {
        _existingReview = myReview;
        _rating = myReview.rating;
        _commentController.text = myReview.comment;
      });
    }
  }

  Future<void> _showReviewDialog() async {
    if (widget.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap login')));
      return;
    }

    final isEdit = _existingReview != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Edit Ulasan' : 'Beri Ulasan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                allowHalfRating: false,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) => _rating = rating,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _commentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Tulis ulasan Anda... ',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          if (isEdit)
            TextButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Hapus Ulasan?'),
                    content: const Text('Ulasan akan dihapus permanen.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (confirm == true && _existingReview != null) {
                  final error = await _reviewService.deleteReview(_existingReview!.reviewId);
                  if (error == null) {
                    setState(() {
                      _existingReview = null;
                      _commentController.clear();
                      _rating = 5.0;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ulasan dihapus')));
                  }
                  if (mounted) Navigator.pop(ctx);
                }
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ElevatedButton(
            onPressed: _isLoadingReview ? null : () async {
              final comment = _commentController.text.trim();
              if (comment.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Komentar wajib diisi')));
                return;
              }

              setState(() => _isLoadingReview = true);

              final review = ReviewModel(
                reviewId: _existingReview?.reviewId ?? '',
                userId: widget.userId!,
                propertyId: widget.booking.propertyId,
                bookingId: widget.booking.bookingId,
                rating: _rating,
                comment: comment,
                createdAt: DateTime.now(),
                userName: null,
                userPhoto: null,
              );

              String? error;
              if (isEdit) {
                error = await _reviewService.updateReview(review);
              } else {
                error = await _reviewService.createReview(review);
              }

              setState(() => _isLoadingReview = false);

              if (error == null && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isEdit ? 'Ulasan diperbarui' : 'Ulasan berhasil ditambahkan')),
                );
                _loadExistingReview(); // reload untuk update tombol
                Navigator.pop(ctx);
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Gagal')));
              }
            },
            child: _isLoadingReview
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(isEdit ? 'Update' : 'Kirim'),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
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

  String _statusText(String status) {
    switch (status) {
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'cancelled':
        return 'Dibatalkan';
      case 'completed':
        return 'Selesai';
      default:
        return status;
    }
  }

  Color _paymentColor(String status) {
    switch (status) {
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

  String _paymentText(String status) {
    switch (status) {
      case 'paid':
        return 'Lunas';
      case 'pending':
        return 'Menunggu';
      case 'failed':
        return 'Gagal';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showReviewButton = widget.booking.bookingStatus == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 6))],
      ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: widget.property != null
              ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailScreen(property: widget.property!)))
              : null,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header foto + nama + kota
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: widget.isLoading
                          ? Container(
                              width: 72,
                              height: 72,
                              color: Colors.grey[200],
                              child: const Center(child: CircularProgressIndicator()),
                            )
                          : widget.property != null && widget.property!.images.isNotEmpty
                              ? Image.network(
                                  widget.property!.images.first,
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: 72,
                                      height: 72,
                                      color: Colors.grey[200],
                                      child: const Center(child: CircularProgressIndicator()),
                                    );
                                  },
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 72,
                                    height: 72,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.hotel, size: 32),
                                  ),
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
                            widget.property?.name ?? (widget.isLoading ? 'Memuat...' : 'Properti tidak ditemukan'),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                widget.property?.city ?? '-',
                                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
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

                const SizedBox(height: 12),

                // Booking ID + Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Booking ID', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.booking.bookingId.substring(0, widget.booking.bookingId.length.clamp(0, 12))}...',
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _statusColor(widget.booking.bookingStatus).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        _statusText(widget.booking.bookingStatus),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: _statusColor(widget.booking.bookingStatus)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Pembayaran
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _paymentColor(widget.booking.paymentStatus).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Pembayaran: ${_paymentText(widget.booking.paymentStatus)}',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _paymentColor(widget.booking.paymentStatus)),
                  ),
                ),

                const SizedBox(height: 16),

                // Tanggal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _dateItem('Check-in', widget.booking.checkInDate),
                    const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                    _dateItem('Check-out', widget.booking.checkOutDate),
                  ],
                ),

                const SizedBox(height: 16),

                // Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _infoItem(Icons.nights_stay, '${widget.booking.totalNights} malam'),
                    _infoItem(Icons.people, '${widget.booking.numberOfGuests} tamu'),
                    _infoItem(Icons.payment, widget.booking.paymentMethod),
                  ],
                ),

                const Divider(height: 32),

                // Total + Tombol Review
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Pembayaran', style: TextStyle(fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${widget.booking.totalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                        ),
                      ],
                    ),
                    if (showReviewButton)
                      ElevatedButton.icon(
                        onPressed: _showReviewDialog,
                        icon: const Icon(Icons.rate_review, size: 18),
                        label: Text(_existingReview != null ? 'Edit Ulasan' : 'Beri Ulasan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
    );
  }

  Widget _dateItem(String title, DateTime date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 6),
        Text(
          DateFormat('dd/MM/yyyy').format(date),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}