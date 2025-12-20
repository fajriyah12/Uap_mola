import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/property_service.dart';
import '../../../models/property_model.dart';
import '../../../config/app_theme.dart';
import 'package:luxora_app/screens/user/search_screen.dart';
import 'property_detail_screen.dart';
import 'wishlist_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool showBottomNav;

  const HomeScreen({
    super.key,
    this.showBottomNav = true,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PropertyService _propertyService = PropertyService();
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Hotel', 'Villa', 'Homestay'];

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ===============================
            // APP BAR
            // ===============================
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false, 
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, ${user?.displayName ?? 'User'}!',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const Text(
                    'Let start your journey!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.favorite_border,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WishlistScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            // ===============================
            // SEARCH BAR
            // ===============================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SearchScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Cari hotel atau villa...',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ===============================
            // CATEGORY FILTER
            // ===============================
            SliverToBoxAdapter(
              child: SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category == _selectedCategory;

                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        backgroundColor: Colors.grey[100],
                        selectedColor: AppTheme.primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppTheme.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ===============================
            // PROPERTY LIST
            // ===============================
            StreamBuilder<List<PropertyModel>>(
              stream: _selectedCategory == 'All'
                  ? _propertyService.getAllProperties()
                  : _propertyService
                      .searchByType(_selectedCategory.toLowerCase()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text('Belum ada properti tersedia'),
                      ),
                    ),
                  );
                }

                final properties = snapshot.data!;

                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final property = properties[index];
                        return _PropertyCard(property: property);
                      },
                      childCount: properties.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================
// PROPERTY CARD
// ===============================
class _PropertyCard extends StatelessWidget {
  final PropertyModel property;

  const _PropertyCard({required this.property});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PropertyDetailScreen(property: property),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===============================
            // PROPERTY IMAGE
            // ===============================
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: property.images.isNotEmpty
                  ? Image.network(
                      property.images.first,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.hotel,
                            size: 40,
                            color: Colors.grey,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 120,
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 120,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.hotel,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
            ),

            // ===============================
            // PROPERTY INFO
            // ===============================
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property Name
                  Text(
                    property.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.city,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Price
                  Text(
                    'Rp ${property.pricePerNight.toStringAsFixed(0)}/malam',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}