import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'config/firebase_config.dart';
import 'config/app_theme.dart';

// SERVICES
import 'services/auth_service.dart';
import 'services/booking_service.dart';
import 'services/review_service.dart';
import 'services/wishlist_service.dart';
import 'services/property_service.dart';

// SCREENS
import 'screens/splash_screen.dart';

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
        Provider(create: (_) => PropertyService()),
        Provider(create: (_) => WishlistService()),
        Provider(create: (_) => BookingService()),
        Provider(create: (_) => ReviewService()),
      ],
      child: MaterialApp(
        title: 'Luxora',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
