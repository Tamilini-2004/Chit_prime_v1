import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/firebase_keys.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/widgets/shared_widgets.dart';
import 'overview_tab.dart';

class UsersTab extends ConsumerStatefulWidget {
  const UsersTab({super.key});
  @override
  ConsumerState<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends ConsumerState<UsersTab> {
  String _search = '';
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final allUsers = ref.watch(allUsersProvider).valueOrNull ?? [];
    final filtered = allUsers.where((u) {
      final name = (u['name'] ?? '').toString().toLowerCase();
      final phone = (u['phone'] ?? '').toString();
      final matchSearch = _search.isEmpty || name.contains(_search.toLowerCase()) || phone.contains(_search);
      final status = u['accountStatus'] ?? 'active';
      final kycStatus = u['kycStatus'] ?? 'pending';
      final matchFilter = _filter == 'all' || (_filter == 'active' && status == 'active') || (_filter == 'suspended' && status == 'suspended') || (_filter == 'verified' && kycStatus == 'verified') || (_filter == 'pending' && kycStatus == 'pending');
      return matchSearch && matchFilter;
    }).toList();

    return Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), child: TextField(
        onChanged: (v) => setState(() => _search = v),
        decoration: InputDecoration(hintText: 'Search by name, phone...', prefixIcon: const Icon(Icons.search_rounded, size: 20), suffixIcon: const Icon(Icons.tune_rounded, size: 20), filled: true, fillColor: AppColors.inputFill, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(vertical: 12)),
      )),
      SizedBox(height: 40, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
        children: ['all', 'active', 'suspended', 'verified', 'pending'].map((f) => GestureDetector(
          onTap: () => setState(() => _filter = f),
          child: Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: _filter == f ? AppColors.primary : AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(f[0].toUpperCase() + f.substring(1), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _filter == f ? Colors.white : AppColors.primary))),
        )).toList(),
      )),
      Expanded(child: filtered.isEmpty
          ? const AppEmptyState(icon: Icons.people_outline_rounded, title: 'No users found')
          : ListView.builder(padding: const EdgeInsets.all(16), itemCount: filtered.length, itemBuilder: (_, i) => _UserCard(user: filtered[i]))),
    ]);
  }
}

class _UserCard extends ConsumerWidget {
  final Map<String, dynamic> user;
  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = user['uid'] as String;
    final name = user['name'] as String? ?? 'Unknown';
    final phone = user['phone'] as String? ?? '';
    final score = (user['creditScore'] as num?)?.toInt() ?? 0;
    final isActive = user['accountStatus'] == 'active';
    final isVerified = user['kycStatus'] == 'verified';

    return AppCard(padding: const EdgeInsets.all(14), child: Column(children: [
      Row(children: [
        CircleAvatar(radius: 22, backgroundColor: AppColors.primary.withOpacity(0.1), child: Text(AppUtils.getInitials(name), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
          Text(phone, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          StatusBadge(label: isActive ? 'Active' : 'Suspended', color: isActive ? AppColors.success : AppColors.error),
          const SizedBox(height: 4),
          StatusBadge(label: isVerified ? 'KYC ✓' : 'KYC Pending', color: isVerified ? AppColors.primary : AppColors.warning),
        ]),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        _chip(Icons.psychology_rounded, 'Score: $score', AppColors.accent),
        const SizedBox(width: 8),
        _chip(Icons.badge_rounded, (user['role'] as String? ?? 'member').toUpperCase(), AppColors.primary),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _btn(isActive ? 'Suspend' : 'Activate', isActive ? AppColors.error : AppColors.success, () => _toggleStatus(context, ref, uid, isActive))),
        const SizedBox(width: 8),
        if (!isVerified) Expanded(child: _btn('Verify KYC', AppColors.primary, () => _verifyKyc(context, ref, uid, name))),
        if (isVerified) Expanded(child: _btn('Message', AppColors.secondary, () => context.push('/admin/chat/admin_001_$uid'))),
        const SizedBox(width: 8),
        Expanded(child: _btn('Notify', AppColors.accent, () => _sendNotif(context, ref, uid, name))),
      ]),
    ]));
  }

  Widget _chip(IconData icon, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 12, color: color), const SizedBox(width: 4), Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500))]),
  );

  Widget _btn(String label, Color color, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.2))),
      child: Center(child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)))),
  );

  Future<void> _toggleStatus(BuildContext context, WidgetRef ref, String uid, bool isActive) async {
    final newStatus = isActive ? 'suspended' : 'active';
    await FirebaseFirestore.instance.collection(FirebaseKeys.users).doc(uid).update({'accountStatus': newStatus});
    // Notify user
    await FirebaseFirestore.instance.collection(FirebaseKeys.notifications).add({
      'toUid': uid, 'fromUid': 'admin', 'type': 'system',
      'title': isActive ? '🚫 Account Suspended' : '✅ Account Activated',
      'message': isActive ? 'Your account has been suspended by admin. Contact support.' : 'Your account has been reactivated. Welcome back!',
      'isRead': false, 'relatedId': '', 'relatedType': 'account', 'actionRoute': '/profile',
      'createdAt': FieldValue.serverTimestamp(),
    });
    // Log admin action
    await _logAction(uid, isActive ? 'suspend_user' : 'activate_user', 'user');
    if (context.mounted) showSnack(context, 'User ${isActive ? 'suspended' : 'activated'} and notified');
  }

  Future<void> _verifyKyc(BuildContext context, WidgetRef ref, String uid, String name) async {
    await FirebaseFirestore.instance.collection(FirebaseKeys.users).doc(uid).update({'kycStatus': 'verified'});
    await FirebaseFirestore.instance.collection(FirebaseKeys.notifications).add({
      'toUid': uid, 'fromUid': 'admin', 'type': 'system',
      'title': '✅ KYC Verified!', 'message': 'Your KYC documents have been verified. You now have full access to CHITPRIME.',
      'isRead': false, 'relatedId': '', 'relatedType': 'kyc', 'actionRoute': '/profile',
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _logAction(uid, 'verify_kyc', 'user');
    if (context.mounted) showSnack(context, '$name KYC verified and notified ✓');
  }

  Future<void> _sendNotif(BuildContext context, WidgetRef ref, String uid, String name) async {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text('Send Notification to $name'),
      content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Enter message...'), maxLines: 3),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: () async {
          Navigator.pop(context);
          if (ctrl.text.trim().isEmpty) return;
          await FirebaseFirestore.instance.collection(FirebaseKeys.notifications).add({
            'toUid': uid, 'fromUid': 'admin', 'type': 'system',
            'title': '📢 Message from Admin', 'message': ctrl.text.trim(),
            'isRead': false, 'relatedId': '', 'relatedType': 'admin_message', 'actionRoute': '',
            'createdAt': FieldValue.serverTimestamp(),
          });
          if (context.mounted) showSnack(context, 'Notification sent to $name');
        }, child: const Text('Send')),
      ],
    ));
  }

  Future<void> _logAction(String targetId, String actionType, String targetType) async {
    await FirebaseFirestore.instance.collection(FirebaseKeys.adminActionsLog).add({
      'adminUid': 'admin_001', 'adminName': 'Admin User',
      'actionType': actionType, 'targetId': targetId, 'targetType': targetType,
      'notes': '', 'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
