import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:luxora_app/models/property_model.dart';
import 'package:luxora_app/models/review_model.dart';
import 'package:luxora_app/services/auth_service.dart';
import 'package:luxora_app/services/wishlist_service.dart';
import 'package:luxora_app/services/review_service.dart';
import 'package:luxora_app/config/app_theme.dart';
import 'package:luxora_app/screens/user/booking_screen.dart';
import 'package:luxora_app/screens/user/review_screen.dart'; 

class PropertyDetailScreen extends StatefulWidget {
  final PropertyModel property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final WishlistService _wishlistService = WishlistService();
  final ReviewService _reviewService = ReviewService();
  bool _isInWishlist = false;

  @override
  void initState() {
    super.initState();
    _checkWishlist();
  }

  Future<void> _checkWishlist() async {
    final userId = Provider.of<AuthService>(context, listen: false).currentUser?.uid;
    if (userId == null) return;

    final inWishlist = await _wishlistService.isInWishlist(
      userId: userId,
      propertyId: widget.property.propertyId,
    );

    if (mounted) setState(() => _isInWishlist = inWishlist);
  }

  Future<void> _toggleWishlist() async {
    final userId = Provider.of<AuthService>(context, listen: false).currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Silakan login terlebih dahulu')));
      return;
    }

    final error = await _wishlistService.toggleWishlist(userId: userId, propertyId: widget.property.propertyId);
    if (error == null && mounted) {
      setState(() => _isInWishlist = !_isInWishlist);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isInWishlist ? 'Ditambahkan ke wishlist' : 'Dihapus dari wishlist')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: widget.property.images.isNotEmpty
                  ? PageView.builder(
                      itemCount: widget.property.images.length,
                      itemBuilder: (context, index) => Image.network(
                        widget.property.images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Colors.grey[300], child: const Icon(Icons.hotel, size: 64)),
                      ),
                    )
                  : Container(color: Colors.grey[300], child: const Icon(Icons.hotel, size: 64)),
            ),
            actions: [
              IconButton(
                icon: Icon(_isInWishlist ? Icons.favorite : Icons.favorite_border, color: _isInWishlist ? Colors.red : Colors.white),
                onPressed: _toggleWishlist,
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Properti
                  Text(widget.property.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  // Alamat
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 20),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(widget.property.address, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // RATING REAL-TIME + TOMBOL LIHAT SEMUA
                  StreamBuilder<List<ReviewModel>>(
                    stream: _reviewService.getPropertyReviews(widget.property.propertyId),
                    builder: (context, snapshot) {
                      double rating = widget.property.rating;
                      int totalReviews = widget.property.totalReviews;

                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        final reviews = snapshot.data!;
                        totalReviews = reviews.length;
                        rating = reviews.fold(0.0, (sum, r) => sum + r.rating) / reviews.length;
                      }

                      return Row(
                        children: [
                          RatingBarIndicator(
                            rating: rating,
                            itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber),
                            itemSize: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(rating.toStringAsFixed(1), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(' ($totalReviews ulasan)', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ReviewScreen(
                                    property: widget.property,
                                    bookingId: '', // kosong karena dari detail
                                  ),
                                ),
                              );
                            },
                            child: const Text('Lihat semua', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                  const Divider(),

                  // Informasi Properti
                  const Text('Informasi Properti', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _InfoItem(icon: Icons.people, label: '${widget.property.maxGuests} Tamu'),
                      _InfoItem(icon: Icons.bed, label: '${widget.property.bedrooms} Kamar Tidur'),
                      _InfoItem(icon: Icons.bathroom, label: '${widget.property.bathrooms} Kamar Mandi'),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(),

                  // Deskripsi
                  const Text('Deskripsi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.property.description, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5)),

                  const SizedBox(height: 24),
                  const Divider(),

                  // Fasilitas
                  const Text('Fasilitas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.property.facilities.map((f) => Chip(
                      label: Text(f),
                      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                    )).toList(),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Harga per malam', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('Rp ${widget.property.pricePerNight.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingScreen(property: widget.property))),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
              child: const Text('Pesan Sekarang'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: AppTheme.primaryColor),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}