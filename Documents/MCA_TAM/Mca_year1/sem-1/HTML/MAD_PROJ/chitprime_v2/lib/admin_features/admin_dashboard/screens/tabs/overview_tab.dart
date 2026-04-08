import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../data/models/notification_model.dart';
import '../../../../features/groups/providers/groups_provider.dart';
import '../../../../features/contributions/providers/payment_provider.dart';
import '../../../../features/auction/providers/auction_provider.dart';

// Admin-wide providers
final allUsersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) {
            final data = Map<String, dynamic>.from(d.data());
            data['uid'] = d.id;
            return data;
          }).toList());
});

final allFraudAlertsProvider = StreamProvider<List<FraudAlertModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('fraud_alerts')
      .orderBy('detectedAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(FraudAlertModel.fromDoc).toList());
});

class OverviewTab extends ConsumerWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(allUsersProvider).valueOrNull ?? [];
    final groups = ref.watch(allGroupsProvider).valueOrNull ?? [];
    final contribs = ref.watch(allContributionsProvider).valueOrNull ?? [];
    final auctions = ref.watch(allActiveAuctionsProvider).valueOrNull ?? [];
    final fraud = ref.watch(allFraudAlertsProvider).valueOrNull ?? [];
    final openFraud = fraud.where((f) => f.status == 'open').length;
    final revenue = contribs.where((c) => c.status == 'success').fold(0.0, (s, c) => s + c.amount * 0.03);

    return RefreshIndicator(
      onRefresh: () async { ref.invalidate(allUsersProvider); ref.invalidate(allGroupsProvider); },
      child: ListView(padding: const EdgeInsets.all(16), children: [
        // Stats grid
        GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5,
          children: [
            _statCard('Total Users', '${users.length}', Icons.people_rounded, AppColors.primary, '+12%'),
            _statCard('Active Groups', '${groups.where((g) => g.isActive).length}', Icons.group_rounded, AppColors.secondary, '+8%'),
            _statCard('Platform Revenue', AppUtils.formatCurrency(revenue), Icons.currency_rupee_rounded, AppColors.success, '+15%'),
            _statCard('Live Auctions', '${auctions.length}', Icons.gavel_rounded, AppColors.accent, 'Active'),
            _statCard('Transactions', '${contribs.length}', Icons.receipt_long_rounded, AppColors.primary, 'All time'),
            _statCard('Fraud Alerts', '$openFraud', Icons.warning_rounded, openFraud > 0 ? AppColors.error : AppColors.success, openFraud > 0 ? 'Action needed' : 'All clear'),
          ],
        ),
        const SizedBox(height: 20),

        // Recent activity
        const SectionHeader(title: 'Live Activity Feed'),
        const SizedBox(height: 12),
        _buildActivityFeed(ref),
        const SizedBox(height: 20),

        // Top groups
        const SectionHeader(title: 'Top Groups by Fund'),
        const SizedBox(height: 12),
        ...groups.take(5).map<Widget>((g) => AppCard(
          onTap: () {},
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.group_rounded, color: Colors.white, size: 18)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(g.groupName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
              Text('${g.currentMembers}/${g.totalMembers} members', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ])),
            Text(AppUtils.formatCurrency(g.totalFund), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary)),
          ]),
        )),
      ]),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color, String trend) {
    return AppCard(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(children: [
        Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 18)),
        const Spacer(),
        Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
          child: Text(trend, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color))),
      ]),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ]),
    ]));
  }

  Widget _buildActivityFeed(WidgetRef ref) {
    final contribs = ref.watch(allContributionsProvider).valueOrNull ?? [];
    if (contribs.isEmpty) return const AppEmptyState(icon: Icons.timeline_rounded, title: 'No recent activity');
    return Column(children: contribs.take(5).map((c) => AppCard(padding: const EdgeInsets.all(12), child: Row(children: [
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.payments_rounded, color: AppColors.success, size: 18)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${c.userName} paid ${AppUtils.formatCurrency(c.amount)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
        Text(c.groupName, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ])),
      Text(c.paymentDate != null ? AppUtils.timeAgo(c.paymentDate!) : 'Pending', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
    ]))).toList());
  }
}
