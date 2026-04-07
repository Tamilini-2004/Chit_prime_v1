import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../../credit_score/providers/credit_score_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final scoreProvider = context.watch<CreditScoreProvider>();
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: Colors.white),
                onPressed: () => context.push(AppRoutes.editProfile),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          AppUtils.getInitials(user.fullName),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(user.fullName,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                          const SizedBox(width: 6),
                          const Icon(Icons.verified_rounded, color: AppColors.accent, size: 18),
                        ],
                      ),
                      Text('Member since ${AppUtils.formatDate(user.createdAt)}',
                          style: const TextStyle(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildStats(),
                const SizedBox(height: 16),
                _buildPersonalInfo(user),
                const SizedBox(height: 16),
                _buildDocuments(user),
                const SizedBox(height: 16),
                _buildBankDetails(user),
                const SizedBox(height: 16),
                _buildMenuOptions(context, scoreProvider.score),
                const SizedBox(height: 16),
                _buildLogout(context),
                const SizedBox(height: 8),
                const Center(child: Text('CHITPRIME v1.0.0', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(child: StatCard(label: 'Active Groups', value: '2', icon: Icons.group_rounded, iconColor: AppColors.primary, iconBg: AppColors.primary.withOpacity(0.1))),
        const SizedBox(width: 10),
        Expanded(child: StatCard(label: 'Total Paid', value: '₹64K', icon: Icons.currency_rupee_rounded, iconColor: AppColors.secondary, iconBg: AppColors.secondary.withOpacity(0.1))),
        const SizedBox(width: 10),
        Expanded(child: StatCard(label: 'Cycles Done', value: '13', icon: Icons.check_circle_rounded, iconColor: AppColors.success, iconBg: AppColors.success.withOpacity(0.1))),
      ],
    );
  }

  Widget _buildPersonalInfo(dynamic user) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Personal Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          _infoRow(Icons.phone_android_rounded, 'Phone', '+91 ${user.phoneNumber}', verified: true),
          _infoRow(Icons.email_outlined, 'Email', user.email ?? 'Not provided', verified: user.email != null),
        ],
      ),
    );
  }

  Widget _buildDocuments(dynamic user) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Verified Documents', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          _docRow('Aadhaar Card', user.aadhaarNumber != null ? AppUtils.maskAadhaar(user.aadhaarNumber!) : 'Not uploaded', user.aadhaarNumber != null),
          _docRow('PAN Card', user.panNumber != null ? AppUtils.maskPan(user.panNumber!) : 'Not uploaded', user.panNumber != null),
        ],
      ),
    );
  }

  Widget _buildBankDetails(dynamic user) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bank Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          _infoRow(Icons.account_balance_rounded, 'Account', user.bankAccount != null ? AppUtils.maskAccount(user.bankAccount!) : 'Not added'),
          _infoRow(Icons.code_rounded, 'IFSC', user.ifscCode ?? 'Not added'),
          _infoRow(Icons.business_rounded, 'Bank', user.bankName ?? 'Not added'),
        ],
      ),
    );
  }

  Widget _buildMenuOptions(BuildContext context, int score) {
    final items = [
      _MenuItem(Icons.receipt_long_rounded, 'Transaction History', AppColors.primary, () => _showTransactionHistory(context)),
      _MenuItem(Icons.psychology_rounded, 'My Credit Score', AppColors.secondary, () => context.push(AppRoutes.creditScore)),
      _MenuItem(Icons.group_rounded, 'My Groups', AppColors.accent, () => context.push(AppRoutes.groups)),
      _MenuItem(Icons.security_rounded, 'Security & Privacy', AppColors.textSecondary, () => _showInfoDialog(context, 'Security & Privacy', 'Your data is protected with 256-bit SSL encryption. Biometric authentication is available on supported devices.')),
      _MenuItem(Icons.help_outline_rounded, 'Help & Support', AppColors.textSecondary, () => _showInfoDialog(context, 'Help & Support', 'For support, contact us at:\nsupport@chitprime.com\n\nPhone: 1800-XXX-XXXX\nAvailable: Mon-Sat, 9AM-6PM')),
      _MenuItem(Icons.description_outlined, 'Terms & Conditions', AppColors.textSecondary, () => _showInfoDialog(context, 'Terms & Conditions', 'By using CHITPRIME, you agree to our terms of service. Chit fund operations are governed by the Chit Funds Act, 1982. All transactions are subject to applicable taxes.')),
      _MenuItem(Icons.info_outline_rounded, 'About CHITPRIME', AppColors.textSecondary, () => _showInfoDialog(context, 'About CHITPRIME', 'CHITPRIME v1.0.0\n\nSmart Chit Fund Management for Small Retailers.\n\nBuilt with Flutter • Powered by AI\n© 2024 CHITPRIME Technologies Pvt. Ltd.')),
    ];

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: items.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          return Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: item.color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(item.icon, color: item.color, size: 20),
                ),
                title: Text(item.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                trailing: item.label == 'My Credit Score'
                    ? Row(mainAxisSize: MainAxisSize.min, children: [
                        StatusBadge(label: '$score', color: AppColors.success),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
                      ])
                    : const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
                onTap: item.onTap,
              ),
              if (i < items.length - 1) const Divider(height: 1, indent: 56),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showTransactionHistory(BuildContext context) {
    final transactions = [
      {'group': 'Retailers Gold Circle', 'amount': 5000.0, 'date': DateTime(2024, 8, 5), 'type': 'Contribution', 'status': 'Success', 'txn': 'TXN20240805001'},
      {'group': 'Small Business Fund', 'amount': 3000.0, 'date': DateTime(2024, 7, 8), 'type': 'Contribution', 'status': 'Success', 'txn': 'TXN20240708002'},
      {'group': 'Retailers Gold Circle', 'amount': 5000.0, 'date': DateTime(2024, 7, 6), 'type': 'Contribution', 'status': 'Success', 'txn': 'TXN20240706001'},
      {'group': 'Retailers Gold Circle', 'amount': 5000.0, 'date': DateTime(2024, 6, 5), 'type': 'Contribution', 'status': 'Success', 'txn': 'TXN20240605001'},
      {'group': 'Small Business Fund', 'amount': 3000.0, 'date': DateTime(2024, 6, 7), 'type': 'Contribution', 'status': 'Success', 'txn': 'TXN20240607002'},
      {'group': 'Retailers Gold Circle', 'amount': 96460.0, 'date': DateTime(2024, 5, 15), 'type': 'Payout', 'status': 'Success', 'txn': 'PAY20240515001'},
      {'group': 'Retailers Gold Circle', 'amount': 5000.0, 'date': DateTime(2024, 5, 5), 'type': 'Contribution', 'status': 'Success', 'txn': 'TXN20240505001'},
      {'group': 'Small Business Fund', 'amount': 3000.0, 'date': DateTime(2024, 5, 8), 'type': 'Contribution', 'status': 'Failed', 'txn': 'TXN20240508002'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 8, 0),
              child: Row(
                children: [
                  const Text('Transaction History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: AppCard(
                gradient: AppColors.primaryGradient,
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.payments_rounded, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Transactions', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text(AppUtils.formatCurrency(transactions.where((t) => t['status'] == 'Success').fold(0.0, (s, t) => s + (t['amount'] as double))),
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: transactions.length,
                itemBuilder: (_, i) {
                  final t = transactions[i];
                  final isPayout = t['type'] == 'Payout';
                  final isSuccess = t['status'] == 'Success';
                  final color = !isSuccess ? AppColors.error : isPayout ? AppColors.success : AppColors.primary;
                  return AppCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: Icon(isPayout ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t['group'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
                              Text('${t['type']} • ${AppUtils.formatDate(t['date'] as DateTime)}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              Text('TXN: ${t['txn']}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${isPayout ? '+' : '-'}${AppUtils.formatCurrency(t['amount'] as double)}',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: color),
                            ),
                            StatusBadge(label: t['status'] as String, color: isSuccess ? AppColors.success : AppColors.error),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        content: Text(content, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildLogout(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
        ),
        title: const Text('Logout', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.error)),
        onTap: () => _confirmLogout(context),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();
              if (context.mounted) context.go(AppRoutes.login);
            },
            child: const Text('Logout', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {bool verified = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
              ],
            ),
          ),
          if (verified) const Icon(Icons.verified_rounded, size: 16, color: AppColors.success),
        ],
      ),
    );
  }

  Widget _docRow(String label, String value, bool isVerified) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isVerified ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(isVerified ? Icons.verified_rounded : Icons.pending_rounded, size: 16, color: isVerified ? AppColors.success : AppColors.warning),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
              ],
            ),
          ),
          StatusBadge(label: isVerified ? 'Verified' : 'Pending', color: isVerified ? AppColors.success : AppColors.warning),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MenuItem(this.icon, this.label, this.color, this.onTap);
}
