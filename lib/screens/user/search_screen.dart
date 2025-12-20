import 'package:flutter/material.dart';
import '../../../services/property_service.dart';
import '../../../models/property_model.dart';
import '../../../config/app_theme.dart';
import 'property_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final bool showBottomNav;

  const SearchScreen({
    super.key,
    this.showBottomNav = true,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final PropertyService _propertyService = PropertyService();
  final TextEditingController _searchController = TextEditingController();
  
  List<PropertyModel> _searchResults = [];
  bool _isLoading = false;
  String _sortBy = 'Rating';
  
  String? _selectedCity;
  String? _selectedType;
  double _minPrice = 0;
  double _maxPrice = 10000000;

  @override
  void initState() {
    super.initState();
    _loadAllProperties();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllProperties() async {
    setState(() => _isLoading = true);
    
    final properties = await _propertyService.searchProperties();
    
    setState(() {
      _searchResults = properties;
      _isLoading = false;
    });
  }

  Future<void> _search() async {
    setState(() => _isLoading = true);

    final properties = await _propertyService.searchProperties(
      city: _selectedCity,
      type: _selectedType,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
    );

    // Apply sorting
    if (_sortBy == 'Harga Terendah') {
      properties.sort((a, b) => a.pricePerNight.compareTo(b.pricePerNight));
    } else if (_sortBy == 'Harga Tertinggi') {
      properties.sort((a, b) => b.pricePerNight.compareTo(a.pricePerNight));
    } else if (_sortBy == 'Rating') {
      properties.sort((a, b) => b.rating.compareTo(a.rating));
    }

    setState(() {
      _searchResults = properties;
      _isLoading = false;
    });
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 16,
              left: 16,
              right: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter Pencarian',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),

                // City Filter
                const Text(
                  'Kota',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCity,
                  decoration: const InputDecoration(
                    hintText: 'Pilih Kota',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Semua Kota')),
                    ...['Jakarta', 'Bandung', 'Bali', 'Yogyakarta', 'Surabaya', 'Lampung', 'Solo', 'Palembang']
                        .map((city) => DropdownMenuItem(
                              value: city,
                              child: Text(city),
                            )),
                  ],
                  onChanged: (value) {
                    setModalState(() => _selectedCity = value);
                  },
                ),
                const SizedBox(height: 16),

                // Type Filter
                const Text(
                  'Tipe Properti',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    hintText: 'Pilih Tipe',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Semua Tipe')),
                    ...['hotel', 'villa', 'homestay']
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type[0].toUpperCase() + type.substring(1)),
                            )),
                  ],
                  onChanged: (value) {
                    setModalState(() => _selectedType = value);
                  },
                ),
                const SizedBox(height: 16),

                // Price Range
                const Text(
                  'Rentang Harga',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                RangeSlider(
                  values: RangeValues(_minPrice, _maxPrice),
                  min: 0,
                  max: 10000000,
                  divisions: 100,
                  labels: RangeLabels(
                    'Rp ${_minPrice.toStringAsFixed(0)}',
                    'Rp ${_maxPrice.toStringAsFixed(0)}',
                  ),
                  onChanged: (values) {
                    setModalState(() {
                      _minPrice = values.start;
                      _maxPrice = values.end;
                    });
                  },
                ),
                Text(
                  'Rp ${_minPrice.toStringAsFixed(0)} - Rp ${_maxPrice.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 24),

                // Apply Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _search();
                    },
                    child: const Text('Terapkan Filter'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Akomodasi'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() => _sortBy = value);
              _search();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Rating', child: Text('Rating Tertinggi')),
              const PopupMenuItem(value: 'Harga Terendah', child: Text('Harga Terendah')),
              const PopupMenuItem(value: 'Harga Tertinggi', child: Text('Harga Tertinggi')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari berdasarkan nama...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _loadAllProperties();
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (value.isEmpty) {
                          _loadAllProperties();
                        } else {
                          _searchResults = _searchResults
                              .where((p) => p.name
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFilterDialog,
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Results Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${_searchResults.length} properti ditemukan',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Results List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada hasil',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final property = _searchResults[index];
                          return _SearchResultCard(property: property);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final PropertyModel property;

  const _SearchResultCard({required this.property});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PropertyDetailScreen(property: property),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: property.images.isNotEmpty
                    ? Image.network(
                        property.images.first,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[300],
                            child: const Icon(Icons.hotel, size: 32),
                          );
                        },
                      )
                    : Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: const Icon(Icons.hotel, size: 32),
                      ),
              ),
              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            property.city,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          property.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          ' (${property.totalReviews})',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rp ${property.pricePerNight.toStringAsFixed(0)}/malam',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}