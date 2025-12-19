import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:luxora_app/services/auth_service.dart';
import 'package:luxora_app/services/wishlist_service.dart';
import 'package:luxora_app/services/property_service.dart';
import 'package:luxora_app/models/wishlist_model.dart';
import 'package:luxora_app/models/property_model.dart';
import 'package:luxora_app/screens/property_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final WishlistService _wishlistService = WishlistService();
  final PropertyService _propertyService = PropertyService();

  Stream<List<WishlistModel>>? _wishlistStream;
  String? _userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final auth = Provider.of<AuthService>(context);
    if (auth.currentUser != null && _wishlistStream == null) {
      _userId = auth.currentUser!.uid;
      _wishlistStream = _wishlistService.getUserWishlist(_userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Scaffold(
        body: Center(child: Text('Silakan login')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorit'),
      ),
      body: StreamBuilder<List<WishlistModel>>(
        stream: _wishlistStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Belum ada favorit'),
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

              /// 🔥 PERBAIKAN UTAMA DI SINI
              return FutureBuilder<PropertyModel?>(
                future: _propertyService.getPropertyById(
                wishlist.propertyId,
                ),
                builder: (context, propSnap) {
                  if (propSnap.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (!propSnap.hasData || propSnap.data == null) {
                    return const SizedBox.shrink();
                  }

                  final property = propSnap.data!;

                  return _WishlistCard(
                    property: property,
                    onRemove: () {
                      _wishlistService.removeFromWishlist(
                        userId: _userId!,
                        propertyId: property.propertyId,
                      );
                    },
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
      child: ListTile(
        leading: property.images.isNotEmpty
            ? Image.network(
                property.images.first,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              )
            : const Icon(Icons.hotel),
        title: Text(property.name),
        subtitle: Text(property.city),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.red),
          onPressed: onRemove,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PropertyDetailScreen(property: property),
            ),
          );
        },
      ),
    );
  }
}
