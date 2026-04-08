import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../../contributions/providers/payment_provider.dart';
import '../../groups/providers/groups_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final myGroups = ref.watch(myGroupsProvider).valueOrNull ?? [];
    final contribs = ref.watch(myContributionsProvider).valueOrNull ?? [];
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final totalPaid = contribs.where((c) => c.status == 'success').fold(0.0, (s, c) => s + c.amount);

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 200, pinned: true,
          leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => context.pop()),
          actions: [IconButton(icon: const Icon(Icons.edit_rounded, color: Colors.white), onPressed: () => context.push('/profile/edit'))],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
              child: SafeArea(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const SizedBox(height: 40),
                CircleAvatar(radius: 36, backgroundColor: Colors.white.withOpacity(0.2), child: Text(AppUtils.getInitials(user.name), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white))),
                const SizedBox(height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(width: 6),
                  const Icon(Icons.verified_rounded, color: AppColors.accent, size: 18),
                ]),
                Text('Member since ${AppUtils.formatDate(user.createdAt)}', style: const TextStyle(fontSize: 12, color: Colors.white70)),
              ])),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(delegate: SliverChildListDelegate([
            // Stats
            Row(children: [
              Expanded(child: StatCard(label: 'Active Groups', value: '${myGroups.length}', icon: Icons.group_rounded, iconColor: AppColors.primary, iconBg: AppColors.primary.withOpacity(0.1))),
              const SizedBox(width: 10),
              Expanded(child: StatCard(label: 'Total Paid', value: AppUtils.formatCurrency(totalPaid), icon: Icons.currency_rupee_rounded, iconColor: AppColors.secondary, iconBg: AppColors.secondary.withOpacity(0.1))),
              const SizedBox(width: 10),
              Expanded(child: StatCard(label: 'Credit Score', value: '${user.creditScore}', icon: Icons.psychology_rounded, iconColor: AppColors.accent, iconBg: AppColors.accent.withOpacity(0.1))),
            ]),
            const SizedBox(height: 16),

            // Personal Info
            AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Personal Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              InfoRow(icon: Icons.phone_android_rounded, label: 'Phone', value: user.phone, verified: true),
              InfoRow(icon: Icons.email_outlined, label: 'Email', value: user.email.isEmpty ? 'Not provided' : user.email, verified: user.email.isNotEmpty),
              InfoRow(icon: Icons.badge_rounded, label: 'Role', value: user.role.toUpperCase()),
              InfoRow(icon: Icons.verified_user_rounded, label: 'KYC Status', value: user.kycStatus.toUpperCase(), verified: user.kycStatus == 'verified'),
            ])),

            // Bank Details
            if (user.bankName.isNotEmpty)
              AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Bank Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                InfoRow(icon: Icons.account_balance_rounded, label: 'Account', value: user.bankMasked.isEmpty ? 'Not added' : user.bankMasked),
                InfoRow(icon: Icons.code_rounded, label: 'IFSC', value: user.ifsc.isEmpty ? 'Not added' : user.ifsc),
                InfoRow(icon: Icons.business_rounded, label: 'Bank', value: user.bankName),
              ])),

            // Menu
            AppCard(padding: EdgeInsets.zero, child: Column(children: [
              _menuItem(context, Icons.receipt_long_rounded, 'Transaction History', AppColors.primary, () => _showTransactions(context, contribs)),
              const Divider(height: 1, indent: 56),
              _menuItem(context, Icons.psychology_rounded, 'My Credit Score', AppColors.secondary, () => context.push('/credit-score')),
              const Divider(height: 1, indent: 56),
              _menuItem(context, Icons.group_rounded, 'My Groups', AppColors.accent, () => context.push('/groups')),
              const Divider(height: 1, indent: 56),
              _menuItem(context, Icons.security_rounded, 'Security & Privacy', AppColors.textSecondary, () => _showInfo(context, 'Security & Privacy', 'Your data is protected with 256-bit SSL encryption. All sensitive data is encrypted at rest and in transit.')),
              const Divider(height: 1, indent: 56),
              _menuItem(context, Icons.help_outline_rounded, 'Help & Support', AppColors.textSecondary, () => _showInfo(context, 'Help & Support', 'Email: support@chitprime.com\nPhone: 1800-XXX-XXXX\nAvailable: Mon-Sat, 9AM-6PM')),
              const Divider(height: 1, indent: 56),
              _menuItem(context, Icons.info_outline_rounded, 'About CHITPRIME', AppColors.textSecondary, () => _showInfo(context, 'About CHITPRIME', 'CHITPRIME v2.0.0\nSmart Chit Fund Management\nPowered by Firebase & AI\n© 2024 CHITPRIME Technologies')),
            ])),

            // Logout
            AppCard(padding: EdgeInsets.zero, child: ListTile(
              leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20)),
              title: const Text('Logout', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.error)),
              onTap: () => _logout(context, ref),
            )),
            const SizedBox(height: 8),
            const Center(child: Text('CHITPRIME v2.0.0 • Firebase Connected', style: TextStyle(fontSize: 11, color: AppColors.textSecondary))),
            const SizedBox(height: 24),
          ])),
        ),
      ]),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }

  void _showTransactions(BuildContext context, List contribs) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(20, 20, 8, 0), child: Row(children: [
            const Text('Transaction History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const Spacer(),
            IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
          ])),
          Expanded(child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: contribs.length,
            itemBuilder: (_, i) {
              final c = contribs[i];
              final isSuccess = c.status == 'success';
              return AppCard(padding: const EdgeInsets.all(14), child: Row(children: [
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: (isSuccess ? AppColors.success : AppColors.error).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(isSuccess ? Icons.arrow_upward_rounded : Icons.cancel_rounded, color: isSuccess ? AppColors.success : AppColors.error, size: 20)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.groupName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
                  Text('Cycle ${c.cycleNumber} • ${c.paymentDate != null ? AppUtils.formatDate(c.paymentDate!) : 'Pending'}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text('TXN: ${c.transactionId}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(AppUtils.formatCurrency(c.amount), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: isSuccess ? AppColors.success : AppColors.error)),
                  StatusBadge(label: c.status.toUpperCase(), color: isSuccess ? AppColors.success : AppColors.error),
                ]),
              ]));
            },
          )),
        ]),
      ),
    );
  }

  void _showInfo(BuildContext context, String title, String content) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      content: Text(content, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
    ));
  }

  void _logout(BuildContext context, WidgetRef ref) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Logout'),
      content: const Text('Are you sure you want to logout?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await ref.read(authNotifierProvider.notifier).logout();
            if (context.mounted) context.go('/login');
          },
          child: const Text('Logout', style: TextStyle(color: AppColors.error)),
        ),
      ],
    ));
  }
}
