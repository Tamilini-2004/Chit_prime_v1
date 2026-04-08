import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../providers/auth_provider.dart';

class RegStep3Screen extends ConsumerStatefulWidget {
  const RegStep3Screen({super.key});
  @override
  ConsumerState<RegStep3Screen> createState() => _RegStep3ScreenState();
}

class _RegStep3ScreenState extends ConsumerState<RegStep3Screen> {
  final _bankCtrl = TextEditingController();
  final _ifscCtrl = TextEditingController();
  final _bankNameCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() { _bankCtrl.dispose(); _ifscCtrl.dispose(); _bankNameCtrl.dispose(); super.dispose(); }

  Future<void> _complete() async {
    setState(() => _loading = true);
    final uid = ref.read(authStateProvider).valueOrNull?.uid ?? '';
    await ref.read(authNotifierProvider.notifier).completeRegistration(
      uid: uid,
      name: 'Test User',
      bankName: _bankNameCtrl.text,
      ifsc: _ifscCtrl.text,
      bankMasked: _bankCtrl.text.length > 4 ? 'XXXX${_bankCtrl.text.substring(_bankCtrl.text.length - 4)}' : _bankCtrl.text,
    );
    if (mounted) { setState(() => _loading = false); context.go('/dashboard'); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bank Details (3/3)')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _progressBar(3),
          const SizedBox(height: 24),
          TextFormField(controller: _bankCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Account Number (optional)', prefixIcon: Icon(Icons.account_balance_outlined))),
          const SizedBox(height: 16),
          TextFormField(controller: _ifscCtrl, decoration: const InputDecoration(hintText: 'IFSC Code (optional)', prefixIcon: Icon(Icons.code_rounded))),
          const SizedBox(height: 16),
          TextFormField(controller: _bankNameCtrl, decoration: const InputDecoration(hintText: 'Bank Name (optional)', prefixIcon: Icon(Icons.business_rounded))),
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.success.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
            child: const Row(children: [Icon(Icons.lock_rounded, size: 16, color: AppColors.success), SizedBox(width: 8), Expanded(child: Text('All data encrypted and secure', style: TextStyle(fontSize: 12, color: AppColors.success)))])),
          const Spacer(),
          GradientButton(label: 'Complete Registration', isLoading: _loading, onPressed: _complete, icon: Icons.check_circle_rounded),
        ]),
      ),
    );
  }

  Widget _progressBar(int step) => Row(children: List.generate(3, (i) => Expanded(child: Container(
    height: 4, margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
    decoration: BoxDecoration(color: i < step ? AppColors.primary : AppColors.divider, borderRadius: BorderRadius.circular(2)),
  ))));
}
