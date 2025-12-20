import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'edit_hotel_screen.dart';

class AdminHotelListScreen extends StatelessWidget {
  const AdminHotelListScreen({super.key});

  Future<void> toggleActive(String id, bool current) async {
    await FirebaseFirestore.instance
        .collection('properties')
        .doc(id)
        .update({'isActive': !current});
  }

  Future<void> deleteHotel(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Hapus Properti"),
        content: const Text("Yakin ingin menghapus properti ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('properties')
          .doc(id)
          .delete();
    }
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
          "Data Properti",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // ✅ DIPINDAHKAN KE TextStyle
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryBrown,
        elevation: 4,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('properties')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada properti",
                style: TextStyle(color: Colors.brown),
              ),
            );
          }

          final hotels = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: hotels.length,
            itemBuilder: (context, index) {
              final doc = hotels[index];
              final data = doc.data() as Map<String, dynamic>;

              final List images = data['images'] ?? [];
              final String imageUrl = images.isNotEmpty
                  ? images.first
                  : 'https://via.placeholder.com/300';

              final bool isActive = data['isActive'] ?? false;

              return Container(
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.15),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ================= IMAGE =================
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: Image.network(
                        imageUrl,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 180,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 60),
                        ),
                      ),
                    ),

                    // ================= CONTENT =================
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // HEADER
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  data['name'] ?? '-',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: primaryBrown,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _StatusBadge(isActive: isActive),
                            ],
                          ),

                          const SizedBox(height: 6),
                          Text(
                            data['city'] ?? '',
                            style: const TextStyle(color: Colors.grey),
                          ),

                          const SizedBox(height: 12),

                          // PRICE
                          Row(
                            children: [
                              const Icon(
                                Icons.attach_money,
                                color: primaryBrown,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Rp ${data['pricePerNight']}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: primaryBrown,
                                ),
                              ),
                            ],
                          ),

                          const Divider(height: 28),

                          // ================= ACTION =================
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton.icon(
                                onPressed: () =>
                                    toggleActive(doc.id, isActive),
                                icon: Icon(
                                  isActive
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: primaryBrown,
                                ),
                                label: Text(
                                  isActive ? "Nonaktifkan" : "Aktifkan",
                                  style:
                                      const TextStyle(color: primaryBrown),
                                ),
                              ),

                              Row(
                                children: [
                                  IconButton(
                                    tooltip: "Edit",
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => EditHotelScreen(
                                            hotelId: doc.id,
                                            hotelData: data,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: "Hapus",
                                    onPressed: () =>
                                        deleteHotel(context, doc.id),
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ================= STATUS BADGE =================
class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final Color color = isActive ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? "AKTIF" : "NONAKTIF",
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
