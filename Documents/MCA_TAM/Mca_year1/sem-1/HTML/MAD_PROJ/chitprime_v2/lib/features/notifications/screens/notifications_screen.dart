import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../providers/notification_provider.dart';
import '../../../data/models/notification_model.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});
  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() { super.initState(); _tab = TabController(length: 3, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final notifs = ref.watch(notificationsProvider).valueOrNull ?? [];
    final unread = notifs.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const Text('Notifications'),
          if (unread > 0) ...[
            const SizedBox(width: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(12)),
              child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
          ],
        ]),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: () => ref.read(notificationNotifierProvider.notifier).markAllAsRead(),
              child: const Text('Mark all read', style: TextStyle(color: AppColors.primary, fontSize: 13)),
            ),
        ],
        bottom: TabBar(controller: _tab, tabs: [
          Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Text('All'),
            if (unread > 0) ...[const SizedBox(width: 4), Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle), child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 10)))],
          ])),
          const Tab(text: 'Payments'),
          const Tab(text: 'Auctions'),
        ]),
      ),
      body: TabBarView(controller: _tab, children: [
        _NotifList(notifs: notifs),
        _NotifList(notifs: notifs.where((n) => n.type == 'payment').toList()),
        _NotifList(notifs: notifs.where((n) => n.type == 'auction').toList()),
      ]),
    );
  }
}

class _NotifList extends ConsumerWidget {
  final List<NotificationModel> notifs;
  const _NotifList({required this.notifs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (notifs.isEmpty) return const AppEmptyState(icon: Icons.notifications_none_rounded, title: 'No notifications', subtitle: 'You\'re all caught up!');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifs.length,
      itemBuilder: (_, i) {
        final n = notifs[i];
        final color = _color(n.type);
        return GestureDetector(
          onTap: () {
            ref.read(notificationNotifierProvider.notifier).markAsRead(n.notificationId);
            if (n.actionRoute.isNotEmpty) context.push(n.actionRoute);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: n.isRead ? AppColors.card : color.withOpacity(0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: n.isRead ? AppColors.divider : color.withOpacity(0.2)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(_icon(n.type), color: color, size: 20)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Text(n.message, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(AppUtils.timeAgo(n.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ])),
              if (!n.isRead) Container(width: 8, height: 8, margin: const EdgeInsets.only(top: 4), decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            ]),
          ),
        );
      },
    );
  }

  Color _color(String type) {
    switch (type) {
      case 'payment': return AppColors.success;
      case 'auction': return AppColors.primary;
      case 'group': return AppColors.secondary;
      case 'chat': return AppColors.accent;
      case 'system': return AppColors.warning;
      default: return AppColors.textSecondary;
    }
  }

  IconData _icon(String type) {
    switch (type) {
      case 'payment': return Icons.payment_rounded;
      case 'auction': return Icons.gavel_rounded;
      case 'group': return Icons.group_rounded;
      case 'chat': return Icons.chat_rounded;
      case 'system': return Icons.info_rounded;
      default: return Icons.notifications_rounded;
    }
  }
}
