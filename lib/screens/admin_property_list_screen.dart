import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'edit_hotel_screen.dart';

class AdminHotelListScreen extends StatelessWidget {
  const AdminHotelListScreen({Key? key}) : super(key: key);

  // Toggle active/inactive
  Future<void> toggleActive(String id, bool current) async {
    await FirebaseFirestore.instance
        .collection('properties')
        .doc(id)
        .update({'isActive': !current});
  }

  // Hapus hotel
  Future<void> deleteHotel(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Hotel"),
        content: const Text("Yakin ingin menghapus hotel ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('properties').doc(id).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Hotel"),
        centerTitle: true,
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
            return const Center(child: Text("Belum ada hotel"));
          }

          final hotels = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: hotels.length,
            itemBuilder: (context, index) {
              final doc = hotels[index];
              final data = doc.data() as Map<String, dynamic>;

              final List images = data['images'] ?? [];
              final String imageUrl =
                  images.isNotEmpty ? images.first : 'https://via.placeholder.com/300';

              final bool isActive = data['isActive'] ?? false;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // IMAGE
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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

                    // CONTENT
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['name'] ?? '-',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data['city'] ?? '',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Rp ${data['pricePerNight']}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    isActive ? Icons.check_circle : Icons.cancel,
                                    color: isActive ? Colors.green : Colors.red,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isActive ? "Aktif" : "Nonaktif",
                                    style: TextStyle(
                                      color: isActive ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const Divider(height: 24),

                          // ================= ACTIONS =================
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Toggle Active
                              TextButton.icon(
                                onPressed: () => toggleActive(doc.id, isActive),
                                icon: Icon(
                                  isActive ? Icons.visibility_off : Icons.visibility,
                                ),
                                label: Text(isActive ? "Nonaktifkan" : "Aktifkan"),
                              ),

                              // Edit + Delete
                              Row(
                                children: [
                                  TextButton.icon(
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
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    label: const Text(
                                      "Edit",
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: () => deleteHotel(context, doc.id),
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    label: const Text(
                                      "Hapus",
                                      style: TextStyle(color: Colors.red),
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
