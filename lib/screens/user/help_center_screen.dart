// lib/screens/user/help_center_screen.dart
import 'package:flutter/material.dart';
import 'package:luxora_app/config/app_theme.dart';
import 'package:luxora_app/screens/user/live_chat_screen.dart';
import 'package:provider/provider.dart';
import 'package:luxora_app/services/auth_service.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  final List<String> _categories = [
    'Semua',
    'Akun',
    'Pemesanan',
    'Pembayaran',
    'Lainnya',
  ];

  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'Bagaimana cara mendaftar akun?',
      answer:
          'Klik tombol "Sign Up" pada halaman login, lalu isi formulir pendaftaran dengan lengkap. Setelah itu, verifikasi email Anda melalui link yang dikirimkan.',
      category: 'Akun',
    ),
    FAQItem(
      question: 'Bagaimana cara reset password?',
      answer:
          'Klik "Lupa Password" pada halaman login, masukkan email Anda, dan kami akan mengirimkan link reset password ke email tersebut.',
      category: 'Akun',
    ),
    FAQItem(
      question: 'Bagaimana cara mengubah email?',
      answer:
          'Buka menu Profile > Edit Profile > Ubah Email. Permintaan perubahan email harus dikonfirmasi oleh Customer Service kami untuk keamanan akun Anda.',
      category: 'Akun',
    ),
    FAQItem(
      question: 'Bagaimana cara melakukan pemesanan?',
      answer:
          'Pilih properti yang Anda inginkan, pilih tanggal check-in dan check-out, masukkan jumlah tamu, lalu klik "Pesan Sekarang". Isi data tamu dan pilih metode pembayaran.',
      category: 'Pemesanan',
    ),
    FAQItem(
      question: 'Apakah saya bisa membatalkan pemesanan?',
      answer:
          'Ya, Anda dapat membatalkan pemesanan melalui halaman "Booking Saya". Kebijakan pembatalan bergantung pada properti yang Anda pesan.',
      category: 'Pemesanan',
    ),
    FAQItem(
      question: 'Berapa lama proses konfirmasi pemesanan?',
      answer:
          'Setelah pembayaran berhasil, pemesanan Anda akan dikonfirmasi secara otomatis. Anda akan menerima notifikasi konfirmasi melalui email.',
      category: 'Pemesanan',
    ),
    FAQItem(
      question: 'Metode pembayaran apa saja yang tersedia?',
      answer:
          'Kami menerima pembayaran melalui Transfer Bank (BRI, BCA, Mandiri) dan E-Wallet (GoPay, OVO, DANA).',
      category: 'Pembayaran',
    ),
    FAQItem(
      question: 'Apakah pembayaran saya aman?',
      answer:
          'Ya, semua transaksi pembayaran menggunakan sistem yang terenkripsi dan aman. Data kartu kredit/debit Anda tidak disimpan di server kami.',
      category: 'Pembayaran',
    ),
    FAQItem(
      question: 'Bagaimana jika pembayaran saya gagal?',
      answer:
          'Jika pembayaran gagal, Anda dapat mencoba lagi atau menghubungi Customer Service kami untuk bantuan lebih lanjut.',
      category: 'Pembayaran',
    ),
    FAQItem(
      question: 'Apakah ada biaya tambahan?',
      answer:
          'Harga yang ditampilkan sudah termasuk semua biaya. Tidak ada biaya tersembunyi atau biaya tambahan.',
      category: 'Lainnya',
    ),
    FAQItem(
      question: 'Bagaimana cara menghubungi Customer Service?',
      answer:
          'Anda dapat menghubungi kami melalui Live Chat (tersedia 24/7), email di cs@luxora.com, atau WhatsApp di +62 812-3456-7890.',
      category: 'Lainnya',
    ),
  ];

  List<FAQItem> get _filteredFAQs {
    return _faqItems.where((faq) {
      final matchesCategory =
          _selectedCategory == 'Semua' || faq.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          faq.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          faq.answer.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pusat Bantuan'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari pertanyaan...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Category Chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: Colors.grey[100],
                    selectedColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Live Chat Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD6C7B2), Color(0xFFBFAF9B)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.headset_mic,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Butuh bantuan langsung?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Chat dengan CS kami sekarang',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final authService = Provider.of<AuthService>(
                        context,
                        listen: false,
                      );
                      final userId = authService.currentUser?.uid;
                      final userName =
                          authService.currentUser?.displayName ?? 'User';

                      if (userId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LiveChatScreen(
                              userId: userId,
                              userName: userName,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Silakan login terlebih dahulu'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Chat',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // FAQ List
          Expanded(
            child: _filteredFAQs.isEmpty
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
                          'Tidak ada hasil ditemukan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredFAQs.length,
                    itemBuilder: (context, index) {
                      final faq = _filteredFAQs[index];
                      return _FAQCard(faq: faq);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FAQCard extends StatefulWidget {
  final FAQItem faq;

  const _FAQCard({required this.faq});

  @override
  State<_FAQCard> createState() => _FAQCardState();
}

class _FAQCardState extends State<_FAQCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.faq.category,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.faq.question,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 12),
                Text(
                  widget.faq.answer,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;
  final String category;

  FAQItem({
    required this.question,
    required this.answer,
    required this.category,
  });
}