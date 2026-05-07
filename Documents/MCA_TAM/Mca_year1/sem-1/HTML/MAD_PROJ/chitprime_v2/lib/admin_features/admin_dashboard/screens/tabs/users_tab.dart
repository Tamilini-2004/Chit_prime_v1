import 'dart:convert';

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

  bool _isPendingReview(Map<String, dynamic> user) {
    return (user['registrationCompleted'] ?? true) &&
        (user['kycStatus'] ?? '') == FirebaseKeys.statusPending;
  }

  @override
  Widget build(BuildContext context) {
    final allUsers = ref.watch(allUsersProvider).valueOrNull ?? [];
    final pendingCount = allUsers.where(_isPendingReview).length;
    final filtered = allUsers.where((u) {
      final name = (u['name'] ?? '').toString().toLowerCase();
      final phone = (u['phone'] ?? '').toString();
      final matchSearch = _search.isEmpty ||
          name.contains(_search.toLowerCase()) ||
          phone.contains(_search);
      final status = u['accountStatus'] ?? FirebaseKeys.statusActive;
      final kycStatus = u['kycStatus'] ?? '';
      final isPending = _isPendingReview(u);
      final matchFilter = _filter == 'all' ||
          (_filter == 'active' && status == FirebaseKeys.statusActive) ||
          (_filter == 'suspended' &&
              status == FirebaseKeys.statusSuspended) ||
          (_filter == 'verified' &&
              kycStatus == FirebaseKeys.statusVerified) ||
          (_filter == 'pending' && isPending);
      return matchSearch && matchFilter;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'Search by name, phone...',
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
        ),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: ['all', 'active', 'suspended', 'verified', 'pending']
                .map(
                  (f) => GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _filter == f
                            ? AppColors.primary
                            : AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        f == 'pending'
                            ? 'To Be Verified'
                            : f[0].toUpperCase() + f.substring(1),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _filter == f
                              ? Colors.white
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        if (pendingCount > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: AppCard(
              color: AppColors.warning.withOpacity(0.08),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.fact_check_rounded,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '$pendingCount user${pendingCount == 1 ? '' : 's'} waiting in the To Be Verified queue with Aadhaar details and image uploads.',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        Expanded(
          child: filtered.isEmpty
              ? const AppEmptyState(
                  icon: Icons.people_outline_rounded,
                  title: 'No users found',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _UserCard(user: filtered[i]),
                ),
        ),
      ],
    );
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
    final email = user['email'] as String? ?? '';
    final aadhaarNumber = user['aadhaarNumber'] as String? ?? '';
    final aadhaarImageUrl = user['aadhaarImageUrl'] as String? ?? '';
    final aadhaarImageData = user['aadhaarImageData'] as String? ?? '';
    final score = (user['creditScore'] as num?)?.toInt() ?? 0;
    final isActive = user['accountStatus'] == FirebaseKeys.statusActive;
    final isVerified = user['kycStatus'] == FirebaseKeys.statusVerified;
    final isPendingReview =
        (user['registrationCompleted'] ?? true) &&
            user['kycStatus'] == FirebaseKeys.statusPending;
    final isDraft =
        !(user['registrationCompleted'] ?? true) ||
            user['kycStatus'] == 'draft';
    final submittedAt = (user['kycSubmittedAt'] as Timestamp?)?.toDate();
    final kycLabel = isVerified
        ? 'KYC Verified'
        : isPendingReview
            ? 'To Be Verified'
            : isDraft
                ? 'KYC Draft'
                : 'KYC Pending';
    final kycColor = isVerified
        ? AppColors.primary
        : isPendingReview
            ? AppColors.warning
            : AppColors.textSecondary;

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  AppUtils.getInitials(name),
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
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      phone,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (email.isNotEmpty)
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusBadge(
                    label: isActive ? 'Active' : 'Suspended',
                    color: isActive ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(height: 4),
                  StatusBadge(label: kycLabel, color: kycColor),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(Icons.psychology_rounded, 'Score: $score',
                  AppColors.accent),
              _chip(
                Icons.badge_rounded,
                (user['role'] as String? ?? 'member').toUpperCase(),
                AppColors.primary,
              ),
              if (isPendingReview)
                _chip(Icons.hourglass_top_rounded, 'To Be Verified',
                    AppColors.warning),
            ],
          ),
          if (isPendingReview ||
              aadhaarNumber.isNotEmpty ||
              aadhaarImageUrl.isNotEmpty ||
              aadhaarImageData.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isPendingReview
                      ? AppColors.warning.withOpacity(0.35)
                      : AppColors.divider,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'KYC Details',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _detailRow('Email', email.isEmpty ? 'Not provided' : email),
                  _detailRow('Aadhaar', aadhaarNumber.isEmpty ? 'Not provided' : aadhaarNumber),
                  _detailRow(
                    'Submitted',
                    submittedAt == null
                        ? 'Awaiting submission'
                        : AppUtils.formatDateTime(submittedAt),
                  ),
                  if (aadhaarImageUrl.isNotEmpty ||
                      aadhaarImageData.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () =>
                          _showAadhaarPreview(
                        context,
                        aadhaarImageUrl,
                        aadhaarImageData,
                        name,
                      ),
                      child: _buildAadhaarImage(
                        aadhaarImageUrl: aadhaarImageUrl,
                        aadhaarImageData: aadhaarImageData,
                        height: 160,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap the image to view it larger.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final actionWidth = (constraints.maxWidth - 8) / 2;
              final actions = <Widget>[
                SizedBox(
                  width: actionWidth,
                  child: _btn(
                    isActive ? 'Suspend' : 'Activate',
                    isActive ? AppColors.error : AppColors.success,
                    () => _toggleStatus(context, ref, uid, isActive),
                  ),
                ),
                if (isPendingReview)
                  SizedBox(
                    width: actionWidth,
                    child: _btn(
                      'Verify KYC',
                      AppColors.primary,
                      () => _verifyKyc(context, ref, uid, name),
                    ),
                  )
                else if (isVerified)
                  SizedBox(
                    width: actionWidth,
                    child: _btn(
                      'Message',
                      AppColors.secondary,
                      () => context.push('/admin/chat/admin_001_$uid'),
                    ),
                  ),
                SizedBox(
                  width: actionWidth,
                  child: _btn(
                    'Notify',
                    AppColors.accent,
                    () => _sendNotif(context, ref, uid, name),
                  ),
                ),
              ];
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: actions,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) => Container(
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
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );

  Widget _btn(String label, Color color, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );

  Widget _detailRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 74,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      );

  Future<void> _toggleStatus(
    BuildContext context,
    WidgetRef ref,
    String uid,
    bool isActive,
  ) async {
    final newStatus =
        isActive ? FirebaseKeys.statusSuspended : FirebaseKeys.statusActive;
    await FirebaseFirestore.instance
        .collection(FirebaseKeys.users)
        .doc(uid)
        .update({'accountStatus': newStatus});
    await FirebaseFirestore.instance.collection(FirebaseKeys.notifications).add({
      'toUid': uid,
      'fromUid': 'admin',
      'type': 'system',
      'title': isActive ? '🚫 Account Suspended' : '✅ Account Activated',
      'message': isActive
          ? 'Your account has been suspended by admin. Contact support.'
          : 'Your account has been reactivated. Welcome back!',
      'isRead': false,
      'relatedId': '',
      'relatedType': 'account',
      'actionRoute': '/profile',
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _logAction(uid, isActive ? 'suspend_user' : 'activate_user', 'user');
    if (context.mounted) {
      showSnack(
        context,
        'User ${isActive ? 'suspended' : 'activated'} and notified',
      );
    }
  }

  Future<void> _verifyKyc(
    BuildContext context,
    WidgetRef ref,
    String uid,
    String name,
  ) async {
    await FirebaseFirestore.instance
        .collection(FirebaseKeys.users)
        .doc(uid)
        .update({
      'kycStatus': FirebaseKeys.statusVerified,
      'registrationCompleted': true,
      'kycVerifiedAt': FieldValue.serverTimestamp(),
    });
    await FirebaseFirestore.instance.collection(FirebaseKeys.notifications).add({
      'toUid': uid,
      'fromUid': 'admin',
      'type': 'system',
      'title': '✅ KYC Verified!',
      'message':
          'Your Aadhaar details and document were verified. You now have full access to CHITPRIME.',
      'isRead': false,
      'relatedId': '',
      'relatedType': 'kyc',
      'actionRoute': '/profile',
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _logAction(uid, 'verify_kyc', 'user');
    if (context.mounted) {
      showSnack(context, '$name KYC verified and notified');
    }
  }

  Future<void> _sendNotif(
    BuildContext context,
    WidgetRef ref,
    String uid,
    String name,
  ) async {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Send Notification to $name'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Enter message...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (ctrl.text.trim().isEmpty) return;
              await FirebaseFirestore.instance
                  .collection(FirebaseKeys.notifications)
                  .add({
                'toUid': uid,
                'fromUid': 'admin',
                'type': 'system',
                'title': '📢 Message from Admin',
                'message': ctrl.text.trim(),
                'isRead': false,
                'relatedId': '',
                'relatedType': 'admin_message',
                'actionRoute': '',
                'createdAt': FieldValue.serverTimestamp(),
              });
              if (context.mounted) {
                showSnack(context, 'Notification sent to $name');
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  Future<void> _logAction(
    String targetId,
    String actionType,
    String targetType,
  ) async {
    await FirebaseFirestore.instance
        .collection(FirebaseKeys.adminActionsLog)
        .add({
      'adminUid': 'admin_001',
      'adminName': 'Admin User',
      'actionType': actionType,
      'targetId': targetId,
      'targetType': targetType,
      'notes': '',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _showAadhaarPreview(
    BuildContext context,
    String imageUrl,
    String imageData,
    String name,
  ) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '$name Aadhaar',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              InteractiveViewer(
                child: _buildAadhaarImage(
                  aadhaarImageUrl: imageUrl,
                  aadhaarImageData: imageData,
                  height: 420,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAadhaarImage({
    required String aadhaarImageUrl,
    required String aadhaarImageData,
    required double height,
    BoxFit fit = BoxFit.cover,
  }) {
    if (aadhaarImageData.isNotEmpty) {
      try {
        final bytes = base64Decode(aadhaarImageData.split(',').last);
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            bytes,
            height: height,
            width: double.infinity,
            fit: fit,
          ),
        );
      } catch (_) {}
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        aadhaarImageUrl,
        height: height,
        width: double.infinity,
        fit: fit,
        errorBuilder: (_, __, ___) => Container(
          height: height,
          color: AppColors.divider,
          alignment: Alignment.center,
          child: const Text(
            'Could not load Aadhaar image',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
