import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/property_model.dart';
import '../../services/auth_service.dart';
import '../../services/property_service.dart';
import '../../config/app_theme.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final PropertyService _propertyService = PropertyService();

  // Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _priceController = TextEditingController();
  final _maxGuestsController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _ratingController = TextEditingController();
  final _totalReviewsController = TextEditingController();


  String _selectedType = 'hotel';
  List<String> _imageUrls = [];
  List<String> _selectedFacilities = [];

  bool _isLoading = false;

  final List<String> _propertyTypes = ['hotel', 'villa', 'homestay'];
  final List<String> _availableFacilities = [
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

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _priceController.dispose();
    _maxGuestsController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _imageUrlController.dispose();
    _ratingController.dispose();
    _totalReviewsController.dispose();

    super.dispose();
  }

  void _addImageUrl() {
    if (_imageUrlController.text.trim().isNotEmpty) {
      setState(() {
        _imageUrls.add(_imageUrlController.text.trim());
        _imageUrlController.clear();
      });
    }
  }

  void _removeImageUrl(int index) {
    setState(() {
      _imageUrls.removeAt(index);
    });
  }

  void _toggleFacility(String facility) {
    setState(() {
      if (_selectedFacilities.contains(facility)) {
        _selectedFacilities.remove(facility);
      } else {
        _selectedFacilities.add(facility);
      }
    });
  }

  Future<void> _submitProperty() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tambahkan minimal 1 gambar'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (_selectedFacilities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal 1 fasilitas'),
          backgroundColor: AppTheme.errorColor,
        ),
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

    // Generate property ID
    final propertyId = 'prop_${DateTime.now().millisecondsSinceEpoch}';

    final property = PropertyModel(
      propertyId: propertyId,
      ownerId: userId,
      name: _nameController.text.trim(),
      type: _selectedType,
      description: _descriptionController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      latitude: -6.2088, // Default Jakarta, bisa diganti dengan location picker
      longitude: 106.8456,
      pricePerNight: double.parse(_priceController.text.trim()),
      maxGuests: int.parse(_maxGuestsController.text.trim()),
      bedrooms: int.parse(_bedroomsController.text.trim()),
      bathrooms: int.parse(_bathroomsController.text.trim()),
      rating: _ratingController.text.isEmpty
            ? 0.0
            : double.parse(_ratingController.text),
      totalReviews: _totalReviewsController.text.isEmpty
            ? 0
            : int.parse(_totalReviewsController.text),
      images: _imageUrls,
      facilities: _selectedFacilities,
      isActive: true,
      createdAt: DateTime.now(),
    );

    final error = await _propertyService.createProperty(property);

    setState(() => _isLoading = false);

    if (error == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Properti berhasil ditambahkan!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context, true); // Return true to refresh list
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
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
        title: const Text('Tambah Properti'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Property Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Properti *',
                hintText: 'Contoh: Grand Hotel Jakarta',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama properti harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Property Type
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Tipe Properti *',
              ),
              items: _propertyTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type[0].toUpperCase() + type.substring(1)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedType = value!);
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi *',
                hintText: 'Deskripsikan properti Anda...',
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Deskripsi harus diisi';
                }
                if (value.length < 20) {
                  return 'Deskripsi minimal 20 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // City
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Kota *',
                hintText: 'Contoh: Jakarta',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kota harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Address
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Alamat Lengkap *',
                hintText: 'Jl. ...',
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Alamat harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Price
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Harga per Malam (Rp) *',
                hintText: '500000',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Harga harus diisi';
                }
                if (double.tryParse(value) == null) {
                  return 'Harga harus berupa angka';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Max Guests
            TextFormField(
              controller: _maxGuestsController,
              decoration: const InputDecoration(
                labelText: 'Maksimal Tamu *',
                hintText: '4',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Jumlah tamu harus diisi';
                }
                if (int.tryParse(value) == null) {
                  return 'Harus berupa angka';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Bedrooms
            TextFormField(
              controller: _bedroomsController,
              decoration: const InputDecoration(
                labelText: 'Jumlah Kamar Tidur *',
                hintText: '2',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Jumlah kamar tidur harus diisi';
                }
                if (int.tryParse(value) == null) {
                  return 'Harus berupa angka';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Bathrooms
            TextFormField(
              controller: _bathroomsController,
              decoration: const InputDecoration(
                labelText: 'Jumlah Kamar Mandi *',
                hintText: '2',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Jumlah kamar mandi harus diisi';
                }
                if (int.tryParse(value) == null) {
                  return 'Harus berupa angka';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Rating
TextFormField(
  controller: _ratingController,
  decoration: const InputDecoration(
    labelText: 'Rating (0 - 5)',
    hintText: '4.5',
  ),
  keyboardType: TextInputType.numberWithOptions(decimal: true),
  validator: (value) {
    if (value == null || value.isEmpty) return null; // optional
    final rating = double.tryParse(value);
    if (rating == null) return 'Rating harus angka';
    if (rating < 0 || rating > 5) return 'Rating antara 0 - 5';
    return null;
  },
),
const SizedBox(height: 16),

// Total Reviews
TextFormField(
  controller: _totalReviewsController,
  decoration: const InputDecoration(
    labelText: 'Total Review',
    hintText: '120',
  ),
  keyboardType: TextInputType.number,
  validator: (value) {
    if (value == null || value.isEmpty) return null; // optional
    if (int.tryParse(value) == null) return 'Harus berupa angka';
    return null;
  },
),
const SizedBox(height: 24),


            // Images Section
            const Text(
              'Gambar Properti *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(
                      hintText: 'URL gambar (https://...)',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addImageUrl,
                  child: const Text('Tambah'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_imageUrls.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _imageUrls.asMap().entries.map((entry) {
                  return Chip(
                    label: Text('Gambar ${entry.key + 1}'),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _removeImageUrl(entry.key),
                  );
                }).toList(),
              ),
            const SizedBox(height: 24),

            // Facilities Section
            const Text(
              'Fasilitas *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableFacilities.map((facility) {
                final isSelected = _selectedFacilities.contains(facility);
                return FilterChip(
                  label: Text(facility),
                  selected: isSelected,
                  onSelected: (selected) => _toggleFacility(facility),
                  backgroundColor: Colors.grey[100],
                  selectedColor: AppTheme.primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Submit Button
            ElevatedButton(
              onPressed: _isLoading ? null : _submitProperty,
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
                  : const Text('Tambah Properti'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}