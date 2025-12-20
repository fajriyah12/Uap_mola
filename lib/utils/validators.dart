import 'constants.dart';

class Validators {
  // Email Validator
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email harus diisi';
    }

    // Regular expression untuk validasi email
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }

    return null;
  }

  // Password Validator
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password harus diisi';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Password minimal ${AppConstants.minPasswordLength} karakter';
    }

    return null;
  }

  // Confirm Password Validator
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password harus diisi';
    }

    if (value != password) {
      return 'Password tidak sama';
    }

    return null;
  }

  // Name Validator
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama harus diisi';
    }

    if (value.length < 3) {
      return 'Nama minimal 3 karakter';
    }

    return null;
  }

  // Phone Number Validator
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon harus diisi';
    }

    // Remove whitespace and special characters
    final cleanedValue = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanedValue.length < AppConstants.minPhoneLength) {
      return 'Nomor telepon minimal ${AppConstants.minPhoneLength} digit';
    }

    if (cleanedValue.length > AppConstants.maxPhoneLength) {
      return 'Nomor telepon maksimal ${AppConstants.maxPhoneLength} digit';
    }

    return null;
  }

  // Required Field Validator
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName harus diisi';
    }
    return null;
  }

  // Number Validator
  static String? validateNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName harus diisi';
    }

    final number = double.tryParse(value);
    if (number == null) {
      return '$fieldName harus berupa angka';
    }

    return null;
  }

  // Price Validator
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Harga harus diisi';
    }

    final price = double.tryParse(value);
    if (price == null) {
      return 'Harga harus berupa angka';
    }

    if (price <= 0) {
      return 'Harga harus lebih dari 0';
    }

    return null;
  }

  // Rating Validator
  static String? validateRating(double? value) {
    if (value == null) {
      return 'Rating harus diisi';
    }

    if (value < AppConstants.minRating || value > AppConstants.maxRating) {
      return 'Rating harus antara ${AppConstants.minRating} - ${AppConstants.maxRating}';
    }

    return null;
  }

  // URL Validator
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL optional
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Format URL tidak valid';
    }

    return null;
  }

  // Address Validator
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Alamat harus diisi';
    }

    if (value.length < 10) {
      return 'Alamat terlalu pendek (minimal 10 karakter)';
    }

    return null;
  }

  // Description Validator
  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Deskripsi harus diisi';
    }

    if (value.length < 20) {
      return 'Deskripsi minimal 20 karakter';
    }

    if (value.length > 1000) {
      return 'Deskripsi maksimal 1000 karakter';
    }

    return null;
  }

  // Date Validator
  static String? validateDate(DateTime? value) {
    if (value == null) {
      return 'Tanggal harus diisi';
    }

    if (value.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return 'Tanggal tidak valid (sudah lewat)';
    }

    return null;
  }

  // Check-out Date Validator
  static String? validateCheckOutDate(DateTime? checkOut, DateTime? checkIn) {
    if (checkOut == null) {
      return 'Tanggal check-out harus diisi';
    }

    if (checkIn == null) {
      return 'Pilih tanggal check-in terlebih dahulu';
    }

    if (checkOut.isBefore(checkIn) || checkOut.isAtSameMomentAs(checkIn)) {
      return 'Check-out harus setelah check-in';
    }

    final daysDifference = checkOut.difference(checkIn).inDays;
    if (daysDifference > AppConstants.maxBookingDays) {
      return 'Maksimal ${AppConstants.maxBookingDays} malam';
    }

    return null;
  }

  // Guests Number Validator
  static String? validateGuestsNumber(int? value, int maxGuests) {
    if (value == null || value <= 0) {
      return 'Jumlah tamu harus lebih dari 0';
    }

    if (value > maxGuests) {
      return 'Maksimal $maxGuests tamu';
    }

    return null;
  }

  // Special Characters Validator (untuk username, propertyId, dll)
  static String? validateNoSpecialChars(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName harus diisi';
    }

    final specialCharsRegex = RegExp(r'^[a-zA-Z0-9_-]+$');
    if (!specialCharsRegex.hasMatch(value)) {
      return '$fieldName tidak boleh mengandung karakter khusus';
    }

    return null;
  }

  // File Size Validator (untuk upload image)
  static String? validateFileSize(int fileSizeInBytes, {int maxSizeInMB = 5}) {
    final maxSizeInBytes = maxSizeInMB * 1024 * 1024;
    
    if (fileSizeInBytes > maxSizeInBytes) {
      return 'Ukuran file maksimal ${maxSizeInMB}MB';
    }

    return null;
  }

  // Image Extension Validator
  static String? validateImageExtension(String fileName) {
    final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    final extension = fileName.split('.').last.toLowerCase();

    if (!validExtensions.contains(extension)) {
      return 'Format file harus: ${validExtensions.join(', ')}';
    }

    return null;
  }
}