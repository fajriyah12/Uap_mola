import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/property_service.dart';
import '../../models/property_model.dart';
import '../../config/app_theme.dart';
import '../screens/search_screen.dart';
import '../screens/property_detail_screen.dart';
import '../screens/wishlist_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/booking_list_screen.dart'; // ✅ BARU

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PropertyService _propertyService = PropertyService();
  int _selectedIndex = 0;
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Hotel', 'Villa', 'Homestay'];

  // ===============================
  // ✅ FIXED BOTTOM NAV BOOKING
  // ===============================
  void _onBottomNavTapped(int index) {
    if (index == 0) return;

    setState(() => _selectedIndex = index);

    switch (index) {
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        ).then((_) => setState(() => _selectedIndex = 0));
        break;

      case 2:
        // ✅ BOOKING LIST / HISTORY (BUKAN BookingScreen)
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BookingListScreen()),
        ).then((_) => setState(() => _selectedIndex = 0));
        break;

      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        ).then((_) => setState(() => _selectedIndex = 0));
        break;
    }
  }

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
                        const Icon(Icons.search,
                            color: AppTheme.textSecondary),
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

      // ===============================
      // BOTTOM NAVIGATION
      // ===============================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            activeIcon: Icon(Icons.bookmark),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ===============================
// PROPERTY CARD (TIDAK DIUBAH)
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
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                property.images.first,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${property.pricePerNight.toStringAsFixed(0)}/malam',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
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
