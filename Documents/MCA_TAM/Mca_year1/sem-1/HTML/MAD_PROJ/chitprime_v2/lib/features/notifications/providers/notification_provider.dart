import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/services/firebase_service.dart';
import '../../auth/providers/auth_provider.dart';

// Notifications — real-time
final notificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value([]);
  return FirebaseService.notificationsStream(uid);
});

// Unread count (local from notifications list)
final notifUnreadCountProvider = Provider<int>((ref) {
  final notifs = ref.watch(notificationsProvider).valueOrNull ?? [];
  return notifs.where((n) => !n.isRead).length;
});

// Messages — real-time
final messagesProvider =
    StreamProvider.family<List<MessageModel>, String>(
        (ref, conversationId) =>
            FirebaseService.messagesStream(conversationId));

final notificationNotifierProvider =
    AsyncNotifierProvider<NotificationNotifier, void>(NotificationNotifier.new);

class NotificationNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> markAsRead(String notifId) =>
      FirebaseService.markNotificationRead(notifId);

  Future<void> markAllAsRead() async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid != null) await FirebaseService.markAllNotificationsRead(uid);
  }

  Future<void> sendNotification({
    required String toUid,
    required String title,
    required String message,
    String type = 'system',
    String actionRoute = '',
  }) =>
      FirebaseService.sendNotification(
        toUid: toUid, title: title, message: message,
        type: type, actionRoute: actionRoute,
      );
}

final chatNotifierProvider =
    AsyncNotifierProvider<ChatNotifier, void>(ChatNotifier.new);

class ChatNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> sendMessage({
    required String conversationId,
    required String toUid,
    required String message,
  }) =>
      FirebaseService.sendMessage(
        conversationId: conversationId, toUid: toUid, message: message,
      );
}
