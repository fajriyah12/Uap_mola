// lib/services/notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Send notification to user
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    required String type, // chat, email_change, booking, etc.
    Map<String, dynamic>? data,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'data': data ?? {},
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ Notification sent to user: $userId');
    } catch (e) {
      print('❌ Error sending notification: $e');
    }
  }

  /// Get user notifications
  Stream<QuerySnapshot> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('❌ Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    try {
      final unreadNotifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in unreadNotifications.docs) {
        await doc.reference.update({'isRead': true});
      }
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
    }
  }

  /// Get unread count
  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      print('❌ Error deleting notification: $e');
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications(String userId) async {
    try {
      final notifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in notifications.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('❌ Error clearing notifications: $e');
    }
  }

  // ==========================================
  // HELPER METHODS FOR SPECIFIC NOTIFICATIONS
  // ==========================================

  /// Send chat notification
  Future<void> sendChatNotification({
    required String userId,
    required String senderName,
    required String message,
  }) async {
    await sendNotification(
      userId: userId,
      title: 'Pesan Baru dari $senderName',
      message: message,
      type: 'chat',
      data: {
        'senderName': senderName,
      },
    );
  }

  /// Send email change notification
  Future<void> sendEmailChangeNotification({
    required String userId,
    required String status, // approved, rejected
    String? reason,
  }) async {
    String title = status == 'approved'
        ? 'Perubahan Email Disetujui'
        : 'Perubahan Email Ditolak';

    String message = status == 'approved'
        ? 'Permintaan perubahan email Anda telah disetujui. Silakan cek email baru Anda untuk verifikasi.'
        : 'Permintaan perubahan email Anda ditolak. ${reason ?? ''}';

    await sendNotification(
      userId: userId,
      title: title,
      message: message,
      type: 'email_change',
      data: {
        'status': status,
        'reason': reason,
      },
    );
  }

  /// Send booking notification
  Future<void> sendBookingNotification({
    required String userId,
    required String bookingId,
    required String propertyName,
    required String status,
  }) async {
    String title = 'Booking Update';
    String message = 'Status booking $propertyName: $status';

    await sendNotification(
      userId: userId,
      title: title,
      message: message,
      type: 'booking',
      data: {
        'bookingId': bookingId,
        'propertyName': propertyName,
        'status': status,
      },
    );
  }
}