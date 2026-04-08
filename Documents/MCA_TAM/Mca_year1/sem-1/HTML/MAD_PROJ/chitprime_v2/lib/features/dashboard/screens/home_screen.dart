import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../../groups/providers/groups_provider.dart';
import '../../contributions/providers/payment_provider.dart';
import '../../notifications/providers/notification_provider.dart';
import '../../auction/providers/auction_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final myGroups = ref.watch(myGroupsProvider).valueOrNull ?? [];
    final myContribs = ref.watch(myContributionsProvider).valueOrNull ?? [];
    final unread = ref.watch(authStateProvider).valueOrNull != null
        ? (ref.watch(unreadCountProvider).valueOrNull ?? 0)
        : 0;
    final activeAuctions = ref.watch(allActiveAuctionsProvider).valueOrNull ?? [];

    final totalPaid = myContribs.where((c) => c.status == 'success').fold(0.0, (s, c) => s + c.amount);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(myGroupsProvider),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context, user, unread, ref)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList(delegate: SliverChildListDelegate([
              const SizedBox(height: 16),
              _buildStats(myGroups.length, totalPaid),
              const SizedBox(height: 20),
              _buildQuickActions(context),
              const SizedBox(height: 20),
              if (activeAuctions.isNotEmpty) ...[
                _buildLiveAuction(context, activeAuctions.first),
                const SizedBox(height: 20),
              ],
              _buildUpcomingPayments(context, myGroups),
              const SizedBox(height: 20),
              _buildRecentActivity(context, ref),
            ])),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user, int unread, WidgetRef ref) {
    final score = user?.creditScore ?? 650;
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Welcome back,', style: TextStyle(fontSize: 13, color: Colors.white70)),
            Text(user?.name ?? 'Loading...', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
          ])),
          GestureDetector(
            onTap: () => context.push('/notifications'),
            child: Stack(children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle), child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22)),
              if (unread > 0) Positioned(right: 0, top: 0, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle), child: Text('$unread', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)))),
            ]),
          ),
        ]),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => context.push('/credit-score'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.2))),
            child: Row(children: [
              Container(width: 56, height: 56, decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.2), shape: BoxShape.circle, border: Border.all(color: AppColors.accent, width: 2)), child: Center(child: Text('$score', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)))),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('AI Credit Score', style: TextStyle(fontSize: 13, color: Colors.white70)),
                Row(children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.success.withOpacity(0.2), borderRadius: BorderRadius.circular(20)), child: Text(AppUtils.creditRating(score), style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600))),
                  const SizedBox(width: 8),
                  const Text('out of 1000', style: TextStyle(fontSize: 12, color: Colors.white60)),
                ]),
              ])),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white60, size: 14),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildStats(int groups, double paid) {
    return Row(children: [
      Expanded(child: StatCard(label: 'Active Groups', value: '$groups', icon: Icons.group_rounded, iconColor: AppColors.primary, iconBg: AppColors.primary.withOpacity(0.1))),
      const SizedBox(width: 10),
      Expanded(child: StatCard(label: 'Total Contributed', value: AppUtils.formatCurrency(paid), icon: Icons.currency_rupee_rounded, iconColor: AppColors.secondary, iconBg: AppColors.secondary.withOpacity(0.1))),
    ]);
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionHeader(title: 'Quick Actions'),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _actionBtn(context, 'Discover Groups', Icons.group_add_rounded, AppColors.primary, () => context.push('/groups'))),
        const SizedBox(width: 12),
        Expanded(child: _actionBtn(context, 'My Groups', Icons.groups_rounded, AppColors.secondary, () => context.push('/groups'))),
      ]),
    ]);
  }

  Widget _actionBtn(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.3))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 20), const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14)),
        ]),
      ),
    );
  }

  Widget _buildLiveAuction(BuildContext context, dynamic auction) {
    return AppCard(
      gradient: AppColors.cardGradient,
      onTap: () => context.push('/auction/${auction.auctionId}'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Live Auction', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          const Spacer(),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(20)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.circle, size: 8, color: Colors.white), SizedBox(width: 4), Text('LIVE', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700))])),
        ]),
        const SizedBox(height: 10),
        Text(auction.groupName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        Text('Fund: ${AppUtils.formatCurrency(auction.totalFund)}', style: const TextStyle(fontSize: 13, color: Colors.white70)),
        const SizedBox(height: 14),
        Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: const Center(child: Text('Place Bid →', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)))),
      ]),
    );
  }

  Widget _buildUpcomingPayments(BuildContext context, List groups) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(title: 'Upcoming Payments', action: 'View All', onAction: () => context.push('/groups')),
      const SizedBox(height: 12),
      if (groups.isEmpty)
        const AppEmptyState(icon: Icons.check_circle_outline_rounded, title: 'All payments up to date!')
      else
        ...groups.take(3).map((g) => AppCard(
          onTap: () => context.push('/payment/${g.groupId}'),
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.calendar_today_rounded, color: AppColors.warning, size: 20)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(g.groupName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
              Text('Cycle ${g.currentCycle}/${g.cycleDuration}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(AppUtils.formatCurrency(g.monthlyContribution), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
              StatusBadge(label: 'Due', color: AppColors.warning),
            ]),
          ]),
        )),
    ]);
  }

  Widget _buildRecentActivity(BuildContext context, WidgetRef ref) {
    final notifs = ref.watch(notificationsProvider).valueOrNull ?? [];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(title: 'Recent Activity', action: 'View All', onAction: () => context.push('/notifications')),
      const SizedBox(height: 12),
      if (notifs.isEmpty)
        const AppEmptyState(icon: Icons.notifications_none_rounded, title: 'No recent activity')
      else
        ...notifs.take(4).map((n) => AppCard(
          onTap: () { ref.read(notificationNotifierProvider.notifier).markAsRead(n.notificationId); if (n.actionRoute.isNotEmpty) context.push(n.actionRoute); },
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: _notifColor(n.type).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(_notifIcon(n.type), color: _notifColor(n.type), size: 18)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
              Text(n.message, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
            ])),
            Text(AppUtils.timeAgo(n.createdAt), style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ]),
        )),
    ]);
  }

  Color _notifColor(String type) {
    switch (type) {
      case 'payment': return AppColors.success;
      case 'auction': return AppColors.primary;
      case 'group': return AppColors.secondary;
      case 'chat': return AppColors.accent;
      default: return AppColors.textSecondary;
    }
  }

  IconData _notifIcon(String type) {
    switch (type) {
      case 'payment': return Icons.payment_rounded;
      case 'auction': return Icons.gavel_rounded;
      case 'group': return Icons.group_rounded;
      case 'chat': return Icons.chat_rounded;
      default: return Icons.notifications_rounded;
    }
  }
}
