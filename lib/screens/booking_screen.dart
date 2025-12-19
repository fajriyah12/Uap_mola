import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:luxora_app/models/property_model.dart';
import 'package:luxora_app/models/booking_model.dart';
import 'package:luxora_app/services/auth_service.dart';
import 'package:luxora_app/services/booking_service.dart';
import 'package:luxora_app/config/app_theme.dart';
import 'package:luxora_app/utils/constants.dart';

class BookingScreen extends StatefulWidget {
  final PropertyModel property;

  const BookingScreen({super.key, required this.property});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String _getPaymentLabel(String method) {
  switch (method) {
    case AppConstants.paymentMethodBRI:
      return 'Transfer Bank BRI';
    case AppConstants.paymentMethodBCA:
      return 'Transfer Bank BCA';
    case AppConstants.paymentMethodMandiri:
      return 'Transfer Bank Mandiri';
    case AppConstants.paymentMethodGopay:
      return 'GoPay';
    case AppConstants.paymentMethodOvo:
      return 'OVO';
    case AppConstants.paymentMethodDana:
      return 'DANA';
    default:
      return method;
  }
}
  final _formKey = GlobalKey<FormState>();
  final BookingService _bookingService = BookingService();
  
  final _guestNameController = TextEditingController();
  final _guestPhoneController = TextEditingController();
  final _guestEmailController = TextEditingController();
  final _specialRequestController = TextEditingController();

  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _numberOfGuests = 1;
  String _paymentMethod = AppConstants.paymentMethodBRI;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeGuestInfo();
  }

  Future<void> _initializeGuestInfo() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    if (user != null) {
      final userData = await authService.getUserData(user.uid);
      if (userData != null) {
        setState(() {
          _guestNameController.text = userData.fullName;
          _guestPhoneController.text = userData.phoneNumber;
          _guestEmailController.text = userData.email;
        });
      }
    }
  }

  @override
  void dispose() {
    _guestNameController.dispose();
    _guestPhoneController.dispose();
    _guestEmailController.dispose();
    _specialRequestController.dispose();
    super.dispose();
  }

  Future<void> _selectCheckInDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _checkInDate = picked;
        if (_checkOutDate != null && _checkOutDate!.isBefore(_checkInDate!)) {
          _checkOutDate = null;
        }
      });
    }
  }

  Future<void> _selectCheckOutDate() async {
    if (_checkInDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal check-in terlebih dahulu')),
      );
      return;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: _checkInDate!.add(const Duration(days: 1)),
      firstDate: _checkInDate!.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _checkOutDate = picked);
    }
  }

  int get _totalNights {
    if (_checkInDate == null || _checkOutDate == null) return 0;
    return _checkOutDate!.difference(_checkInDate!).inDays;
  }

  double get _totalPrice {
    return widget.property.pricePerNight * _totalNights;
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    if (_checkInDate == null || _checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal check-in dan check-out')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?.uid;

    if (userId == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }

    // Check availability
    final isAvailable = await _bookingService.checkAvailability(
      propertyId: widget.property.propertyId,
      checkIn: _checkInDate!,
      checkOut: _checkOutDate!,
    );

    if (!isAvailable) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Properti tidak tersedia untuk tanggal tersebut'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // Create booking - DIPERBAIKI dengan paymentStatus dan bookingStatus yang benar
    final booking = BookingModel(
      bookingId: '',
      userId: userId,
      propertyId: widget.property.propertyId,
      checkInDate: _checkInDate!,
      checkOutDate: _checkOutDate!,
      numberOfGuests: _numberOfGuests,
      totalNights: _totalNights,
      totalPrice: _totalPrice,
      paymentMethod: _paymentMethod,
      paymentStatus: 'paid', // SET SEBAGAI PAID (simulasi pembayaran berhasil)
      bookingStatus: 'confirmed', // SET SEBAGAI CONFIRMED
      guestName: _guestNameController.text.trim(),
      guestPhone: _guestPhoneController.text.trim(),
      guestEmail: _guestEmailController.text.trim(),
      specialRequest: _specialRequestController.text.trim().isNotEmpty
          ? _specialRequestController.text.trim()
          : null,
      createdAt: DateTime.now(),
    );

    print('Creating booking with:');
    print('- userId: $userId');
    print('- propertyId: ${widget.property.propertyId}');
    print('- paymentStatus: paid');
    print('- bookingStatus: confirmed');

    final bookingId = await _bookingService.createBooking(booking);

    setState(() => _isLoading = false);

    if (bookingId != null) {
      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Pemesanan Berhasil '),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text('Booking ID: ${bookingId.substring(0, 8)}...'),
                const SizedBox(height: 8),
                const Text(
                  '✅ Pembayaran berhasil dikonfirmasi',
                  style: TextStyle(
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pemesanan Anda telah dikonfirmasi dan dapat dilihat di riwayat pemesanan',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Back to detail
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuat pemesanan. Silakan coba lagi.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pemesanan'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Property Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: widget.property.images.isNotEmpty
                          ? Image.network(
                              widget.property.images.first,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[300],
                              child: const Icon(Icons.hotel),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.property.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.property.city,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Check-in Date
            const Text(
              'Tanggal Check-in',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectCheckInDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _checkInDate != null
                      ? DateFormat('dd MMMM yyyy').format(_checkInDate!)
                      : 'Pilih tanggal check-in',
                  style: TextStyle(
                    color: _checkInDate != null ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Check-out Date
            const Text(
              'Tanggal Check-out',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectCheckOutDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _checkOutDate != null
                      ? DateFormat('dd MMMM yyyy').format(_checkOutDate!)
                      : 'Pilih tanggal check-out',
                  style: TextStyle(
                    color: _checkOutDate != null ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Number of Guests
            const Text(
              'Jumlah Tamu',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: _numberOfGuests > 1
                      ? () => setState(() => _numberOfGuests--)
                      : null,
                ),
                Text(
                  '$_numberOfGuests',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _numberOfGuests < widget.property.maxGuests
                      ? () => setState(() => _numberOfGuests++)
                      : null,
                ),
                Text(
                  'Maks. ${widget.property.maxGuests} tamu',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Guest Information
            const Text(
              'Informasi Tamu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _guestNameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama harus diisi';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _guestPhoneController,
              decoration: const InputDecoration(
                labelText: 'Nomor Telepon',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nomor telepon harus diisi';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _guestEmailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email harus diisi';
                }
                if (!value.contains('@')) {
                  return 'Format email tidak valid';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _specialRequestController,
              decoration: const InputDecoration(
                labelText: 'Permintaan Khusus (Opsional)',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Payment Method
            const Text(
              'Metode Pembayaran',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
  value: _paymentMethod,
  decoration: const InputDecoration(
    prefixIcon: Icon(Icons.payment),
    border: OutlineInputBorder(),
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
  ),
  items: AppConstants.paymentMethods.map((method) {
    return DropdownMenuItem<String>(
      value: method,
      child: Text(_getPaymentLabel(method)),
    );
  }).toList(),
  onChanged: (value) {
    if (value != null) {
      setState(() => _paymentMethod = value);
    }
  },
),


            const SizedBox(height: 24),

            // Price Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Harga per malam'),
                      Text(
                        'Rp ${widget.property.pricePerNight.toStringAsFixed(0)}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total malam'),
                      Text('$_totalNights malam'),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Pembayaran',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rp ${_totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _isLoading ? null : _submitBooking,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Konfirmasi Pemesanan'),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}