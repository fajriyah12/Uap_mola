import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditHotelScreen extends StatefulWidget {
  final String hotelId;
  final Map<String, dynamic> hotelData;

  const EditHotelScreen({
    super.key,
    required this.hotelId,
    required this.hotelData,
  });

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

  @override
  void initState() {
    super.initState();
    final data = widget.hotelData;

    nameController = TextEditingController(text: data['name']);
    cityController = TextEditingController(text: data['city']);
    addressController = TextEditingController(text: data['address']);
    descController = TextEditingController(text: data['description']);
    priceController =
        TextEditingController(text: data['pricePerNight']?.toString());
    bedroomsController =
        TextEditingController(text: data['bedrooms']?.toString());
    bathroomsController =
        TextEditingController(text: data['bathrooms']?.toString());
    guestsController =
        TextEditingController(text: data['maxGuests']?.toString());
    ratingController =
        TextEditingController(text: data['rating']?.toString());
    reviewsController =
        TextEditingController(text: data['totalReviews']?.toString());
    imageController = TextEditingController();

    selectedType = data['type'] ?? 'hotel';
    facilities = List<String>.from(data['facilities'] ?? []);
    images = List<String>.from(data['images'] ?? []);
  }

  // ================= VALIDASI URL =================
  bool _isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && uri.isAbsolute;
  }

  void addImage() {
    final url = imageController.text.trim();
    if (url.isEmpty) return;

    if (!_isValidUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL gambar tidak valid')),
      );
      return;
    }

    setState(() {
      images.add(url);
      imageController.clear();
    });
  }

  void toggleFacility(String facility) {
    setState(() {
      facilities.contains(facility)
          ? facilities.remove(facility)
          : facilities.add(facility);
    });
  }

  // ================= UPDATE HOTEL =================
  Future<void> updateHotel() async {
    if (!_formKey.currentState!.validate()) return;

    if (facilities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih minimal 1 fasilitas")),
      );
      return;
    }

    if (images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tambahkan minimal 1 gambar")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('properties')
          .doc(widget.hotelId)
          .update({
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
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Properti berhasil diperbarui")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal update properti: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Properti"),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _section("Informasi Properti"),
            _input(nameController, "Nama Properti"),
            _dropdown(),
            _input(cityController, "Kota"),
            _input(addressController, "Alamat"),
            _input(descController, "Deskripsi", maxLines: 3),

            _section("Detail Properti"),
            _number(priceController, "Harga per Malam"),
            _number(bedroomsController, "Jumlah Kamar Tidur"),
            _number(bathroomsController, "Jumlah Kamar Mandi"),
            _number(guestsController, "Maksimal Tamu"),
            _rating(),
            _number(reviewsController, "Total Ulasan"),

            _section("Fasilitas"),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: availableFacilities.map((f) {
                return FilterChip(
                  label: Text(f),
                  selected: facilities.contains(f),
                  selectedColor: Colors.green.shade100,
                  onSelected: (_) => toggleFacility(f),
                );
              }).toList(),
            ),

            _section("Gambar Properti"),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: imageController,
                    decoration: const InputDecoration(
                      hintText: "https://image-url",
                      prefixIcon: Icon(Icons.image),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, size: 30),
                  color: Colors.green,
                  onPressed: addImage,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ===== PREVIEW GAMBAR =====
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(images.length, (index) {
                final imageUrl = images[index];

                return Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imageUrl,
                            width: 120,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 120,
                              height: 80,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Gambar ${index + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: -6,
                      right: -6,
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        color: Colors.red,
                        onPressed: () {
                          setState(() => images.removeAt(index));
                        },
                      ),
                    ),
                  ],
                );
              }),
            ),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: isLoading ? null : updateHotel,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "UPDATE PROPERTI",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI HELPERS =================
  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 12, top: 20),
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );

  Widget _input(TextEditingController c, String label, {int maxLines = 1}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: c,
          maxLines: maxLines,
          validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      );

  Widget _number(TextEditingController c, String label) => _input(c, label);

  Widget _rating() => _input(ratingController, "Rating (0 - 5)");

  Widget _dropdown() => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DropdownButtonFormField(
          initialValue: selectedType,
          decoration: const InputDecoration(labelText: "Tipe Properti"),
          items: propertyTypes
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => setState(() => selectedType = v!),
        ),
      );
}
