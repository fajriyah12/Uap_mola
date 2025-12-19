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

  Future<void> addHotel() async {
    if (!_formKey.currentState!.validate()) return;

    if (facilities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih minimal 1 fasilitas")),
      );
      return;
    }

    if (images.isEmpty) {
      images.add(defaultImage);
    }

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
        'images': images,
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

  void addImage() {
    if (imageController.text.trim().isNotEmpty) {
      setState(() {
        images.add(imageController.text.trim());
        imageController.clear();
      });
    }
  }

  void toggleFacility(String facility) {
    setState(() {
      if (facilities.contains(facility)) {
        facilities.remove(facility);
      } else {
        facilities.add(facility);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Properti (Admin)")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              _input(nameController, "Nama Properti"),
              _dropdown(),
              _input(cityController, "Kota"),
              _input(addressController, "Alamat"),
              _input(descController, "Deskripsi", maxLines: 3),
              _number(priceController, "Harga per malam"),
              _number(bedroomsController, "Jumlah Kamar Tidur"),
              _number(bathroomsController, "Jumlah Kamar Mandi"),
              _number(guestsController, "Maksimal Tamu"),
              _rating(),
              _number(reviewsController, "Total Ulasan"),

              const SizedBox(height: 16),
              const Text("Fasilitas", style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: availableFacilities.map((f) {
                  return FilterChip(
                    label: Text(f),
                    selected: facilities.contains(f),
                    onSelected: (_) => toggleFacility(f),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              const Text("Gambar (URL)"),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: imageController,
                      decoration:
                          const InputDecoration(hintText: "https://..."),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: addImage,
                  )
                ],
              ),

              Wrap(
                children: images.map((e) => const Chip(label: Text("Gambar"))).toList(),
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : addHotel,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("SIMPAN PROPERTI"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(TextEditingController c, String label,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        maxLines: maxLines,
        validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
        decoration: InputDecoration(labelText: label),
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
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _rating() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ratingController,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
        validator: (v) {
          final value = double.tryParse(v!);
          if (value == null) return "Harus angka";
          if (value < 0 || value > 5) return "Rating 0 - 5";
          return null;
        },
        decoration: const InputDecoration(labelText: "Rating (0 - 5)"),
      ),
    );
  }

  Widget _dropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField(
        value: selectedType,
        decoration: const InputDecoration(labelText: "Tipe Properti"),
        items: propertyTypes
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) => setState(() => selectedType = v!),
      ),
    );
  }
}
