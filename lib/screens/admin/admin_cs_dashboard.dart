import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luxora_app/config/app_theme.dart';
import 'package:luxora_app/screens/admin/admin_chat_detail_screen.dart';
import 'package:luxora_app/screens/admin/email_change_request_screen.dart';
import 'package:intl/intl.dart';

class AdminCSDashboardScreen extends StatelessWidget {
  const AdminCSDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CS Dashboard'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD6C7B2), Color(0xFFBFAF9B)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Customer Service',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kelola chat dan permintaan perubahan email',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Statistics Cards
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.chat_bubble_outline,
                    title: 'Active Chats',
                    stream: FirebaseFirestore.instance
                        .collection('chats')
                        .where('isAdmin', isEqualTo: false)
                        .where('isRead', isEqualTo: false)
                        .snapshots(),
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.email_outlined,
                    title: 'Email Requests',
                    stream: FirebaseFirestore.instance
                        .collection('email_change_requests')
                        .where('status', isEqualTo: 'pending')
                        .snapshots(),
                    color: Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recent Chats Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pesan Terbaru',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to all chats
                  },
                  child: const Text('Lihat Semua'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            StreamBuilder<QuerySnapshot>(
              // PERBAIKAN: Hapus orderBy untuk menghindari composite index
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .limit(50)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('Belum ada chat'),
                    ),
                  );
                }

                // PERBAIKAN: Sort manual berdasarkan timestamp
                final List<QueryDocumentSnapshot> allDocs = List.from(snapshot.data!.docs);
                
                allDocs.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  
                  final dynamic aTime = aData['timestamp'];
                  final dynamic bTime = bData['timestamp'];
                  
                  if (aTime == null && bTime == null) return 0;
                  if (aTime == null) return 1;
                  if (bTime == null) return -1;
                  
                  try {
                    final aMillis = aTime is int ? aTime : (aTime as Timestamp).millisecondsSinceEpoch;
                    final bMillis = bTime is int ? bTime : (bTime as Timestamp).millisecondsSinceEpoch;
                    return bMillis.compareTo(aMillis); // Descending (newest first)
                  } catch (e) {
                    return 0;
                  }
                });

                // Group by userId
                Map<String, List<QueryDocumentSnapshot>> groupedChats = {};
                for (var doc in allDocs) {
                  final data = doc.data() as Map<String, dynamic>;
                  String userId = data['userId'] ?? '';
                  
                  if (userId.isEmpty) continue;
                  
                  if (!groupedChats.containsKey(userId)) {
                    groupedChats[userId] = [];
                  }
                  groupedChats[userId]!.add(doc);
                }

                if (groupedChats.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('Belum ada chat'),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: groupedChats.length,
                  itemBuilder: (context, index) {
                    String userId = groupedChats.keys.elementAt(index);
                    List<QueryDocumentSnapshot> userChats = groupedChats[userId]!;
                    QueryDocumentSnapshot lastMessage = userChats.first;
                    final lastMsgData = lastMessage.data() as Map<String, dynamic>;

                    // Count unread messages from user
                    int unreadCount = 0;
                    for (var doc in userChats) {
                      final data = doc.data() as Map<String, dynamic>;
                      if (data['isAdmin'] == false && data['isRead'] == false) {
                        unreadCount++;
                      }
                    }

                    return _ChatListItem(
                      userId: userId,
                      userName: lastMsgData['userName'] ?? 'User',
                      lastMessage: lastMsgData['message'] ?? '',
                      timestamp: lastMsgData['timestamp'],
                      unreadCount: unreadCount,
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 24),

            // Email Change Requests
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Permintaan Ubah Email',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EmailChangeRequestsScreen(),
                      ),
                    );
                  },
                  child: const Text('Lihat Semua'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            StreamBuilder<QuerySnapshot>(
              // PERBAIKAN: Hapus orderBy untuk menghindari composite index
              stream: FirebaseFirestore.instance
                  .collection('email_change_requests')
                  .where('status', isEqualTo: 'pending')
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('Tidak ada permintaan pending'),
                    ),
                  );
                }

                // PERBAIKAN: Sort manual berdasarkan requestDate
                final List<QueryDocumentSnapshot> requests = List.from(snapshot.data!.docs);
                
                requests.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  
                  final dynamic aDate = aData['requestDate'];
                  final dynamic bDate = bData['requestDate'];
                  
                  if (aDate == null && bDate == null) return 0;
                  if (aDate == null) return 1;
                  if (bDate == null) return -1;
                  
                  if (aDate is Timestamp && bDate is Timestamp) {
                    return bDate.compareTo(aDate); // Descending
                  }
                  
                  return 0;
                });

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    return _EmailRequestCard(request: request);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Stream<QuerySnapshot> stream;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.stream,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        int count = snapshot.hasData ? snapshot.data!.docs.length : 0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 12),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChatListItem extends StatelessWidget {
  final String userId;
  final String userName;
  final String lastMessage;
  final dynamic timestamp;
  final int unreadCount;

  const _ChatListItem({
    required this.userId,
    required this.userName,
    required this.lastMessage,
    this.timestamp,
    required this.unreadCount,
  });

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    
    DateTime dateTime;
    try {
      if (timestamp is Timestamp) {
        dateTime = timestamp.toDate();
      } else if (timestamp is int) {
        dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else {
        return '';
      }
    } catch (e) {
      return '';
    }
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else {
      return DateFormat('dd/MM').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor,
          child: Text(
            userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          userName,
          style: TextStyle(
            fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTimestamp(timestamp),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdminChatDetailScreen(
                userId: userId,
                userName: userName,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmailRequestCard extends StatelessWidget {
  final DocumentSnapshot request;

  const _EmailRequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final data = request.data() as Map<String, dynamic>?;
    
    if (data == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(Icons.email, color: Colors.white, size: 20),
        ),
        title: Text(data['userName'] ?? 'User'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${data['currentEmail'] ?? ''} → ${data['newEmail'] ?? ''}'),
            if (data['reason'] != null && (data['reason'] as String).isNotEmpty)
              Text(
                data['reason'],
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EmailChangeRequestsScreen(
                highlightRequestId: request.id,
              ),
            ),
          );
        },
      ),
    );
  }
}