import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../providers/groups_provider.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});
  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _nameCtrl = TextEditingController();
  double _contribution = 5000;
  int _members = 10;
  int _duration = 12;
  String _fundType = 'auction';
  String _privacy = 'public';
  bool _loading = false;

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  Future<void> _create() async {
    setState(() => _loading = true);
    final groupId = await ref.read(groupsNotifierProvider.notifier).createGroup(
      name: _nameCtrl.text.trim().isEmpty ? 'My Chit Group' : _nameCtrl.text.trim(),
      contribution: _contribution, members: _members, duration: _duration,
      fundType: _fundType, privacy: _privacy,
    );
    if (mounted) {
      setState(() => _loading = false);
      showDialog(context: context, builder: (_) => AlertDialog(
        title: const Text('Group Created! 🎉'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Your group has been created successfully.'),
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.qr_code_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Group ID: $groupId', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
            ])),
        ]),
        actions: [
          ElevatedButton(onPressed: () { Navigator.pop(context); context.go('/groups/$groupId'); }, child: const Text('View Group')),
        ],
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Group')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextFormField(controller: _nameCtrl, decoration: const InputDecoration(hintText: 'Group Name (optional)', prefixIcon: Icon(Icons.group_rounded))),
          const SizedBox(height: 20),
          _slider('Monthly Contribution', '₹${_contribution.toInt()}', _contribution, 1000, 100000, (v) => setState(() => _contribution = v)),
          _slider('Total Members', '$_members members', _members.toDouble(), 2, 50, (v) => setState(() => _members = v.toInt())),
          _slider('Duration', '$_duration months', _duration.toDouble(), 2, 36, (v) => setState(() => _duration = v.toInt())),
          const SizedBox(height: 16),
          const Text('Fund Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Row(children: ['auction', 'lottery', 'on_request'].map((t) => Expanded(child: GestureDetector(
            onTap: () => setState(() => _fundType = t),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: _fundType == t ? AppColors.primary : AppColors.inputFill,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Text(t.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _fundType == t ? Colors.white : AppColors.textSecondary))),
            ),
          ))).toList()),
          const SizedBox(height: 16),
          Row(children: [
            const Text('Public Group', style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            const Spacer(),
            Switch(value: _privacy == 'public', onChanged: (v) => setState(() => _privacy = v ? 'public' : 'invite_only'), activeColor: AppColors.primary),
          ]),
          const SizedBox(height: 24),
          GradientButton(label: 'Create Group', isLoading: _loading, onPressed: _create, icon: Icons.add_circle_rounded),
        ]),
      ),
    );
  }

  Widget _slider(String label, String value, double current, double min, double max, ValueChanged<double> onChanged) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
      ]),
      Slider(value: current.clamp(min, max), min: min, max: max, activeColor: AppColors.primary, onChanged: onChanged),
    ]);
  }
}


