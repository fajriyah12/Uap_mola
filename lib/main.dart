import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'config/firebase_config.dart';
import 'config/app_theme.dart';
import 'services/auth_service.dart';
import 'package:luxora_app/services/booking_service.dart';
import 'package:luxora_app/services/review_service.dart';
import 'package:luxora_app/services/wishlist_service.dart';
import 'package:luxora_app/services/property_service.dart';
import 'package:luxora_app/screens/login_screen.dart';
import 'package:luxora_app/screens/signup_screen.dart';
import 'package:luxora_app/screens/home_screen.dart';
import 'package:luxora_app/screens/booking_screen.dart';
import 'package:luxora_app/screens/profile_screen.dart';
import 'package:luxora_app/screens/property_detail_screen.dart';
import 'package:luxora_app/screens/search_screen.dart';
import 'package:luxora_app/screens/wishlist_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseConfig.firebaseOptions,
  );
  runApp(const LuxoraApp());
}

class LuxoraApp extends StatelessWidget {
  const LuxoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'Luxora',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
