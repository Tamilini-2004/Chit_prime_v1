import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../group_management/providers/group_management_provider.dart';

class GroupsTab extends StatelessWidget {
  const GroupsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroupManagementProvider>();

    return Column(
      children: [
        _buildFilters(context, provider),
        Expanded(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.filteredGroups.isEmpty
                  ? const AppEmptyState(
                      icon: Icons.group_outlined, title: 'No groups found')
                  : RefreshIndicator(
                      onRefresh: () => provider.loadGroups(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.filteredGroups.length,
                        itemBuilder: (_, i) =>
                            _GroupAdminCard(group: provider.filteredGroups[i]),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context, GroupManagementProvider provider) {
    final filters = ['all', 'active', 'suspended', 'completed'];
    return SizedBox(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: filters.length,
        itemBuilder: (_, i) {
          final f = filters[i];
          return GestureDetector(
            onTap: () => provider.setFilter(f),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Text(
                f[0].toUpperCase() + f.substring(1),
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GroupAdminCard extends StatelessWidget {
  final dynamic group;
  const _GroupAdminCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<GroupManagementProvider>();
    final statusColor = group.status == 'active'
        ? AppColors.success
        : group.status == 'suspended'
            ? AppColors.error
            : AppColors.textSecondary;

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.group_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.groupName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.textPrimary)),
                    Text(
                        '${group.currentMembers}/${group.totalMembers} Members',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              StatusBadge(
                  label: group.status.toUpperCase(), color: statusColor),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _chip('Cycle ${group.currentCycle}/${group.cycleDuration}',
                  AppColors.primary),
              const SizedBox(width: 8),
              _chip(AppUtils.formatCurrency(group.monthlyContribution) + '/mo',
                  AppColors.secondary),
              const SizedBox(width: 8),
              _chip('Fund: ${AppUtils.formatCurrency(group.totalFund)}',
                  AppColors.accent),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: group.progressPercent,
              backgroundColor: AppColors.divider,
              color: AppColors.primary,
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _actionBtn(
                  group.status == 'active' ? 'Suspend' : 'Activate',
                  group.status == 'active'
                      ? Icons.pause_circle_rounded
                      : Icons.play_circle_rounded,
                  group.status == 'active' ? AppColors.error : AppColors.success,
                  () => provider.suspendGroup(group.groupId),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _actionBtn(
                  'View Details',
                  Icons.visibility_rounded,
                  AppColors.primary,
                  () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w500)),
    );
  }

  Widget _actionBtn(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 12, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
