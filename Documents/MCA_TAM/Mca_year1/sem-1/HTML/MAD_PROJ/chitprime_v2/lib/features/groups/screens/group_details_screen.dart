import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../providers/groups_provider.dart';
import '../../contributions/providers/payment_provider.dart';
import '../../auction/providers/auction_provider.dart';
import '../../auth/providers/auth_provider.dart';

class GroupDetailsScreen extends ConsumerStatefulWidget {
  final String groupId;
  const GroupDetailsScreen({super.key, required this.groupId});
  @override
  ConsumerState<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends ConsumerState<GroupDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final group = ref.watch(groupProvider(widget.groupId)).valueOrNull;
    if (group == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => context.pop()),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration:
                    const BoxDecoration(gradient: AppColors.primaryGradient),
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(children: [
                        Expanded(
                            child: Text(group.groupName,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white))),
                        StatusBadge(
                            label: group.status.toUpperCase(),
                            color: AppColors.success),
                      ]),
                      const SizedBox(height: 6),
                      Text(
                          '${group.currentMembers}/${group.totalMembers} Members • Cycle ${group.currentCycle}/${group.cycleDuration}',
                          style: const TextStyle(
                              fontSize: 13, color: Colors.white70)),
                      const SizedBox(height: 8),
                      ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                              value: group.progressPercent,
                              backgroundColor: Colors.white24,
                              color: AppColors.accent,
                              minHeight: 6)),
                    ]),
              ),
            ),
            bottom: TabBar(
                controller: _tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                indicatorColor: AppColors.accent,
                tabs: const [
                  Tab(text: 'Members'),
                  Tab(text: 'Payments'),
                  Tab(text: 'Auctions'),
                  Tab(text: 'Payouts')
                ]),
          ),
        ],
        body: TabBarView(controller: _tab, children: [
          _MembersTab(groupId: widget.groupId),
          _PaymentsTab(groupId: widget.groupId, group: group),
          _AuctionsTab(groupId: widget.groupId),
          _PayoutsTab(groupId: widget.groupId),
        ]),
      ),
    );
  }
}

class _MembersTab extends ConsumerWidget {
  final String groupId;
  const _MembersTab({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(groupMembersProvider(groupId)).valueOrNull ?? [];
    final user = ref.watch(currentUserProvider).valueOrNull;
    final isForeman = user?.isForeman ?? false;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: members.length,
      itemBuilder: (_, i) {
        final m = members[i];
        final statusColor = m.paymentStatusThisMonth == 'paid'
            ? AppColors.success
            : m.paymentStatusThisMonth == 'overdue'
                ? AppColors.error
                : AppColors.warning;
        return AppCard(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(AppUtils.getInitials(m.name),
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14))),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(children: [
                    Text(m.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.textPrimary)),
                    if (m.role == 'foreman') ...[
                      const SizedBox(width: 6),
                      StatusBadge(label: 'Foreman', color: AppColors.primary)
                    ],
                  ]),
                  Text(
                      'Score: ${m.creditScore} • Joined ${AppUtils.formatDate(m.joinedAt)}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              StatusBadge(
                  label: m.paymentStatusThisMonth.toUpperCase(),
                  color: statusColor),
              if (isForeman && m.role != 'foreman') ...[
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () async {
                    await ref
                        .read(groupsNotifierProvider.notifier)
                        .removeMember(groupId, m.uid);
                    if (context.mounted)
                      showSnack(context, '${m.name} removed from group');
                  },
                  child: const Text('Remove',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.error,
                          fontWeight: FontWeight.w500)),
                ),
              ],
            ]),
          ]),
        );
      },
    );
  }
}

class _PaymentsTab extends ConsumerWidget {
  final String groupId;
  final dynamic group;
  const _PaymentsTab({required this.groupId, required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contribs =
        ref.watch(groupContributionsProvider(groupId)).valueOrNull ?? [];
    final total = contribs
        .where((c) => c.status == 'success')
        .fold(0.0, (s, c) => s + c.amount);

    return ListView(padding: const EdgeInsets.all(16), children: [
      AppCard(
          gradient: AppColors.primaryGradient,
          child: Row(children: [
            const Icon(Icons.payments_rounded, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Total Collected',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              Text(AppUtils.formatCurrency(total),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700)),
            ]),
          ])),
      const SizedBox(height: 12),
      ElevatedButton.icon(
          onPressed: () => context.push('/payment/$groupId'),
          icon: const Icon(Icons.payment_rounded, size: 18),
          label: const Text('Pay This Month')),
      const SizedBox(height: 12),
      OutlinedButton.icon(
          onPressed: () => context.push('/repayment/$groupId'),
          icon: const Icon(Icons.attach_money_rounded, size: 18),
          label: const Text('Repay Group Loan')),
      const SizedBox(height: 16),
      ...contribs.map((c) => AppCard(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: (c.status == 'success'
                              ? AppColors.success
                              : AppColors.error)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(
                      c.status == 'success'
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      color: c.status == 'success'
                          ? AppColors.success
                          : AppColors.error,
                      size: 20)),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(c.userName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColors.textPrimary)),
                    Text(
                        'Cycle ${c.cycleNumber} • ${c.paymentDate != null ? AppUtils.formatDate(c.paymentDate!) : 'Pending'}',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                    Text('TXN: ${c.transactionId}',
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textSecondary)),
                  ])),
              Text(AppUtils.formatCurrency(c.amount),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textPrimary)),
            ]),
          )),
    ]);
  }
}

class _AuctionsTab extends ConsumerWidget {
  final String groupId;
  const _AuctionsTab({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auctions =
        ref.watch(groupAuctionsProvider(groupId)).valueOrNull ?? [];
    final user = ref.watch(currentUserProvider).valueOrNull;
    final isForeman = user?.isForeman ?? false;

    return ListView(padding: const EdgeInsets.all(16), children: [
      if (isForeman) ...[
        ElevatedButton.icon(
          onPressed: () async {
            await ref
                .read(auctionNotifierProvider.notifier)
                .openAuction(groupId);
            if (context.mounted)
              showSnack(context, 'Auction opened! All members notified. 🔨');
          },
          icon: const Icon(Icons.gavel_rounded, size: 18),
          label: const Text('Open New Auction'),
        ),
        const SizedBox(height: 16),
      ],
      ...auctions.map((a) => AppCard(
            onTap:
                a.isOpen ? () => context.push('/auction/${a.auctionId}') : null,
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: (a.isLive ? AppColors.error : AppColors.primary)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.gavel_rounded,
                      color: a.isLive ? AppColors.error : AppColors.primary,
                      size: 20)),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(
                        'Cycle ${a.cycleNumber} • ${a.auctionType.toUpperCase()}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColors.textPrimary)),
                    if (a.winnerName.isNotEmpty)
                      Text('Winner: ${a.winnerName}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary)),
                    Text(AppUtils.formatDate(a.startTime),
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                  ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                StatusBadge(
                    label: a.status.toUpperCase(),
                    color: a.isLive
                        ? AppColors.error
                        : a.status == 'closed'
                            ? AppColors.success
                            : AppColors.warning),
                if (a.winningBid > 0) ...[
                  const SizedBox(height: 4),
                  Text(AppUtils.formatCurrency(a.winningBid),
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppColors.textPrimary))
                ],
              ]),
            ]),
          )),
    ]);
  }
}

class _PayoutsTab extends ConsumerWidget {
  final String groupId;
  const _PayoutsTab({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payouts = ref.watch(groupPayoutsProvider(groupId)).valueOrNull ?? [];
    final user = ref.watch(currentUserProvider).valueOrNull;
    final isForeman = user?.isForeman ?? false;

    if (payouts.isEmpty)
      return const AppEmptyState(
          icon: Icons.payments_outlined, title: 'No payouts yet');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: payouts.length,
      itemBuilder: (_, i) {
        final p = payouts[i];
        return AppCard(
          onTap: () => context.push('/escrow/${p.payoutId}'),
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(p.winnerName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.textPrimary)),
              const Spacer(),
              StatusBadge(
                  label: p.escrowStatus.toUpperCase(),
                  color: p.escrowStatus == 'released'
                      ? AppColors.success
                      : AppColors.warning),
            ]),
            const SizedBox(height: 8),
            _row('Gross', AppUtils.formatCurrency(p.grossAmount)),
            _row('Commission (3%)',
                '- ${AppUtils.formatCurrency(p.platformCommission)}'),
            _row('GST (18%)', '- ${AppUtils.formatCurrency(p.gstAmount)}'),
            const Divider(height: 12),
            _row('Net Payout', AppUtils.formatCurrency(p.netPayout),
                bold: true),
            if (isForeman && p.escrowStatus == 'held') ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  await ref
                      .read(paymentNotifierProvider.notifier)
                      .confirmPayout(p.payoutId);
                  if (context.mounted)
                    showSnack(context,
                        'Payout confirmed! ${p.winnerName} notified. 🎉');
                },
                icon: const Icon(Icons.check_circle_rounded, size: 16),
                label: const Text('Confirm & Release Payout'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    minimumSize: const Size(double.infinity, 44)),
              ),
            ],
          ]),
        );
      },
    );
  }

  Widget _row(String l, String v, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(l,
              style: TextStyle(
                  fontSize: 13,
                  color: bold ? AppColors.textPrimary : AppColors.textSecondary,
                  fontWeight: bold ? FontWeight.w600 : FontWeight.w400)),
          Text(v,
              style: TextStyle(
                  fontSize: 13,
                  color: bold ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
        ]),
      );
}
