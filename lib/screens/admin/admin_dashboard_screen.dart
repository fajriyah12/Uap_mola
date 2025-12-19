import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth/login_admin_screen.dart';
import 'add_hotel_screen.dart';
import 'admin_property_list_screen.dart';
import 'admin_booking_screen.dart'; // pastikan sudah pakai versi adminId

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return WillPopScope(
      onWillPop: () async => false, // menonaktifkan tombol back fisik / gesture
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),

        // ================= APP BAR =================
        appBar: AppBar(
          title: const Text("Admin Dashboard"),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 1,
          automaticallyImplyLeading: false, // hilangkan panah back
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: "Logout",
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminLoginScreen(),
                  ),
                  (route) => false, // hapus semua route sebelumnya
                );
              },
            ),
          ],
        ),

        // ================= BODY =================
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Selamat Datang, Admin 👋",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Kelola hotel dan booking pengguna",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // ================= GRID MENU =================
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1,
                children: [
                  // Tambah Hotel
                  _DashboardCard(
                    icon: Icons.hotel,
                    title: "Tambah Hotel",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddHotelScreen(),
                        ),
                      );
                    },
                  ),

                  // Data Hotel
                  _DashboardCard(
                    icon: Icons.list_alt,
                    title: "Data Hotel",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminHotelListScreen(),
                        ),
                      );
                    },
                  ),

                  // Booking User
                  _DashboardCard(
                    icon: Icons.people,
                    title: "Booking User",
                    onTap: () {
                      if (currentUser != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminBookingScreen(
                              adminId: currentUser.uid,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('User belum login')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= DASHBOARD CARD =================
class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
