import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddHotelScreen extends StatefulWidget {
  const AddHotelScreen({super.key});

  @override
  State<AddHotelScreen> createState() => _AddHotelScreenState();
}

class _AddHotelScreenState extends State<AddHotelScreen> {
  // ================= CONSTANT =================
  static const Color _primaryBrown = Color(0xFF6F4E37);
  static const Color _cream = Color(0xFFF5EFE6);

  static const List<String> _propertyTypes = ['hotel', 'villa', 'homestay'];
  static const List<String> _availableFacilities = [
    'WiFi',
    'AC',
    'TV',
    'Kitchen',
    'Swimming Pool',
    'Parking',
    'BBQ',
    'Security',
  ];

  // ================= FORM =================
  final _formKey = GlobalKey<FormState>();

  // ================= CONTROLLERS =================
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _guestsController = TextEditingController();
  final _ratingController = TextEditingController();
  final _reviewsController = TextEditingController();
  final _imageController = TextEditingController();

  // ================= STATE =================
  String _selectedType = 'hotel';
  final List<String> _facilities = [];
  final List<String> _images = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _guestsController.dispose();
    _ratingController.dispose();
    _reviewsController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  // ================= VALIDASI URL =================
  bool _isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && uri.isAbsolute;
  }

  // ================= IMAGE =================
  void _addImage() {
    final url = _imageController.text.trim();
    if (url.isEmpty) return;

    if (!_isValidUrl(url)) {
      _showSnackBar('URL gambar tidak valid');
      return;
    }

    setState(() {
      _images.add(url);
      _imageController.clear();
    });
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  // ================= FACILITY =================
  void _toggleFacility(String facility) {
    setState(() {
      _facilities.contains(facility)
          ? _facilities.remove(facility)
          : _facilities.add(facility);
    });
  }

  // ================= SUBMIT =================
  Future<void> _addHotel() async {
    if (!_formKey.currentState!.validate()) return;

    if (_facilities.isEmpty) {
      _showSnackBar('Pilih minimal 1 fasilitas');
      return;
    }

    if (_images.isEmpty) {
      _showSnackBar('Tambahkan minimal 1 gambar');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final propertyId = 'prop_${DateTime.now().millisecondsSinceEpoch}';

      await FirebaseFirestore.instance
          .collection('properties')
          .doc(propertyId)
          .set({
        'propertyId': propertyId,
        'ownerId': uid,
        'name': _nameController.text.trim(),
        'type': _selectedType,
        'city': _cityController.text.trim(),
        'address': _addressController.text.trim(),
        'description': _descController.text.trim(),
        'pricePerNight': int.parse(_priceController.text),
        'bedrooms': int.parse(_bedroomsController.text),
        'bathrooms': int.parse(_bathroomsController.text),
        'maxGuests': int.parse(_guestsController.text),
        'rating': double.parse(_ratingController.text),
        'totalReviews': int.parse(_reviewsController.text),
        'facilities': _facilities,
        'images': _images,
        'latitude': -6.2088,
        'longitude': 106.8456,
        'isActive': true,
        'createdAt': Timestamp.now(),
      });

      if (!mounted) return;
      _showSnackBar('Properti berhasil ditambahkan');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Gagal menambahkan properti: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Tambah Properti',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      centerTitle: true,
      backgroundColor: _primaryBrown,
      elevation: 4,
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            _buildPropertyInfoSection(),
            _buildPriceDetailsSection(),
            _buildFacilitiesSection(),
            _buildImagesSection(),
            const SizedBox(height: 28),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  // ================= SECTIONS =================
  Widget _buildPropertyInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Informasi Properti'),
        _buildTextInput(_nameController, 'Nama Properti'),
        _buildDropdown(),
        _buildTextInput(_cityController, 'Kota'),
        _buildTextInput(_addressController, 'Alamat'),
        _buildTextInput(_descController, 'Deskripsi', maxLines: 3),
      ],
    );
  }

  Widget _buildPriceDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Detail & Harga'),
        _buildNumberInput(_priceController, 'Harga per Malam'),
        _buildNumberInput(_bedroomsController, 'Jumlah Kamar Tidur'),
        _buildNumberInput(_bathroomsController, 'Jumlah Kamar Mandi'),
        _buildNumberInput(_guestsController, 'Maksimal Tamu'),
        _buildRatingInput(),
        _buildNumberInput(_reviewsController, 'Total Ulasan'),
      ],
    );
  }

  Widget _buildFacilitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Fasilitas'),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: _availableFacilities.map((facility) {
            return FilterChip(
              label: Text(facility),
              selected: _facilities.contains(facility),
              selectedColor: _primaryBrown.withOpacity(0.2),
              checkmarkColor: _primaryBrown,
              onSelected: (_) => _toggleFacility(facility),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Gambar Properti'),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _imageController,
                decoration: _buildInputDecoration('URL Gambar'),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: _primaryBrown),
              onPressed: _addImage,
            ),
          ],
        ),
        if (_images.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(_images.length, (index) {
              final imageUrl = _images[index];
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Chip(
                    label: Text('Gambar ${index + 1}'),
                    backgroundColor: _cream,
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _removeImage(index),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 120,
                    height: 80,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 40),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBrown,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: _isLoading ? null : _addHotel,
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'SIMPAN PROPERTI',
                style:
                    TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
      ),
    );
  }

  // ================= INPUT HELPERS =================
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: _primaryBrown,
        ),
      ),
    );
  }

  Widget _buildTextInput(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
        decoration: _buildInputDecoration(label),
      ),
    );
  }

  Widget _buildNumberInput(TextEditingController controller, String label) {
    return _buildTextInput(controller, label);
  }

  Widget _buildRatingInput() {
    return _buildTextInput(_ratingController, 'Rating (0 - 5)');
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedType,
        decoration: _buildInputDecoration('Tipe Properti'),
        items: _propertyTypes.map((type) {
          return DropdownMenuItem<String>(
            value: type,
            child: Text(type.toUpperCase()),
          );
        }).toList(),
        onChanged: (v) => setState(() => _selectedType = v!),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _primaryBrown, width: 2),
      ),
    );
  }
}
