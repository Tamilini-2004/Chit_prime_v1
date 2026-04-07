import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/group_provider.dart';
import '../../../data/models/group_model.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<GroupProvider>().loadMyGroups(user.userId);
        context.read<GroupProvider>().loadDiscoverGroups();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chit Groups'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRoutes.dashboard),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Groups'),
            Tab(text: 'Discover'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_MyGroupsTab(), _DiscoverTab()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateGroupSheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Create Group',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showCreateGroupSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreateGroupSheet(),
    );
  }
}

class _MyGroupsTab extends StatelessWidget {
  const _MyGroupsTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroupProvider>();
    if (provider.isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (_, __) => const ShimmerCard(),
      );
    }
    if (provider.myGroups.isEmpty) {
      return const AppEmptyState(
        icon: Icons.group_outlined,
        title: 'No groups yet',
        subtitle: 'Join or create a chit group to get started',
        actionLabel: 'Discover Groups',
      );
    }
    return RefreshIndicator(
      onRefresh: () => provider.loadMyGroups(
          context.read<AuthProvider>().user?.userId ?? ''),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.myGroups.length,
        itemBuilder: (_, i) => _GroupCard(group: provider.myGroups[i]),
      ),
    );
  }
}

class _DiscoverTab extends StatelessWidget {
  const _DiscoverTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroupProvider>();
    if (provider.isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (_, __) => const ShimmerCard(),
      );
    }
    return RefreshIndicator(
      onRefresh: () => provider.loadDiscoverGroups(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.discoverGroups.length,
        itemBuilder: (_, i) =>
            _DiscoverGroupCard(group: provider.discoverGroups[i]),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final GroupModel group;
  const _GroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push('/groups/${group.groupId}'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.group_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.groupName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${group.currentMembers}/${group.totalMembers} Members',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: group.status.toUpperCase(),
                color: group.status == 'active'
                    ? AppColors.success
                    : AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: group.progressPercent,
              backgroundColor: AppColors.divider,
              color: AppColors.primary,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cycle ${group.currentCycle}/${group.cycleDuration}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                AppUtils.formatCurrency(group.monthlyContribution) + '/mo',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (group.nextAuctionDate != null) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.gavel_rounded,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  'Next Auction: ${AppUtils.formatDate(group.nextAuctionDate!)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DiscoverGroupCard extends StatelessWidget {
  final GroupModel group;
  const _DiscoverGroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  group.groupName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (!group.isPublic)
                const Icon(Icons.lock_rounded,
                    size: 16, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _infoChip(Icons.group_rounded,
                  '${group.currentMembers}/${group.totalMembers}'),
              const SizedBox(width: 8),
              _infoChip(Icons.currency_rupee_rounded,
                  '${AppUtils.formatCurrency(group.monthlyContribution)}/mo'),
              const SizedBox(width: 8),
              _infoChip(Icons.star_rounded,
                  'Min ${group.minCreditScore}'),
            ],
          ),
          if (group.description != null) ...[
            const SizedBox(height: 8),
            Text(
              group.description!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          AppButton(
            label: group.isFull ? 'Group Full' : 'Join Group',
            onPressed: group.isFull
                ? null
                : () async {
                    final user = context.read<AuthProvider>().user;
                    if (user == null) return;
                    final groupProvider = context.read<GroupProvider>();
                    final success = await groupProvider.joinGroup(group.groupId, user.userId);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text(success ? 'Successfully joined ${group.groupName}!' : 'Failed to join group'),
                            ],
                          ),
                          backgroundColor: success ? AppColors.success : AppColors.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                  },
            color: group.isFull ? AppColors.textSecondary : AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateGroupSheet extends StatefulWidget {
  const _CreateGroupSheet();

  @override
  State<_CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends State<_CreateGroupSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  double _contribution = 5000;
  int _members = 20;
  int _duration = 12;
  int _minScore = 500;
  bool _isPublic = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text(
                    'Create New Group',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(hintText: 'Group Name'),
                validator: (v) =>
                    (v?.trim().isEmpty ?? true) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _sliderField('Monthly Contribution',
                  '₹${_contribution.toInt()}', _contribution, 1000, 50000,
                  (v) => setState(() => _contribution = v)),
              _sliderField('Total Members', '$_members', _members.toDouble(),
                  10, 50, (v) => setState(() => _members = v.toInt())),
              _sliderField('Duration (months)', '$_duration months',
                  _duration.toDouble(), 6, 36,
                  (v) => setState(() => _duration = v.toInt())),
              _sliderField('Min Credit Score', '$_minScore',
                  _minScore.toDouble(), 0, 1000,
                  (v) => setState(() => _minScore = v.toInt())),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Public Group',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary)),
                  const Spacer(),
                  Switch(
                    value: _isPublic,
                    onChanged: (v) => setState(() => _isPublic = v),
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Consumer<GroupProvider>(
                builder: (_, provider, __) => GradientButton(
                  label: 'Create Group',
                  isLoading: provider.isLoading,
                  onPressed: _submit,
                  icon: Icons.add_circle_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sliderField(String label, String value, double current, double min,
      double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary)),
            Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
          ],
        ),
        Slider(
          value: current,
          min: min,
          max: max,
          activeColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = context.read<AuthProvider>().user;
    final success = await context.read<GroupProvider>().createGroup({
      'groupName': _nameCtrl.text.trim(),
      'adminUserId': user?.userId ?? '',
      'totalMembers': _members,
      'monthlyContribution': _contribution,
      'cycleDuration': _duration,
      'startDate': DateTime.now(),
      'minCreditScore': _minScore,
      'description': _descCtrl.text.trim(),
      'isPublic': _isPublic,
    });
    if (success && mounted) Navigator.pop(context);
  }
}
