class AppConstants {
  // App Info
  static const String appName = 'Luxora';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Hotel and Villa Booking Application';

  // Property Types
  static const String typeHotel = 'hotel';
  static const String typeVilla = 'villa';
  static const String typeHomestay = 'homestay';

  static const List<String> propertyTypes = [
    typeHotel,
    typeVilla,
    typeHomestay,
  ];

  // Booking Status
  static const String bookingStatusConfirmed = 'confirmed';
  static const String bookingStatusCancelled = 'cancelled';
  static const String bookingStatusCompleted = 'completed';

  // Payment Status
  static const String paymentStatusPending = 'pending';
  static const String paymentStatusPaid = 'paid';
  static const String paymentStatusFailed = 'failed';

  // Payment Methods
  static const String paymentMethodBRI = 'BRI';
  static const String paymentMethodBCA = 'BCA';
  static const String paymentMethodMandiri = 'Mandiri';
  static const String paymentMethodGopay = 'GoPay';
  static const String paymentMethodOvo = 'OVO';
  static const String paymentMethodDana = 'DANA';

  static const List<String> paymentMethods = [
    paymentMethodBRI,
    paymentMethodBCA,
    paymentMethodMandiri,
    paymentMethodGopay,
    paymentMethodOvo,
    paymentMethodDana,
  ];

  // Popular Cities
  static const List<String> popularCities = [
    'Jakarta',
    'Bandung',
    'Bali',
    'Yogyakarta',
    'Surabaya',
    'Medan',
    'Semarang',
    'Makassar',
    'Lombok',
    'Malang',
  ];

  // Common Facilities
  static const List<String> commonFacilities = [
    'WiFi',
    'AC',
    'TV',
    'Swimming Pool',
    'Parking',
    'Restaurant',
    'Gym',
    'Spa',
    'Kitchen',
    'Laundry',
    'Room Service',
    'Garden',
    'BBQ',
    'Security',
    'Pet Friendly',
  ];

  // Price Ranges
  static const double minPrice = 0;
  static const double maxPrice = 10000000;
  static const double defaultMinPrice = 0;
  static const double defaultMaxPrice = 5000000;

  // Limits
  static const int maxImagesPerProperty = 10;
  static const int maxGuestsPerProperty = 20;
  static const int maxBedroomsPerProperty = 10;
  static const int maxBathroomsPerProperty = 10;
  static const int minBookingDays = 1;
  static const int maxBookingDays = 30;

  // Rating
  static const double minRating = 1.0;
  static const double maxRating = 5.0;

  // Dates
  static const int maxAdvanceBookingDays = 365;
  static const int minAdvanceBookingDays = 1;

  // Error Messages
  static const String errorNoInternet = 'Tidak ada koneksi internet';
  static const String errorGeneral = 'Terjadi kesalahan, silakan coba lagi';
  static const String errorAuthFailed = 'Autentikasi gagal';
  static const String errorPropertyNotFound = 'Properti tidak ditemukan';
  static const String errorBookingFailed = 'Pemesanan gagal';
  static const String errorPaymentFailed = 'Pembayaran gagal';

  // Success Messages
  static const String successLogin = 'Login berhasil';
  static const String successSignup = 'Pendaftaran berhasil';
  static const String successBooking = 'Pemesanan berhasil';
  static const String successPayment = 'Pembayaran berhasil';
  static const String successAddWishlist = 'Ditambahkan ke wishlist';
  static const String successRemoveWishlist = 'Dihapus dari wishlist';

  // Validation
  static const int minPasswordLength = 6;
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 15;

  // Image Placeholders
  static const String placeholderImage = 'https://via.placeholder.com/400x300.png?text=No+Image';
  static const String placeholderUserImage = 'https://via.placeholder.com/150x150.png?text=User';

  // Currency
  static const String currency = 'Rp';
  static const String currencyCode = 'IDR';

  // Date Formats
  static const String dateFormatDisplay = 'dd MMMM yyyy';
  static const String dateFormatShort = 'dd/MM/yyyy';
  static const String dateFormatWithTime = 'dd MMM yyyy HH:mm';

  // Storage Paths
  static const String storagePropertiesPath = 'properties';
  static const String storageUsersPath = 'users';

  // Pagination
  static const int itemsPerPage = 20;
  static const int searchResultsLimit = 50;

  // Cache
  static const int cacheValidityHours = 24;
}