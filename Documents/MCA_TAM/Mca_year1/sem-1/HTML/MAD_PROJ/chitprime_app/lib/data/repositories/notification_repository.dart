import '../models/notification_model.dart';

class NotificationRepository {
  final List<NotificationModel> _notifications = [
    NotificationModel(
      notificationId: 'notif_001',
      userId: 'user_001',
      type: 'payment',
      title: 'Payment Reminder',
      message: 'Your contribution of ₹3,000 for Small Business Fund is due in 3 days.',
      isRead: false,
      actionUrl: '/payment/grp_002',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationModel(
      notificationId: 'notif_002',
      userId: 'user_001',
      type: 'auction',
      title: 'Auction Started!',
      message: 'Cycle 9 auction for Retailers Gold Circle is now live. Place your bid!',
      isRead: false,
      actionUrl: '/auction/grp_001',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    NotificationModel(
      notificationId: 'notif_003',
      userId: 'user_001',
      type: 'payment',
      title: 'Payment Confirmed',
      message: 'Your payment of ₹5,000 for Retailers Gold Circle (Cycle 8) was successful.',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    NotificationModel(
      notificationId: 'notif_004',
      userId: 'user_001',
      type: 'credit_score',
      title: 'Credit Score Updated',
      message: 'Your AI credit score has improved by 15 points to 820. Keep it up!',
      isRead: true,
      actionUrl: '/credit-score',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    NotificationModel(
      notificationId: 'notif_005',
      userId: 'user_001',
      type: 'auction',
      title: 'Auction Winner Announced',
      message: 'Mohan Lal won the Cycle 8 auction for Retailers Gold Circle with a bid of ₹95,000.',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    NotificationModel(
      notificationId: 'notif_006',
      userId: 'user_001',
      type: 'group',
      title: 'New Member Joined',
      message: 'Kavitha Reddy has joined Retailers Gold Circle.',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _notifications.where((n) => n.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> markAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index =
        _notifications.indexWhere((n) => n.notificationId == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  Future<void> markAllAsRead(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].userId == userId) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
  }

  int getUnreadCount(String userId) {
    return _notifications
        .where((n) => n.userId == userId && !n.isRead)
        .length;
  }
}
