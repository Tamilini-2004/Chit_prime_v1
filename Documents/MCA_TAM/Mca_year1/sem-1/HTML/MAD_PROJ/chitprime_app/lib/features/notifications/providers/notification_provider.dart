import 'package:flutter/material.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repo;
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  NotificationProvider(this._repo);

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  List<NotificationModel> get paymentNotifications =>
      _notifications.where((n) => n.type == 'payment').toList();

  List<NotificationModel> get auctionNotifications =>
      _notifications.where((n) => n.type == 'auction').toList();

  Future<void> loadNotifications(String userId) async {
    _isLoading = true;
    notifyListeners();
    _notifications = await _repo.getUserNotifications(userId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(String notificationId) async {
    await _repo.markAsRead(notificationId);
    final index = _notifications
        .indexWhere((n) => n.notificationId == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  Future<void> markAllAsRead(String userId) async {
    await _repo.markAllAsRead(userId);
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }
}
