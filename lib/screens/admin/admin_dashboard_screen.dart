import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth/login_admin_screen.dart';
import 'add_hotel_screen.dart';
import 'admin_property_list_screen.dart';
import 'admin_booking_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    const Color primaryBrown = Color(0xFF6F4E37);
    const Color cream = Color(0xFFF5EFE6);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: cream,

        // ================= APP BAR =================
        appBar: AppBar(
          backgroundColor: primaryBrown,
          elevation: 4,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text(
            "Admin Dashboard",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminLoginScreen(),
                  ),
                  (route) => false,
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
                "Selamat Datang, Admin!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryBrown,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Kelola properti & booking dengan mudah",
                style: TextStyle(color: Colors.brown),
              ),
              const SizedBox(height: 28),

              // ================= GRID MENU =================
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 18,
                crossAxisSpacing: 18,
                childAspectRatio: 0.95,
                children: [
                  _DashboardCard(
                    title: "Tambah Hotel",
                    imageUrl:
                        "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddHotelScreen(),
                        ),
                      );
                    },
                  ),

                  _DashboardCard(
                    title: "Data Hotel",
                    imageUrl:
                        "https://images.unsplash.com/photo-1505691938895-1758d7feb511?auto=format&fit=crop&w=800&q=80",

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminHotelListScreen(),
                        ),
                      );
                    },
                  ),

                  _DashboardCard(
                    title: "Booking User",
                    imageUrl:
                        "https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=800",
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

// ================= DASHBOARD CARD (IMAGE VERSION) =================
class _DashboardCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // ===== IMAGE =====
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 50),
                ),
              ),
            ),

            // ===== DARK OVERLAY =====
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.65),
                    Colors.black.withOpacity(0.15),
                  ],
                ),
              ),
            ),

            // ===== TITLE =====
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
