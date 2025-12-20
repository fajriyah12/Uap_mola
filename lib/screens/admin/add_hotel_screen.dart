import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddHotelScreen extends StatefulWidget {
  const AddHotelScreen({Key? key}) : super(key: key);

  @override
  State<AddHotelScreen> createState() => _AddHotelScreenState();
}

class _AddHotelScreenState extends State<AddHotelScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final cityController = TextEditingController();
  final addressController = TextEditingController();
  final descController = TextEditingController();
  final priceController = TextEditingController();
  final bedroomsController = TextEditingController();
  final bathroomsController = TextEditingController();
  final guestsController = TextEditingController();
  final ratingController = TextEditingController();
  final reviewsController = TextEditingController();
  final imageController = TextEditingController();

  String selectedType = 'hotel';
  List<String> facilities = [];
  List<String> images = [];

  bool isLoading = false;

  final List<String> propertyTypes = ['hotel', 'villa', 'homestay'];

  final List<String> availableFacilities = [
    'WiFi',
    'AC',
    'TV',
    'Kitchen',
    'Swimming Pool',
    'Parking',
    'BBQ',
    'Security',
  ];

  final String defaultImage =
      'https://images.unsplash.com/photo-1602343168117-bb8ffe3e2e9f?w=800';

  // ================= VALIDASI URL =================
  bool isValidUrl(String url) {
    return Uri.tryParse(url)?.hasAbsolutePath ?? false;
  }

  void addImage() {
    final url = imageController.text.trim();
    if (url.isEmpty) return;

    if (!isValidUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("URL gambar tidak valid")),
      );
      return;
    }

    setState(() {
      images.add(url);
      imageController.clear();
    });
  }
 

  Future<void> addHotel() async {
    if (!_formKey.currentState!.validate()) return;

    if (facilities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih minimal 1 fasilitas")),
      );
      return;
    }

    final List<String> finalImages =
        images.isNotEmpty ? images : [defaultImage];

    setState(() => isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final propertyId = 'prop_${DateTime.now().millisecondsSinceEpoch}';

      await FirebaseFirestore.instance
          .collection('properties')
          .doc(propertyId)
          .set({
        'propertyId': propertyId,
        'ownerId': uid,
        'name': nameController.text.trim(),
        'type': selectedType,
        'city': cityController.text.trim(),
        'address': addressController.text.trim(),
        'description': descController.text.trim(),
        'pricePerNight': int.parse(priceController.text),
        'bedrooms': int.parse(bedroomsController.text),
        'bathrooms': int.parse(bathroomsController.text),
        'maxGuests': int.parse(guestsController.text),
        'rating': double.parse(ratingController.text),
        'totalReviews': int.parse(reviewsController.text),
        'facilities': facilities,
        'images': finalImages,
        'latitude': -6.2088,
        'longitude': 106.8456,
        'isActive': true,
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Properti berhasil ditambahkan")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menambahkan properti: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  void toggleFacility(String facility) {
    setState(() {
      facilities.contains(facility)
          ? facilities.remove(facility)
          : facilities.add(facility);
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBrown = Color(0xFF6F4E37);
    const Color cream = Color(0xFFF5EFE6);

    return Scaffold(
      backgroundColor: cream,

      // ================= APP BAR =================
      appBar: AppBar(
        title: const Text(
          "Tambah Properti",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryBrown,
        elevation: 4,
      ),

      // ================= BODY =================
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _sectionTitle("Informasi Properti"),
              _input(nameController, "Nama Properti"),
              _dropdown(),
              _input(cityController, "Kota"),
              _input(addressController, "Alamat"),
              _input(descController, "Deskripsi", maxLines: 3),

              _sectionTitle("Detail & Harga"),
              _number(priceController, "Harga per Malam"),
              _number(bedroomsController, "Jumlah Kamar Tidur"),
              _number(bathroomsController, "Jumlah Kamar Mandi"),
              _number(guestsController, "Maksimal Tamu"),
              _rating(),
              _number(reviewsController, "Total Ulasan"),

              _sectionTitle("Fasilitas"),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: availableFacilities.map((f) {
                  return FilterChip(
                    label: Text(f),
                    selected: facilities.contains(f),
                    selectedColor: primaryBrown.withOpacity(0.2),
                    checkmarkColor: primaryBrown,
                    onSelected: (_) => toggleFacility(f),
                  );
                }).toList(),
              ),

              _sectionTitle("Gambar Properti"),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: imageController,
                      decoration: _inputDecoration("URL Gambar"),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: primaryBrown),
                    onPressed: addImage,
                  )
                ],
              ),

              Wrap(
                spacing: 6,
                children: images
                    .map(
                      (_) => const Chip(
                        label: Text("Gambar"),
                        backgroundColor: cream,
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 28),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBrown,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: isLoading ? null : addHotel,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "SIMPAN PROPERTI",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= UI COMPONENT =================

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Color(0xFF6F4E37),
        ),
      ),
    );
  }

  Widget _input(TextEditingController c, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        maxLines: maxLines,
        validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
        decoration: _inputDecoration(label),
      ),
    );
  }

  Widget _number(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: TextInputType.number,
        validator: (v) => int.tryParse(v!) == null ? "Harus angka" : null,
        decoration: _inputDecoration(label),
      ),
    );
  }

  Widget _rating() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ratingController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (v) {
          final value = double.tryParse(v!);
          if (value == null) return "Harus angka";
          if (value < 0 || value > 5) return "Rating 0 - 5";
          return null;
        },
        decoration: _inputDecoration("Rating (0 - 5)"),
      ),
    );
  }

  Widget _dropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField(
        value: selectedType,
        decoration: _inputDecoration("Tipe Properti"),
        items: propertyTypes
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) => setState(() => selectedType = v!),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
