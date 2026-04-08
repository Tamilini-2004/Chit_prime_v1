import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/shared_widgets.dart';

class RegStep1Screen extends StatefulWidget {
  const RegStep1Screen({super.key});
  @override
  State<RegStep1Screen> createState() => _RegStep1ScreenState();
}

class _RegStep1ScreenState extends State<RegStep1Screen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() { _nameCtrl.dispose(); _emailCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personal Info (1/3)')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _progressBar(1),
          const SizedBox(height: 24),
          TextFormField(controller: _nameCtrl, decoration: const InputDecoration(hintText: 'Full Name (optional)', prefixIcon: Icon(Icons.person_outline_rounded))),
          const SizedBox(height: 16),
          TextFormField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'Email (optional)', prefixIcon: Icon(Icons.email_outlined))),
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.success.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
            child: const Row(children: [Icon(Icons.info_outline_rounded, size: 16, color: AppColors.success), SizedBox(width: 8), Expanded(child: Text('All fields are optional in this build', style: TextStyle(fontSize: 12, color: AppColors.success)))])),
          const Spacer(),
          GradientButton(label: 'Continue', onPressed: () => context.go('/register/2'), icon: Icons.arrow_forward_rounded),
        ]),
      ),
    );
  }

  Widget _progressBar(int step) => Row(children: List.generate(3, (i) => Expanded(child: Container(
    height: 4, margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
    decoration: BoxDecoration(color: i < step ? AppColors.primary : AppColors.divider, borderRadius: BorderRadius.circular(2)),
  ))));
}
