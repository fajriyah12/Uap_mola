import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:luxora_app/services/auth_service.dart';
import 'package:luxora_app/services/wishlist_service.dart';
import 'package:luxora_app/services/property_service.dart';
import 'package:luxora_app/models/wishlist_model.dart';
import 'package:luxora_app/models/property_model.dart';
import 'package:luxora_app/config/app_theme.dart';
import 'package:luxora_app/screens/property_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final WishlistService _wishlistService = WishlistService();
  final PropertyService _propertyService = PropertyService();

  Future<void> _removeFromWishlist(String userId, String propertyId) async {
    final error = await _wishlistService.removeFromWishlist(
      userId: userId,
      propertyId: propertyId,
    );

    if (error == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dihapus dari wishlist')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userId = authService.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Favorit'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_border,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Silakan login untuk melihat wishlist',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorit'),
        actions: [
          StreamBuilder<List<WishlistModel>>(
            stream: _wishlistService.getUserWishlist(userId),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox.shrink();
              }

              return IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Hapus Semua'),
                      content: const Text(
                        'Apakah Anda yakin ingin menghapus semua favorit?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await _wishlistService.clearAllWishlist(userId);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Semua favorit telah dihapus'),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'Hapus',
                            style: TextStyle(color: AppTheme.errorColor),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<WishlistModel>>(
        stream: _wishlistService.getUserWishlist(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada favorit',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tambahkan properti ke favorit untuk melihatnya di sini',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final wishlists = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: wishlists.length,
            itemBuilder: (context, index) {
              final wishlist = wishlists[index];
              return FutureBuilder<PropertyModel?>(
                future: _propertyService.getPropertyById(wishlist.propertyId),
                builder: (context, propertySnapshot) {
                  if (propertySnapshot.connectionState == ConnectionState.waiting){
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }
                  if (!propertySnapshot.hasData || propertySnapshot.data == null) {
                  return const SizedBox.shrink(); // PROPERTY TIDAK ADA
                  }

                  final property = propertySnapshot.data!;

                  return _WishlistCard(
                    property: property,
                    onRemove: () => _removeFromWishlist(userId, property.propertyId),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _WishlistCard extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback onRemove;

  const _WishlistCard({
    required this.property,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PropertyDetailScreen(property: property),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: property.images.isNotEmpty
                    ? Image.network(
                        property.images.first,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[300],
                            child: const Icon(Icons.hotel, size: 32),
                          );
                        },
                      )
                    : Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: const Icon(Icons.hotel, size: 32),
                      ),
              ),
              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            property.city,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          property.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          ' (${property.totalReviews})',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rp ${property.pricePerNight.toStringAsFixed(0)}/malam',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Remove Button
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: onRemove,
              ),
            ],
          ),
        ),
      ),
    );
  }
}