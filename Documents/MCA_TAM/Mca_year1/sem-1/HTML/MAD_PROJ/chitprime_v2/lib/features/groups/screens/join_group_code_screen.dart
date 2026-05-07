import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../providers/groups_provider.dart';

class JoinGroupCodeScreen extends ConsumerStatefulWidget {
  const JoinGroupCodeScreen({super.key});

  @override
  ConsumerState<JoinGroupCodeScreen> createState() =>
      _JoinGroupCodeScreenState();
}

class _JoinGroupCodeScreenState extends ConsumerState<JoinGroupCodeScreen> {
  final _codeCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_codeCtrl.text.trim().isEmpty) {
      showSnack(context, 'Enter a valid group code', isError: true);
      return;
    }
    setState(() => _submitting = true);
    try {
      final groupId = await ref
          .read(groupsNotifierProvider.notifier)
          .joinGroupByCode(_codeCtrl.text.trim());
      if (mounted) {
        showSnack(context, 'Joined group successfully!');
        ref.invalidate(myGroupsProvider);
        ref.invalidate(allPublicGroupsProvider);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted)
        showSnack(context, 'Failed to join: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Group by Code')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter group code to join',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            TextField(
              controller: _codeCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Group Code',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.vpn_key_rounded),
              ),
            ),
            const SizedBox(height: 24),
            GradientButton(
              label: 'Join Group',
              icon: Icons.group_add_rounded,
              isLoading: _submitting,
              onPressed: _submit,
            ),
            const SizedBox(height: 16),
            const Text('Note',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text(
                'Use the code shared by the group foreman or admin to join invite-only groups.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
