import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditHotelScreen extends StatefulWidget {
  final String hotelId;
  final Map<String, dynamic> hotelData;

  const EditHotelScreen({Key? key, required this.hotelId, required this.hotelData}) : super(key: key);

  @override
  State<EditHotelScreen> createState() => _EditHotelScreenState();
}

class _EditHotelScreenState extends State<EditHotelScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController cityController;
  late TextEditingController addressController;
  late TextEditingController descController;
  late TextEditingController priceController;
  late TextEditingController bedroomsController;
  late TextEditingController bathroomsController;
  late TextEditingController guestsController;
  late TextEditingController ratingController;
  late TextEditingController reviewsController;
  late TextEditingController imageController;

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

  @override
  void initState() {
    super.initState();
    final data = widget.hotelData;

    nameController = TextEditingController(text: data['name'] ?? '');
    cityController = TextEditingController(text: data['city'] ?? '');
    addressController = TextEditingController(text: data['address'] ?? '');
    descController = TextEditingController(text: data['description'] ?? '');
    priceController = TextEditingController(text: data['pricePerNight']?.toString() ?? '');
    bedroomsController = TextEditingController(text: data['bedrooms']?.toString() ?? '');
    bathroomsController = TextEditingController(text: data['bathrooms']?.toString() ?? '');
    guestsController = TextEditingController(text: data['maxGuests']?.toString() ?? '');
    ratingController = TextEditingController(text: data['rating']?.toString() ?? '');
    reviewsController = TextEditingController(text: data['totalReviews']?.toString() ?? '');
    imageController = TextEditingController();

    selectedType = data['type'] ?? 'hotel';
    facilities = List<String>.from(data['facilities'] ?? []);
    images = List<String>.from(data['images'] ?? []);
  }

  Future<void> updateHotel() async {
    if (!_formKey.currentState!.validate()) return;

    if (facilities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih minimal 1 fasilitas")),
      );
      return;
    }

    if (images.isEmpty) images.add(defaultImage);

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('properties').doc(widget.hotelId).update({
        'name': nameController.text.trim(),
        'type': selectedType,
        'city': cityController.text.trim(),
        'address': addressController.text.trim(),
        'description': descController.text.trim(),
        'pricePerNight': int.tryParse(priceController.text) ?? 0,
        'bedrooms': int.tryParse(bedroomsController.text) ?? 0,
        'bathrooms': int.tryParse(bathroomsController.text) ?? 0,
        'maxGuests': int.tryParse(guestsController.text) ?? 0,
        'rating': double.tryParse(ratingController.text) ?? 0,
        'totalReviews': int.tryParse(reviewsController.text) ?? 0,
        'facilities': facilities,
        'images': images,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Properti berhasil diupdate")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal update properti: $e")),
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
      appBar: AppBar(title: const Text("Edit Properti")),
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
                      decoration: const InputDecoration(hintText: "https://..."),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: addImage,
                  )
                ],
              ),

              Wrap(
                children: images.map((e) => Chip(
                  label: Text(
                    e,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onDeleted: () {
                    setState(() {
                      images.remove(e);
                    });
                  },
                )).toList(),
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : updateHotel,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("UPDATE PROPERTI"),
              ),
            ],
          ),
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
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
