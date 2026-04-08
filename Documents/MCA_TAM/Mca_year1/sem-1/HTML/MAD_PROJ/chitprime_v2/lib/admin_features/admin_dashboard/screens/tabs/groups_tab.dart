import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../features/groups/providers/groups_provider.dart';
import '../../../../features/auction/providers/auction_provider.dart';
import 'overview_tab.dart';

class GroupsTab extends ConsumerStatefulWidget {
  const GroupsTab({super.key});
  @override
  ConsumerState<GroupsTab> createState() => _GroupsTabState();
}

class _GroupsTabState extends ConsumerState<GroupsTab> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(allGroupsProvider).valueOrNull ?? [];
    final filtered = _filter == 'all'
        ? groups
        : groups.where((g) => g.status == _filter).toList();

    return Column(children: [
      // Filter chips
      SizedBox(
        height: 56,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: ['all', 'active', 'cycle_in_progress', 'terminated']
              .map((f) => GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: _filter == f ? AppColors.primary : AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        f.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _filter == f ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),

      // Create Group button for admin
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: GradientButton(
          label: 'Create New Group & Notify Members',
          icon: Icons.add_circle_rounded,
          onPressed: () => _showCreateGroupDialog(context),
        ),
      ),

      // Groups list
      Expanded(
        child: filtered.isEmpty
            ? const AppEmptyState(icon: Icons.group_outlined, title: 'No groups found')
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final g = filtered[i];
                  return AppCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.group_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(g.groupName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
                          Text('${g.currentMembers}/${g.totalMembers} • ${g.fundType.toUpperCase()} • by ${g.foremanName.isNotEmpty ? g.foremanName : 'Admin'}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ])),
                        StatusBadge(label: g.status.toUpperCase(), color: g.isActive ? AppColors.success : AppColors.error),
                      ]),
                      const SizedBox(height: 10),
                      Row(children: [
                        _chip('Cycle ${g.currentCycle}/${g.cycleDuration}', AppColors.primary),
                        const SizedBox(width: 8),
                        _chip('${AppUtils.formatCurrency(g.monthlyContribution)}/mo', AppColors.secondary),
                        const SizedBox(width: 8),
                        _chip('₹${AppUtils.formatCurrency(g.totalFund)}', AppColors.accent),
                      ]),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(value: g.progressPercent, backgroundColor: AppColors.divider, color: AppColors.primary, minHeight: 5),
                      ),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(child: _btn(context, 'View', AppColors.primary, () => context.push('/groups/${g.groupId}'))),
                        const SizedBox(width: 8),
                        Expanded(child: _btn(context, 'Auction', AppColors.secondary, () async {
                          await ref.read(auctionNotifierProvider.notifier).openAuction(g.groupId);
                          if (context.mounted) showSnack(context, 'Auction opened! Members notified 🔨');
                        })),
                        const SizedBox(width: 8),
                        Expanded(child: _btn(
                          context,
                          g.isActive ? 'Suspend' : 'Activate',
                          g.isActive ? AppColors.error : AppColors.success,
                          () async {
                            if (g.isActive) {
                              await ref.read(groupsNotifierProvider.notifier).suspendGroup(g.groupId);
                            } else {
                              await ref.read(groupsNotifierProvider.notifier).reactivateGroup(g.groupId);
                            }
                            if (context.mounted) showSnack(context, 'Group ${g.isActive ? 'suspended' : 'activated'}');
                          },
                        )),
                      ]),
                    ]),
                  );
                },
              ),
      ),
    ]);
  }

  void _showCreateGroupDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    double contribution = 5000;
    int members = 10;
    int duration = 12;
    String fundType = 'auction';
    bool loading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Create Group', style: TextStyle(fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(hintText: 'Group Name', prefixIcon: Icon(Icons.group_rounded)),
              ),
              const SizedBox(height: 12),
              _dialogSlider('Monthly Contribution', '₹${contribution.toInt()}', contribution, 1000, 100000,
                  (v) => setS(() => contribution = v)),
              _dialogSlider('Total Members', '$members', members.toDouble(), 2, 50,
                  (v) => setS(() => members = v.toInt())),
              _dialogSlider('Duration (months)', '$duration months', duration.toDouble(), 2, 36,
                  (v) => setS(() => duration = v.toInt())),
              const SizedBox(height: 8),
              Row(children: ['auction', 'lottery'].map((t) => Expanded(child: GestureDetector(
                onTap: () => setS(() => fundType = t),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: fundType == t ? AppColors.primary : AppColors.inputFill,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(child: Text(t.toUpperCase(),
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                          color: fundType == t ? Colors.white : AppColors.textSecondary))),
                ),
              ))).toList()),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: loading ? null : () async {
                setS(() => loading = true);
                try {
                  final groupId = await ref.read(groupsNotifierProvider.notifier).createGroup(
                    name: nameCtrl.text.trim().isEmpty ? 'Admin Chit Group' : nameCtrl.text.trim(),
                    contribution: contribution,
                    members: members,
                    duration: duration,
                    fundType: fundType,
                    privacy: 'public',
                  );
                  // Notify ALL users about new group
                  await _notifyAllUsers(
                    groupId: groupId,
                    groupName: nameCtrl.text.trim().isEmpty ? 'Admin Chit Group' : nameCtrl.text.trim(),
                    contribution: contribution,
                  );
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    showSnack(context, 'Group created! All members notified 🎉');
                  }
                } catch (e) {
                  if (ctx.mounted) showSnack(context, 'Failed: $e', isError: true);
                } finally {
                  setS(() => loading = false);
                }
              },
              child: loading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Create & Notify'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _notifyAllUsers({
    required String groupId,
    required String groupName,
    required double contribution,
  }) async {
    final db = FirebaseFirestore.instance;
    // Get all users with role = member
    final users = await db.collection('users')
        .where('accountStatus', isEqualTo: 'active')
        .get();

    final batch = db.batch();
    for (final u in users.docs) {
      final role = u.data()['role'] ?? 'member';
      if (role == 'super_admin' || role == 'admin') continue;
      final notifRef = db.collection('notifications').doc();
      batch.set(notifRef, {
        'toUid': u.id,
        'fromUid': 'admin',
        'type': 'group',
        'title': '🆕 New Group Available!',
        'message': 'Admin created "$groupName" — ${AppUtils.formatCurrency(contribution)}/month. Join now!',
        'isRead': false,
        'relatedId': groupId,
        'relatedType': 'group',
        'actionRoute': '/groups',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Widget _dialogSlider(String label, String value, double current, double min, double max, ValueChanged<double> onChanged) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
      ]),
      Slider(value: current.clamp(min, max), min: min, max: max, activeColor: AppColors.primary, onChanged: onChanged),
    ]);
  }

  Widget _chip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
    child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
  );

  Widget _btn(BuildContext context, String label, Color color, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.2))),
      child: Center(child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600))),
    ),
  );
}
