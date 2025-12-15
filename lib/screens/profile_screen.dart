import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:luxora_app/services/auth_service.dart';
import 'package:luxora_app/services/booking_service.dart';
import 'package:luxora_app/models/user_model.dart';
import 'package:luxora_app/models/booking_model.dart';
import 'package:luxora_app/config/app_theme.dart';
import 'package:luxora_app/screens/login_screen.dart';
import 'package:luxora_app/screens/add_property_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final BookingService _bookingService = BookingService();
  UserModel? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?.uid;

    if (userId != null) {
      final userData = await authService.getUserData(userId);
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final authService = Provider.of<AuthService>(context, listen: false);
              await authService.signOut();
              
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Silakan login untuk melihat profile',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // App Bar with Profile Header
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: AppGradients.primaryGradient,
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              backgroundImage: user.photoURL != null
                                  ? NetworkImage(user.photoURL!)
                                  : null,
                              child: user.photoURL == null
                                  ? Text(
                                      _userData?.fullName[0].toUpperCase() ?? 'U',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _userData?.fullName ?? user.displayName ?? 'User',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _userData?.email ?? user.email ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Profile Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Account Info
                        const Text(
                          'Informasi Akun',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _ProfileInfoCard(
                          icon: Icons.phone,
                          title: 'Nomor Telepon',
                          value: _userData?.phoneNumber ?? '-',
                        ),
                        const SizedBox(height: 12),
                        _ProfileInfoCard(
                          icon: Icons.calendar_today,
                          title: 'Bergabung Sejak',
                          value: _userData?.createdAt != null
                              ? '${_userData!.createdAt.day}/${_userData!.createdAt.month}/${_userData!.createdAt.year}'
                              : '-',
                        ),

                        const SizedBox(height: 24),

                        // Bookings Section
                        const Text(
                          'Pemesanan Saya',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Bookings List
                StreamBuilder<List<BookingModel>>(
                  stream: _bookingService.getUserBookings(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Belum ada pemesanan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    final bookings = snapshot.data!;

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final booking = bookings[index];
                            return _BookingCard(booking: booking);
                          },
                          childCount: bookings.length,
                        ),
                      ),
                    );
                  },
                ),

                // Settings Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        const Text(
                          'Kelola Properti',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ADD PROPERTY BUTTON - BARU!
                        _SettingsItem(
                          icon: Icons.add_business,
                          title: 'Tambah Properti Baru',
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddPropertyScreen(),
                              ),
                            );
                            
                            if (result == true) {
                              // Refresh if needed
                              setState(() {});
                            }
                          },
                        ),

                        const SizedBox(height: 24),
                        const Text(
                          'Pengaturan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        _SettingsItem(
                          icon: Icons.edit,
                          title: 'Edit Profile',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fitur segera hadir'),
                              ),
                            );
                          },
                        ),
                        
                        _SettingsItem(
                          icon: Icons.lock,
                          title: 'Ubah Password',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fitur segera hadir'),
                              ),
                            );
                          },
                        ),
                        
                        _SettingsItem(
                          icon: Icons.help,
                          title: 'Bantuan',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fitur segera hadir'),
                              ),
                            );
                          },
                        ),
                        
                        _SettingsItem(
                          icon: Icons.info,
                          title: 'Tentang Luxora',
                          onTap: () {
                            showAboutDialog(
                              context: context,
                              applicationName: 'Luxora',
                              applicationVersion: '1.0.0',
                              applicationIcon: const Icon(
                                Icons.hotel,
                                size: 48,
                                color: AppTheme.primaryColor,
                              ),
                              children: [
                                const Text(
                                  'Aplikasi pemesanan hotel dan villa terpercaya',
                                ),
                              ],
                            );
                          },
                        ),
                        
                        _SettingsItem(
                          icon: Icons.logout,
                          title: 'Logout',
                          onTap: _logout,
                          textColor: AppTheme.errorColor,
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ProfileInfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;

  const _BookingCard({required this.booking});

  Color _getStatusColor() {
    switch (booking.bookingStatus) {
      case 'confirmed':
        return AppTheme.successColor;
      case 'cancelled':
        return AppTheme.errorColor;
      default:
        return AppTheme.warningColor;
    }
  }

  String _getStatusText() {
    switch (booking.bookingStatus) {
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return booking.bookingStatus;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking ID: ${booking.bookingId.substring(0, 8)}...',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(),
                    style: TextStyle(
                      color: _getStatusColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${booking.checkInDate.day}/${booking.checkInDate.month}/${booking.checkInDate.year} - ${booking.checkOutDate.day}/${booking.checkOutDate.month}/${booking.checkOutDate.year}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              '${booking.totalNights} malam • ${booking.numberOfGuests} tamu',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Rp ${booking.totalPrice.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: textColor ?? AppTheme.primaryColor),
        title: Text(
          title,
          style: TextStyle(color: textColor),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.grey[50],
      ),
    );
  }
}