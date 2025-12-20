import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  
  static FirebaseOptions firebaseOptions = const FirebaseOptions(
    apiKey: 'AIzaSyCNAR4RZYUCSEm--Fl7jZ7SOa7z6FvpIQw',
    appId: '1:933167062902:android:931723f973a54d1dc86457',
    messagingSenderId: '933167062902',
    projectId: 'luxora-app-6c7c7',
    storageBucket: 'luxora-app-6c7c7.firebasestorage.app',
  );

  static const String usersCollection = 'users';
  static const String propertiesCollection = 'properties';
  static const String bookingsCollection = 'bookings';
  static const String wishlistsCollection = 'wishlists';
  static const String reviewsCollection = 'reviews';
  static const String promosCollection = 'promos';
}
