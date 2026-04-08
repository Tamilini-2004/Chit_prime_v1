import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../contributions/providers/payment_provider.dart';
import '../../auth/providers/auth_provider.dart';

class EscrowPayoutScreen extends ConsumerWidget {
  final String payoutId;
  const EscrowPayoutScreen({super.key, required this.payoutId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payout = ref.watch(payoutProvider(payoutId)).valueOrNull;
    if (payout == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final user = ref.watch(currentUserProvider).valueOrNull;
    final isForeman = user?.isForeman ?? false;
    final isWinner = user?.uid == payout.winnerUid;
    final isReleased = payout.escrowStatus == 'released';

    return Scaffold(
      appBar: AppBar(title: const Text('Escrow & Payout'), leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop())),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // Status card
        AppCard(
          gradient: isReleased ? const LinearGradient(colors: [AppColors.success, Color(0xFF059669)]) : AppColors.primaryGradient,
          child: Column(children: [
            Icon(isReleased ? Icons.check_circle_rounded : Icons.lock_rounded, color: Colors.white, size: 48),
            const SizedBox(height: 12),
            Text(isReleased ? 'Payout Released!' : 'Funds in Escrow', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(isReleased ? 'Transferred to winner\'s bank' : 'Awaiting foreman confirmation', style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 16),
            Text(AppUtils.formatCurrency(payout.netPayout), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w700)),
            const Text('Net Payout Amount', style: TextStyle(color: Colors.white70, fontSize: 13)),
          ]),
        ),
        const SizedBox(height: 16),

        // Winner info
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Winner Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Row(children: [
            CircleAvatar(radius: 24, backgroundColor: AppColors.accent.withOpacity(0.1),
              child: Text(AppUtils.getInitials(payout.winnerName), style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700, fontSize: 16))),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(payout.winnerName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textPrimary)),
              Text(payout.groupName, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ]),
            const Spacer(),
            if (isWinner) StatusBadge(label: 'You Won!', color: AppColors.accent),
          ]),
        ])),

        // Breakdown
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Financial Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          _row('Gross Amount', AppUtils.formatCurrency(payout.grossAmount)),
          _row('Platform Commission (3%)', '- ${AppUtils.formatCurrency(payout.platformCommission)}'),
          _row('GST on Commission (18%)', '- ${AppUtils.formatCurrency(payout.gstAmount)}'),
          const Divider(height: 20),
          _row('Net Payout', AppUtils.formatCurrency(payout.netPayout), bold: true),
          const SizedBox(height: 8),
          _row('Escrow Status', payout.escrowStatus.toUpperCase()),
          _row('Payout Status', payout.status.toUpperCase()),
          _row('Cycle', 'Cycle ${payout.cycleNumber}'),
          _row('Payout ID', payout.payoutId),
        ])),

        // Foreman action
        if (isForeman && !isReleased) ...[
          const SizedBox(height: 8),
          GradientButton(
            label: 'Confirm & Release Payout',
            onPressed: () async {
              await ref.read(paymentNotifierProvider.notifier).confirmPayout(payoutId);
              if (context.mounted) showSnack(context, 'Payout released! ${payout.winnerName} has been notified 🎉');
            },
            icon: Icons.check_circle_rounded,
          ),
        ],

        if (isReleased) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => showSnack(context, 'Receipt downloaded! 📄'),
            icon: const Icon(Icons.download_rounded, size: 18),
            label: const Text('Download Payout Receipt'),
          ),
        ],
      ]),
    );
  }

  Widget _row(String l, String v, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: TextStyle(fontSize: 13, color: bold ? AppColors.textPrimary : AppColors.textSecondary, fontWeight: bold ? FontWeight.w600 : FontWeight.w400)),
      Text(v, style: TextStyle(fontSize: 13, color: bold ? AppColors.primary : AppColors.textPrimary, fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
    ]),
  );
}
