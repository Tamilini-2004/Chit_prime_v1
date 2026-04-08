import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../auth/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});
  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameCtrl, _emailCtrl, _bankCtrl, _ifscCtrl, _bankNameCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider).valueOrNull;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _bankCtrl = TextEditingController(text: user?.bankMasked ?? '');
    _ifscCtrl = TextEditingController(text: user?.ifsc ?? '');
    _bankNameCtrl = TextEditingController(text: user?.bankName ?? '');
  }

  @override
  void dispose() { for (final c in [_nameCtrl, _emailCtrl, _bankCtrl, _ifscCtrl, _bankNameCtrl]) c.dispose(); super.dispose(); }

  Future<void> _save() async {
    setState(() => _loading = true);
    final uid = ref.read(authStateProvider).valueOrNull?.uid ?? '';
    await ref.read(authNotifierProvider.notifier).updateProfile(uid, {
      'name': _nameCtrl.text.trim().isEmpty ? 'Test User' : _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'bankMasked': _bankCtrl.text.trim(),
      'ifsc': _ifscCtrl.text.trim(),
      'bankName': _bankNameCtrl.text.trim(),
    });
    if (mounted) { setState(() => _loading = false); showSnack(context, 'Profile updated successfully!'); context.pop(); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile'), leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _field('Full Name', _nameCtrl, Icons.person_outline_rounded),
          const SizedBox(height: 16),
          _field('Email Address', _emailCtrl, Icons.email_outlined, type: TextInputType.emailAddress),
          const SizedBox(height: 16),
          const Text('Bank Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          _field('Account Number', _bankCtrl, Icons.account_balance_outlined, type: TextInputType.number),
          const SizedBox(height: 12),
          _field('IFSC Code', _ifscCtrl, Icons.code_rounded),
          const SizedBox(height: 12),
          _field('Bank Name', _bankNameCtrl, Icons.business_rounded),
          const SizedBox(height: 24),
          GradientButton(label: 'Save Changes', isLoading: _loading, onPressed: _save, icon: Icons.save_rounded),
        ]),
      ),
    );
  }

  Widget _field(String hint, TextEditingController ctrl, IconData icon, {TextInputType? type}) {
    return TextFormField(controller: ctrl, keyboardType: type, decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, size: 20)));
  }
}
