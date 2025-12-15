import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:luxora_app/models/property_model.dart';
import 'package:luxora_app/services/auth_service.dart';
import 'package:luxora_app/services/wishlist_service.dart';
import 'package:luxora_app/services/review_service.dart';
import 'package:luxora_app/models/review_model.dart';
import 'package:luxora_app/config/app_theme.dart';
import 'package:luxora_app/screens/booking_screen.dart';

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkWishlist();
  }

  Future<void> _checkWishlist() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?.uid;

    if (userId != null) {
      final inWishlist = await _wishlistService.isInWishlist(
        userId: userId,
        propertyId: widget.property.propertyId,
      );

      setState(() {
        _isInWishlist = inWishlist;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleWishlist() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }

    final error = await _wishlistService.toggleWishlist(
      userId: userId,
      propertyId: widget.property.propertyId,
    );

    if (error == null) {
      setState(() => _isInWishlist = !_isInWishlist);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isInWishlist
              ? 'Ditambahkan ke wishlist'
              : 'Dihapus dari wishlist'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppTheme.errorColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Images
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: widget.property.images.isNotEmpty
                  ? PageView.builder(
                      itemCount: widget.property.images.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          widget.property.images[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.hotel, size: 64),
                            );
                          },
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.hotel, size: 64),
                    ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isInWishlist ? Icons.favorite : Icons.favorite_border,
                  color: _isInWishlist ? Colors.red : Colors.white,
                ),
                onPressed: _toggleWishlist,
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Property Name & Location
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.property.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 20),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.property.address,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 20, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            widget.property.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            ' (${widget.property.totalReviews} ulasan)',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Property Info
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Properti',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _InfoItem(
                            icon: Icons.people,
                            label: '${widget.property.maxGuests} Tamu',
                          ),
                          _InfoItem(
                            icon: Icons.bed,
                            label: '${widget.property.bedrooms} Kamar',
                          ),
                          _InfoItem(
                            icon: Icons.bathroom,
                            label: '${widget.property.bathrooms} Kamar Mandi',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Description
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Deskripsi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.property.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Facilities
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fasilitas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.property.facilities.map((facility) {
                          return Chip(
                            label: Text(facility),
                            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Reviews
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ulasan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      StreamBuilder<List<ReviewModel>>(
                        stream: _reviewService.getPropertyReviews(
                            widget.property.propertyId),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text('Belum ada ulasan');
                          }

                          final reviews = snapshot.data!.take(3).toList();

                          return Column(
                            children: reviews.map((review) {
                              return _ReviewCard(review: review);
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Harga per malam',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    'Rp ${widget.property.pricePerNight.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingScreen(property: widget.property),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
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
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                child: Text(review.userName?[0] ?? 'U'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName ?? 'User',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < review.rating.round()
                              ? Icons.star
                              : Icons.star_border,
                          size: 16,
                          color: Colors.amber,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}