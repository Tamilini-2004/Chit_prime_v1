import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../user_management/providers/user_management_provider.dart';

class UsersTab extends StatelessWidget {
  const UsersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserManagementProvider>();

    return Column(
      children: [
        _buildSearchBar(context, provider),
        _buildFilters(context, provider),
        Expanded(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.filteredUsers.isEmpty
                  ? const AppEmptyState(
                      icon: Icons.people_outline_rounded,
                      title: 'No users found')
                  : RefreshIndicator(
                      onRefresh: () async {},
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.filteredUsers.length,
                        itemBuilder: (_, i) =>
                            _UserCard(user: provider.filteredUsers[i]),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, UserManagementProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        onChanged: provider.setSearch,
        decoration: InputDecoration(
          hintText: 'Search by name, phone, email...',
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          suffixIcon: const Icon(Icons.tune_rounded, size: 20),
          filled: true,
          fillColor: AppColors.inputFill,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context, UserManagementProvider provider) {
    final filters = ['all', 'active', 'inactive', 'verified', 'pending'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (_, i) {
          final f = filters[i];
          return GestureDetector(
            onTap: () => provider.setFilter(f),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Text(
                f[0].toUpperCase() + f.substring(1),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final dynamic user;
  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<UserManagementProvider>();
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  AppUtils.getInitials(user.fullName),
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.fullName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.textPrimary)),
                    Text('+91 ${user.phoneNumber}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                    if (user.email != null)
                      Text(user.email!,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusBadge(
                    label: user.isActive ? 'Active' : 'Inactive',
                    color: user.isActive ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(height: 4),
                  StatusBadge(
                    label: user.verificationStatus == 'verified'
                        ? 'Verified'
                        : 'Pending',
                    color: user.verificationStatus == 'verified'
                        ? AppColors.primary
                        : AppColors.warning,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _chip(Icons.psychology_rounded, 'Score: ${user.creditScore}',
                  AppColors.accent),
              const SizedBox(width: 8),
              _chip(Icons.calendar_today_rounded,
                  AppUtils.formatDate(user.createdAt), AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _actionBtn(
                  context,
                  user.isActive ? 'Suspend' : 'Activate',
                  user.isActive ? Icons.block_rounded : Icons.check_circle_rounded,
                  user.isActive ? AppColors.error : AppColors.success,
                  () => provider.toggleUserStatus(user.userId),
                ),
              ),
              const SizedBox(width: 8),
              if (user.verificationStatus != 'verified')
                Expanded(
                  child: _actionBtn(
                    context,
                    'Verify',
                    Icons.verified_rounded,
                    AppColors.primary,
                    () => provider.verifyUser(user.userId),
                  ),
                ),
              if (user.verificationStatus == 'verified')
                Expanded(
                  child: _actionBtn(
                    context,
                    'View Profile',
                    Icons.person_rounded,
                    AppColors.secondary,
                    () => _showUserDetail(context, user),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _actionBtn(BuildContext context, String label, IconData icon,
      Color color, VoidCallback onTap) {
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

  void _showUserDetail(BuildContext context, dynamic user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('User Profile',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const Spacer(),
                IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            _detailRow('Full Name', user.fullName),
            _detailRow('Phone', '+91 ${user.phoneNumber}'),
            _detailRow('Email', user.email ?? 'N/A'),
            _detailRow('Credit Score', '${user.creditScore}'),
            _detailRow('Verification', user.verificationStatus),
            _detailRow('Status', user.isActive ? 'Active' : 'Inactive'),
            _detailRow('Joined', AppUtils.formatDate(user.createdAt)),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}
