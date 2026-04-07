import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/common_widgets.dart';
import '../providers/group_provider.dart';
import '../../../data/repositories/payment_repository.dart';
import '../../../data/repositories/auction_repository.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;
  const GroupDetailScreen({super.key, required this.groupId});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupProvider>().loadGroupDetail(widget.groupId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroupProvider>();
    final group = provider.selectedGroup;

    return Scaffold(
      body: group == null
          ? const Center(child: CircularProgressIndicator())
          : NestedScrollView(
              headerSliverBuilder: (_, __) => [
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration:
                          const BoxDecoration(gradient: AppColors.primaryGradient),
                      padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  group.groupName,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              StatusBadge(
                                label: group.status.toUpperCase(),
                                color: AppColors.success,
                                textColor: AppColors.success,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${group.currentMembers}/${group.totalMembers} Members • Cycle ${group.currentCycle}/${group.cycleDuration}',
                            style: const TextStyle(
                                fontSize: 13, color: Colors.white70),
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: group.progressPercent,
                              backgroundColor: Colors.white24,
                              color: AppColors.accent,
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  bottom: TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,
                    indicatorColor: AppColors.accent,
                    tabs: const [
                      Tab(text: 'Members'),
                      Tab(text: 'Contributions'),
                      Tab(text: 'Auctions'),
                      Tab(text: 'Payouts'),
                    ],
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  _MembersTab(groupId: widget.groupId),
                  _ContributionsTab(groupId: widget.groupId),
                  _AuctionsTab(groupId: widget.groupId),
                  _PayoutsTab(groupId: widget.groupId),
                ],
              ),
            ),
    );
  }
}

class _MembersTab extends StatelessWidget {
  final String groupId;
  const _MembersTab({required this.groupId});

  @override
  Widget build(BuildContext context) {
    final members = context.watch<GroupProvider>().members;
    if (members.isEmpty) {
      return const AppEmptyState(
          icon: Icons.group_outlined, title: 'No members found');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: members.length,
      itemBuilder: (_, i) {
        final m = members[i];
        return AppCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  AppUtils.getInitials(m.userName),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          m.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (m.isAdmin) ...[
                          const SizedBox(width: 6),
                          StatusBadge(
                              label: 'Admin', color: AppColors.primary),
                        ],
                      ],
                    ),
                    Text(
                      'Score: ${m.creditScore} • Joined ${AppUtils.formatDate(m.joinDate)}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Icon(
                m.paymentStatus == 'paid'
                    ? Icons.check_circle_rounded
                    : Icons.pending_rounded,
                color: m.paymentStatus == 'paid'
                    ? AppColors.success
                    : AppColors.warning,
                size: 20,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ContributionsTab extends StatefulWidget {
  final String groupId;
  const _ContributionsTab({required this.groupId});

  @override
  State<_ContributionsTab> createState() => _ContributionsTabState();
}

class _ContributionsTabState extends State<_ContributionsTab> {
  List<dynamic> _contributions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = context.read<PaymentRepository>();
    _contributions = await repo.getGroupContributions(widget.groupId);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          gradient: AppColors.primaryGradient,
          child: Row(
            children: [
              const Icon(Icons.currency_rupee_rounded,
                  color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Contributed',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  Text(
                    AppUtils.formatCurrency(_contributions
                        .where((c) => c.status == 'success')
                        .fold(0.0, (sum, c) => sum + c.amount)),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ..._contributions.map((c) => _contributionItem(c)),
        const SizedBox(height: 16),
        AppButton(
          label: 'Pay This Month',
          onPressed: () => context.push('/payment/${widget.groupId}'),
          icon: Icons.payment_rounded,
        ),
      ],
    );
  }

  Widget _contributionItem(dynamic c) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: c.status == 'success'
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              c.status == 'success'
                  ? Icons.check_circle_rounded
                  : Icons.pending_rounded,
              color: c.status == 'success' ? AppColors.success : AppColors.warning,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cycle ${c.cycleNumber}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  c.paymentDate != null
                      ? AppUtils.formatDate(c.paymentDate!)
                      : 'Due: ${AppUtils.formatDate(c.dueDate)}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            AppUtils.formatCurrency(c.amount),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuctionsTab extends StatefulWidget {
  final String groupId;
  const _AuctionsTab({required this.groupId});

  @override
  State<_AuctionsTab> createState() => _AuctionsTabState();
}

class _AuctionsTabState extends State<_AuctionsTab> {
  List<dynamic> _auctions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = context.read<AuctionRepository>();
    _auctions = await repo.getGroupAuctions(widget.groupId);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppButton(
          label: 'View Live Auction',
          onPressed: () => context.push('/auction/${widget.groupId}'),
          icon: Icons.gavel_rounded,
        ),
        const SizedBox(height: 16),
        ..._auctions.map((a) => _auctionItem(a)),
      ],
    );
  }

  Widget _auctionItem(dynamic a) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.gavel_rounded,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cycle ${a.cycleNumber} • ${a.auctionType.toUpperCase()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (a.winnerName != null)
                  Text(
                    'Winner: ${a.winnerName}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (a.winningBid != null)
                Text(
                  AppUtils.formatCurrency(a.winningBid!),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              StatusBadge(
                label: a.status.toUpperCase(),
                color: a.status == 'live'
                    ? AppColors.error
                    : a.status == 'completed'
                        ? AppColors.success
                        : AppColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PayoutsTab extends StatefulWidget {
  final String groupId;
  const _PayoutsTab({required this.groupId});

  @override
  State<_PayoutsTab> createState() => _PayoutsTabState();
}

class _PayoutsTabState extends State<_PayoutsTab> {
  List<dynamic> _payouts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = context.read<PaymentRepository>();
    _payouts = await repo.getGroupPayouts(widget.groupId);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_payouts.isEmpty) {
      return const AppEmptyState(
          icon: Icons.payments_outlined, title: 'No payouts yet');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _payouts.length,
      itemBuilder: (_, i) {
        final p = _payouts[i];
        return AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    p.userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  StatusBadge(label: 'Cycle ${p.cycleNumber}', color: AppColors.primary),
                ],
              ),
              const SizedBox(height: 10),
              _row('Gross Amount', AppUtils.formatCurrency(p.grossAmount)),
              _row('Platform Fee (3%)', '- ${AppUtils.formatCurrency(p.platformFee)}'),
              _row('GST (18%)', '- ${AppUtils.formatCurrency(p.gstAmount)}'),
              const Divider(height: 16),
              _row('Net Payout', AppUtils.formatCurrency(p.netPayout),
                  bold: true),
              const SizedBox(height: 6),
              Text(
                'TXN: ${p.transactionId}',
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: 13,
                color: bold ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
              )),
          Text(value,
              style: TextStyle(
                fontSize: 13,
                color: bold ? AppColors.primary : AppColors.textPrimary,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              )),
        ],
      ),
    );
  }
}
