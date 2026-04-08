import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/shared_widgets.dart';

class RegStep2Screen extends StatelessWidget {
  const RegStep2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KYC Documents (2/3)')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _progressBar(2),
          const SizedBox(height: 24),
          _docCard(context, 'Aadhaar Card', Icons.credit_card_rounded, 'Front & Back'),
          _docCard(context, 'PAN Card', Icons.article_outlined, 'Clear photo'),
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
            child: const Row(children: [Icon(Icons.info_outline_rounded, size: 16, color: AppColors.warning), SizedBox(width: 8), Expanded(child: Text('KYC is auto-verified in this test build. You can skip.', style: TextStyle(fontSize: 12, color: AppColors.warning)))])),
          const Spacer(),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => context.go('/register/3'), child: const Text('Skip for now'))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(onPressed: () => context.go('/register/3'), child: const Text('Continue'))),
          ]),
        ]),
      ),
    );
  }

  Widget _progressBar(int step) => Row(children: List.generate(3, (i) => Expanded(child: Container(
    height: 4, margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
    decoration: BoxDecoration(color: i < step ? AppColors.primary : AppColors.divider, borderRadius: BorderRadius.circular(2)),
  ))));

  Widget _docCard(BuildContext context, String title, IconData icon, String subtitle) {
    return GestureDetector(
      onTap: () => showSnack(context, '$title upload simulated ✓'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary.withOpacity(0.2))),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppColors.primary, size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ])),
          const Icon(Icons.upload_rounded, color: AppColors.primary),
        ]),
      ),
    );
  }
}
