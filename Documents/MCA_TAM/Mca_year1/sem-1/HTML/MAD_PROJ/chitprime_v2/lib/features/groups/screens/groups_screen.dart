import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../providers/groups_provider.dart';
import '../../../data/models/group_model.dart';

class GroupsScreen extends ConsumerStatefulWidget {
  const GroupsScreen({super.key});
  @override
  ConsumerState<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends ConsumerState<GroupsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chit Groups'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [Tab(text: 'My Groups'), Tab(text: 'Discover')],
        ),
      ),
      // NO FloatingActionButton — users cannot create groups
      body: TabBarView(
        controller: _tab,
        children: const [_MyGroupsTab(), _DiscoverTab()],
      ),
    );
  }
}

class _MyGroupsTab extends ConsumerWidget {
  const _MyGroupsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(myGroupsProvider);
    return groupsAsync.when(
      loading: () => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (_, __) => const ShimmerCard(),
      ),
      error: (e, _) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          const Text('Failed to load groups', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: () => ref.invalidate(myGroupsProvider), child: const Text('Retry')),
        ]),
      ),
      data: (groups) {
        if (groups.isEmpty) {
          return const AppEmptyState(
            icon: Icons.group_outlined,
            title: 'No groups yet',
            subtitle: 'Go to Discover tab to join a group created by admin',
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(myGroupsProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groups.length,
            itemBuilder: (_, i) => _GroupCard(group: groups[i]),
          ),
        );
      },
    );
  }
}

class _DiscoverTab extends ConsumerWidget {
  const _DiscoverTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(allPublicGroupsProvider);
    final myGroups = ref.watch(myGroupsProvider).valueOrNull ?? [];
    final myIds = myGroups.map((g) => g.groupId).toSet();

    return allAsync.when(
      loading: () => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (_, __) => const ShimmerCard(),
      ),
      error: (e, _) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          const Text('Failed to load groups'),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: () => ref.invalidate(allPublicGroupsProvider), child: const Text('Retry')),
        ]),
      ),
      data: (all) {
        final discover = all.where((g) => !myIds.contains(g.groupId)).toList();
        if (discover.isEmpty) {
          return const AppEmptyState(
            icon: Icons.search_rounded,
            title: 'No groups available',
            subtitle: 'Admin will create groups for you to join. Check back soon!',
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(allPublicGroupsProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: discover.length,
            itemBuilder: (_, i) => _DiscoverCard(group: discover[i]),
          ),
        );
      },
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.group_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(group.groupName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textPrimary)),
            Text('${group.currentMembers}/${group.totalMembers} Members • ${group.fundType.toUpperCase()}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ])),
          StatusBadge(label: group.status.toUpperCase(), color: group.isActive ? AppColors.success : AppColors.error),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: group.progressPercent, backgroundColor: AppColors.divider, color: AppColors.primary, minHeight: 6),
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Cycle ${group.currentCycle}/${group.cycleDuration}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text('${AppUtils.formatCurrency(group.monthlyContribution)}/mo',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
        ]),
        if (group.nextAuctionDate != null) ...[
          const SizedBox(height: 8), const Divider(height: 1), const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.gavel_rounded, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text('Next Auction: ${AppUtils.formatDate(group.nextAuctionDate!)}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ]),
        ],
      ]),
    );
  }
}

class _DiscoverCard extends ConsumerStatefulWidget {
  final GroupModel group;
  const _DiscoverCard({required this.group});

  @override
  ConsumerState<_DiscoverCard> createState() => _DiscoverCardState();
}

class _DiscoverCardState extends ConsumerState<_DiscoverCard> {
  bool _joining = false;

  Future<void> _join() async {
    setState(() => _joining = true);
    try {
      await ref.read(groupsNotifierProvider.notifier).joinGroup(widget.group.groupId);
      if (mounted) {
        showSnack(context, 'Successfully joined ${widget.group.groupName}! 🎉');
        ref.invalidate(myGroupsProvider);
        ref.invalidate(allPublicGroupsProvider);
      }
    } catch (e) {
      if (mounted) showSnack(context, 'Failed to join. Try again.', isError: true);
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.group_rounded, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.group.groupName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textPrimary)),
            Text(widget.group.foremanName.isNotEmpty ? 'by ${widget.group.foremanName}' : 'Admin Group',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ])),
          if (widget.group.privacy == 'invite_only')
            const Icon(Icons.lock_rounded, size: 16, color: AppColors.textSecondary),
        ]),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 6, children: [
          _chip(Icons.group_rounded, '${widget.group.currentMembers}/${widget.group.totalMembers}'),
          _chip(Icons.currency_rupee_rounded, '${AppUtils.formatCurrency(widget.group.monthlyContribution)}/mo'),
          _chip(Icons.category_rounded, widget.group.fundType.toUpperCase()),
          _chip(Icons.calendar_today_rounded, '${widget.group.cycleDuration} months'),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: widget.group.isFull || _joining ? null : _join,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.group.isFull ? AppColors.textSecondary : AppColors.primary,
            ),
            child: _joining
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(widget.group.isFull ? 'Group Full' : 'Join Group'),
          ),
        ),
      ]),
    );
  }

  Widget _chip(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: AppColors.textSecondary), const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
    ]),
  );
}
