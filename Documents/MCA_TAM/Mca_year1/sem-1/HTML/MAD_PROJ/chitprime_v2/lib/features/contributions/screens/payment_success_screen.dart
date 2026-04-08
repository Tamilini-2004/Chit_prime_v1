import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/shared_widgets.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final Map<String, dynamic>? data;
  const PaymentSuccessScreen({super.key, this.data});
  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scale = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final d = widget.data ?? {};
    final amount = (d['amount'] as double?) ?? 0;
    final groupName = d['groupName'] as String? ?? 'Group';
    final txnId = d['txnId'] as String? ?? '';
    final date = d['date'] as DateTime? ?? DateTime.now();
    final method = d['method'] as String? ?? 'UPI';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const Spacer(),
            ScaleTransition(
              scale: _scale,
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 60),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Payment Successful!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text('Your contribution has been recorded', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 32),
            AppCard(child: Column(children: [
              _row('Group', groupName),
              _row('Amount Paid', AppUtils.formatCurrency(amount)),
              _row('Payment Method', method),
              _row('Transaction ID', txnId),
              _row('Date & Time', AppUtils.formatDateTime(date)),
            ])),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () => showSnack(context, 'Receipt downloaded! 📄'),
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Download Receipt'),
            ),
            const SizedBox(height: 12),
            GradientButton(label: 'Back to Home', onPressed: () => context.go('/dashboard'), icon: Icons.home_rounded),
          ]),
        ),
      ),
    );
  }

  Widget _row(String l, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      Flexible(child: Text(v, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary), textAlign: TextAlign.right)),
    ]),
  );
}
