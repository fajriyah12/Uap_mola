import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../screens/auth/login_screen.dart';
import '../screens/user/main_navigation.dart';
import '../screens/admin/admin_dashboard_screen.dart';


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // 🔄 Masih cek status login
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❌ Belum login
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // ✅ Sudah login - CEK ROLE
        return FutureBuilder<String?>(
          future: authService.getUserRole(),
          builder: (context, roleSnapshot) {
            // Loading role
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // Cek role
            final role = roleSnapshot.data;

            if (role == 'admin') {
              // ✅ ADMIN -> Dashboard Admin
              return const AdminDashboardScreen();
            } else {
              // ✅ USER -> Main Navigation (dengan bottom nav)
              return const MainNavigation();
            }
          },
        );
      },
    );
  }
}